from django.shortcuts import render
from django.http import JsonResponse
from django.views import View
from inventario.models import Product
from .cart import Cart
from django.shortcuts import get_object_or_404
import logging

logger = logging.getLogger('cart')

# Create your views here.
def add_to_cart(request):
    cart = Cart(request)
    cart_quantity = 0
    if request.method == 'POST':
        product_id = request.POST.get('product_id')
        product_quantity = request.POST.get('quantity')
        try:
            product = get_object_or_404(Product, id=product_id)
            cart.add(product=product, quantity=product_quantity)
            cart_quantity = cart.__len__()
            logger.info("Producto id=%s agregado al carrito (cantidad=%s)", product_id, product_quantity)
        except Exception as e:
            logger.error("Error al agregar producto id=%s al carrito: %s", product_id, e, exc_info=True)
            return JsonResponse({'message': 'Error al agregar producto', 'cart_quantity': cart_quantity}, status=400)
    return JsonResponse({'message': 'Producto agregado al carrito', 'cart_quantity': cart_quantity})

class CartView(View):
    def get(self, request):
        cart = Cart(request)
        return render(request, 'cart/carrito.html', {'cart': cart})

    def post(self, request):
        cart = Cart(request)
        product_id = request.POST.get('product_id')
        quantity = request.POST.get('quantity')
        try:
            cart.update(product_id=product_id, quantity=quantity)
            logger.info("Carrito actualizado: producto id=%s cantidad=%s", product_id, quantity)
        except Exception as e:
            logger.error("Error al actualizar carrito producto id=%s: %s", product_id, e, exc_info=True)
            return JsonResponse({'message': 'Error al actualizar carrito'}, status=400)
        return JsonResponse({
            'message': 'Cantidad actualizada',
            'cart_quantity': len(cart),
            'cart_total': str(cart.get_total_price()),
        })

def remove_from_cart(request):
    cart = Cart(request)
    if request.method == 'POST':
        product_id = request.POST.get('product_id')
        try:
            cart.remove(product_id)
            logger.info("Producto id=%s eliminado del carrito", product_id)
        except Exception as e:
            logger.error("Error al eliminar producto id=%s del carrito: %s", product_id, e, exc_info=True)
            return JsonResponse({'message': 'Error al eliminar producto'}, status=400)
    return JsonResponse({
        'message': 'Producto eliminado del carrito',
        'cart_quantity': len(cart),
        'cart_total': str(cart.get_total_price()),
    })