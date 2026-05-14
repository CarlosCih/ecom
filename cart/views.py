from django.shortcuts import render
from django.http import JsonResponse
from inventario.models import Product
from .cart import Cart
from django.shortcuts import get_object_or_404

# Create your views here.
def add_to_cart(request):
    cart = Cart(request)
    print('Producto agregado al carrito')
    if request.method == 'POST':
        product_id = request.POST.get('product_id')
        product_quantity = request.POST.get('quantity')
        print("ID del producto a agregar al carrito:", product_id)
        print("Cantidad del producto a agregar al carrito:", product_quantity)
        #product = Product.objects.get(id=product_id)
        product = get_object_or_404(Product, id=product_id)
        cart.add(product=product, quantity=product_quantity)
    return JsonResponse({'message': 'Producto agregado al carrito'})  