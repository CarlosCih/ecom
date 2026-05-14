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
        return sum(int(item['quantity']) for item in self.cart.values())
    
    def add(self, product, quantity):
        # Agrega un producto al carrito o actualiza su cantidad
        product_id = product.id 
        if product_id in self.cart:
            self.cart[product_id]['quantity'] += int(quantity)
        else:
            self.cart[product_id] = {'quantity': int(quantity), 'price': str(product.price)}
        self.save()

    def save(self):
        # Guarda el carrito en la sesión
        self.session['cart'] = self.cart
        self.session.modified = True