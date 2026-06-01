import logging
from decimal import Decimal, ROUND_HALF_UP

import stripe
from django.conf import settings
from django.db import transaction
from django.db.models import F
from django.http import HttpResponse, HttpResponseBadRequest
from django.shortcuts import redirect, render
from django.urls import reverse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST

from cart.cart import Cart
from inventario.models import Product
from .models import Order, OrderItem

logger = logging.getLogger('orders')


def _stripe_value(obj, key, default=None):
    if obj is None:
        return default
    if isinstance(obj, dict):
        return obj.get(key, default)
    return getattr(obj, key, default)


def _money_to_cents(value):
    amount = Decimal(str(value)).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)
    return int((amount * 100).quantize(Decimal('1'), rounding=ROUND_HALF_UP))


def _build_checkout_data(cart):
    line_items = []
    order_items = []
    total = Decimal('0.00')

    for item in cart:
        product = item['product']
        quantity = int(item['quantity'])
        unit_price = Decimal(str(item['price'])).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)

        if quantity <= 0:
            continue

        if product.stock < quantity:
            raise ValueError(f'Stock insuficiente para {product.name}')

        line_items.append(
            {
                'price_data': {
                    'currency': settings.STRIPE_CURRENCY,
                    'product_data': {
                        'name': product.name,
                        'metadata': {'product_id': str(product.id)},
                    },
                    'unit_amount': _money_to_cents(unit_price),
                },
                'quantity': quantity,
            }
        )
        order_items.append(
            {
                'product': product,
                'product_name': product.name,
                'quantity': quantity,
                'unit_price': unit_price,
            }
        )
        total += unit_price * quantity

    if not line_items:
        raise ValueError('El carrito esta vacio')

    return line_items, order_items, total.quantize(Decimal('0.01'))


@require_POST
def create_checkout_session(request):
    stripe.api_key = settings.STRIPE_SECRET_KEY
    cart = Cart(request)

    try:
        line_items, order_items, total = _build_checkout_data(cart)
    except ValueError as exc:
        logger.warning('Checkout no creado: %s', exc)
        return HttpResponseBadRequest(str(exc))

    user = request.user if request.user.is_authenticated else None
    email = request.user.email if request.user.is_authenticated else ''

    order = Order.objects.create(
        user=user,
        email=email,
        total=total,
        currency=settings.STRIPE_CURRENCY,
    )
    OrderItem.objects.bulk_create(
        OrderItem(order=order, **order_item)
        for order_item in order_items
    )

    success_url = request.build_absolute_uri(reverse('checkout_success'))
    cancel_url = request.build_absolute_uri(reverse('checkout_cancel'))
    checkout_params = {
        'mode': 'payment',
        'line_items': line_items,
        'success_url': f'{success_url}?session_id={{CHECKOUT_SESSION_ID}}',
        'cancel_url': cancel_url,
        'metadata': {'order_id': str(order.id)},
    }
    if email:
        checkout_params['customer_email'] = email

    try:
        session = stripe.checkout.Session.create(**checkout_params)
    except stripe.StripeError as exc:
        order.status = Order.Status.FAILED
        order.save(update_fields=['status', 'updated_at'])
        logger.error('Error creando Checkout Session para orden %s: %s', order.id, exc, exc_info=True)
        return HttpResponseBadRequest('No se pudo iniciar el pago. Intenta de nuevo.')

    order.stripe_checkout_session_id = session.id
    order.save(update_fields=['stripe_checkout_session_id', 'updated_at'])

    return redirect(session.url)


def checkout_success(request):
    session_id = request.GET.get('session_id')
    if session_id:
        stripe.api_key = settings.STRIPE_SECRET_KEY
        try:
            session = stripe.checkout.Session.retrieve(session_id)
            if _stripe_value(session, 'payment_status') == 'paid':
                request.session['cart'] = {}
                request.session.modified = True
        except stripe.StripeError:
            logger.warning('No se pudo verificar la sesion de exito: %s', session_id, exc_info=True)

    return render(request, 'orders/checkout_success.html')


def checkout_cancel(request):
    return render(request, 'orders/checkout_cancel.html')


def _mark_order_paid_from_session(session):
    metadata = _stripe_value(session, 'metadata', {}) or {}
    order_id = _stripe_value(metadata, 'order_id')
    if not order_id:
        logger.warning('Checkout Session sin order_id: %s', _stripe_value(session, 'id'))
        return

    with transaction.atomic():
        order = (
            Order.objects.select_for_update()
            .prefetch_related('items__product')
            .get(id=order_id)
        )

        if order.status == Order.Status.PAID:
            return

        payment_intent_id = _stripe_value(session, 'payment_intent') or ''
        order.mark_paid(payment_intent_id=payment_intent_id)

        for item in order.items.select_related('product'):
            updated = Product.objects.filter(
                id=item.product_id,
                stock__gte=item.quantity,
            ).update(stock=F('stock') - item.quantity)
            if not updated:
                logger.error('Stock insuficiente al confirmar orden %s, producto %s', order.id, item.product_id)


@csrf_exempt
@require_POST
def stripe_webhook(request):
    payload = request.body
    signature = request.META.get('HTTP_STRIPE_SIGNATURE')

    try:
        event = stripe.Webhook.construct_event(
            payload=payload,
            sig_header=signature,
            secret=settings.STRIPE_WEBHOOK_SECRET,
        )
    except ValueError:
        return HttpResponse(status=400)
    except stripe.SignatureVerificationError:
        return HttpResponse(status=400)

    event_type = _stripe_value(event, 'type')
    event_data = _stripe_value(event, 'data', {}) or {}
    session = _stripe_value(event_data, 'object', {}) or {}

    if event_type == 'checkout.session.completed' and _stripe_value(session, 'payment_status') == 'paid':
        _mark_order_paid_from_session(session)
    elif event_type == 'checkout.session.expired':
        metadata = _stripe_value(session, 'metadata', {}) or {}
        order_id = _stripe_value(metadata, 'order_id')
        if order_id:
            Order.objects.filter(id=order_id, status=Order.Status.PENDING).update(status=Order.Status.CANCELED)

    return HttpResponse(status=200)
