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