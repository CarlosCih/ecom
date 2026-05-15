from decimal import Decimal
from inventario.models import Product
class Cart():
    def __init__(self, request):
        # Initialize the cart
        self.session = request.session
        # Get the cart from the session, if it doesn't exist, create an empty cart
        cart = self.session.get('cart')
        # If the cart doesn't exist in the session, create an empty cart and save it in the session
        if 'cart' not in self.session:
            cart = self.session['cart'] = {}
        self.cart = cart
    def __len__(self):
        # Contabiliza el número total de productos en el carrito
        return sum(int(item['quantity']) for item in self.cart.values())
    
    def __iter__(self):
        # Itera sobre los productos en el carrito y obtiene los objetos Product de la base de datos
        product_ids = self.cart.keys()
        products = Product.objects.filter(id__in=product_ids)
        # Agrega el objeto Product a cada item del carrito
        cart = self.cart.copy()
        for product in products:
            cart[str(product.id)]['product'] = product
        # Convierte el precio a float y calcula el precio total para cada item del carrito
        for item in cart.values():
            item['price'] = Decimal(item['price'])
            item['total_price'] = item['price'] * int(item['quantity'])
            yield item
    
    def add(self, product, quantity):
        # Agrega un producto al carrito o actualiza su cantidad
        product_id = str(product.id)  # str: JSON serializa claves como string
        if product_id in self.cart:
            self.cart[product_id]['quantity'] += int(quantity)
        else:
            self.cart[product_id] = {'quantity': int(quantity), 'price': str(product.price)}
        self.save()

    def update(self, product_id, quantity):
        # Actualiza la cantidad de un producto existente en el carrito
        product_id = str(product_id)
        if product_id in self.cart:
            self.cart[product_id]['quantity'] = int(quantity)
            self.save()

    def remove(self, product_id):
        # Elimina un producto del carrito
        product_id = str(product_id)
        if product_id in self.cart:
            del self.cart[product_id]
            self.save()

    def save(self):
        # Guarda el carrito en la sesión
        self.session['cart'] = self.cart
        self.session.modified = True
        
    def get_total_price(self):
        return sum(Decimal(item['price']) * int(item['quantity']) for item in self.cart.values())