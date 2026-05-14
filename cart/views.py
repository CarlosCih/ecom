from django.shortcuts import render
from django.http import JsonResponse
# Create your views here.
def add_to_cart(request):
    print('Producto agregado al carrito')
    if request.method == 'POST':
        product_id = request.POST.get('product_id')
        product_quantity = request.POST.get('quantity')
        print("ID del producto a agregar al carrito:", product_id)
        print("Cantidad del producto a agregar al carrito:", product_quantity)
    return JsonResponse({'message': 'Producto agregado al carrito'})