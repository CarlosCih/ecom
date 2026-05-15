from django.shortcuts import render
from django.http import JsonResponse
from django.views import View
from inventario.models import Product
from .cart import Cart
from django.shortcuts import get_object_or_404

# Create your views here.
def add_to_cart(request):
    # Obtener el carrito de la sesión
    cart = Cart(request)
    print('Producto agregado al carrito')
    # Inicializar la cantidad del carrito
    cart_quantity = 0
    if request.method == 'POST':
        product_id = request.POST.get('product_id')
        product_quantity = request.POST.get('quantity')
        print("ID del producto a agregar al carrito:", product_id)
        print("Cantidad del producto a agregar al carrito:", product_quantity)
        #product = Product.objects.get(id=product_id)
        product = get_object_or_404(Product, id=product_id)
        cart.add(product=product, quantity=product_quantity)
        cart_quantity = cart.__len__()
    return JsonResponse({'message': 'Producto agregado al carrito', 'cart_quantity': cart_quantity})

class CartView(View):
    def get(self, request):
        cart = Cart(request)
        return render(request, 'cart/carrito.html', {'cart': cart})

def remove_from_cart(request):
    cart = Cart(request)
    if request.method == 'POST':
        product_id = request.POST.get('product_id')
        cart.remove(product_id)
    return JsonResponse({
        'message': 'Producto eliminado del carrito',
        'cart_quantity': len(cart),
        'cart_total': str(cart.get_total_price()),
    })