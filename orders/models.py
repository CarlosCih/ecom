from decimal import Decimal

from django.conf import settings
from django.db import models
from django.utils import timezone

from inventario.models import Product


class Order(models.Model):
    class Status(models.TextChoices):
        PENDING = 'pending', 'Pendiente'
        PAID = 'paid', 'Pagada'
        CANCELED = 'canceled', 'Cancelada'
        FAILED = 'failed', 'Fallida'

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='orders',
    )
    email = models.EmailField(blank=True)
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PENDING,
    )
    currency = models.CharField(max_length=10, default='mxn')
    total = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0.00'))
    stripe_checkout_session_id = models.CharField(max_length=255, blank=True, db_index=True)
    stripe_payment_intent_id = models.CharField(max_length=255, blank=True, db_index=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def mark_paid(self, payment_intent_id=''):
        self.status = self.Status.PAID
        self.stripe_payment_intent_id = payment_intent_id or self.stripe_payment_intent_id
        self.paid_at = timezone.now()
        self.save(update_fields=['status', 'stripe_payment_intent_id', 'paid_at', 'updated_at'])

    def __str__(self):
        return f'Orden #{self.pk} - {self.status}'


class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey(Product, on_delete=models.PROTECT, related_name='order_items')
    product_name = models.CharField(max_length=100)
    quantity = models.PositiveIntegerField()
    unit_price = models.DecimalField(max_digits=10, decimal_places=2)

    @property
    def subtotal(self):
        return self.unit_price * self.quantity

    def __str__(self):
        return f'{self.product_name} x {self.quantity}'
