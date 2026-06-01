# Implementacion de Stripe en este proyecto Django

Este proyecto queda configurado para usar el SDK oficial `stripe` con Stripe Checkout. No se usa `dj-stripe`, porque para un flujo de ecommerce basico no hace falta sincronizar modelos internos de Stripe en Django.

## 1. Estado actual

- `stripe==15.1.0` ya esta en `requirements.txt`.
- `djstripe` ya no esta en `INSTALLED_APPS`.
- `ecom/urls.py` incluye `orders/`.
- `settings.py` lee claves de Stripe desde `.env`.
- El carrito vive en sesion mediante `cart/cart.py`.
- `orders` contiene modelos para guardar ordenes locales y confirmar pagos con webhook.
- El boton "Proceder al pago" del carrito envia un POST a `create_checkout_session`.

## 2. Variables de entorno

Agrega o conserva estas variables en `ecom/.env`:

```env
STRIPE_PUBLIC_KEY=pk_test_xxx
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_RESTRICTED_KEY=
STRIPE_WEBHOOK_SECRET=whsec_xxx
STRIPE_CURRENCY=mxn
```

Notas:

- `STRIPE_SECRET_KEY` crea la Checkout Session.
- `STRIPE_PUBLIC_KEY` queda disponible para pagos con Stripe.js si luego lo necesitas.
- `STRIPE_WEBHOOK_SECRET` valida que el webhook venga realmente de Stripe.
- `STRIPE_RESTRICTED_KEY` no se usa en el flujo actual; puede quedarse vacia.
- Si alguna clave real fue compartida, rotala desde el Dashboard de Stripe.

## 3. Configuracion en `settings.py`

La configuracion necesaria es:

```python
STRIPE_PUBLIC_KEY = env('STRIPE_PUBLIC_KEY')
STRIPE_SECRET_KEY = env('STRIPE_SECRET_KEY')
STRIPE_RESTRICTED_KEY = env('STRIPE_RESTRICTED_KEY', default='')
STRIPE_WEBHOOK_SECRET = env('STRIPE_WEBHOOK_SECRET', default='')
STRIPE_CURRENCY = env('STRIPE_CURRENCY', default='mxn')
```

## 4. URLs principales

En `ecom/urls.py`:

```python
urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('inventario.urls')),
    path('cart/', include('cart.urls')),
    path('orders/', include('orders.urls')),
    path('users/', include('users.urls')),
]
```

En `orders/urls.py`:

```python
urlpatterns = [
    path('checkout/', views.create_checkout_session, name='create_checkout_session'),
    path('checkout/success/', views.checkout_success, name='checkout_success'),
    path('checkout/cancel/', views.checkout_cancel, name='checkout_cancel'),
    path('stripe/webhook/', views.stripe_webhook, name='stripe_webhook'),
]
```

## 5. Flujo implementado

1. El usuario actualiza el carrito en `templates/cart/carrito.html`.
2. El boton "Proceder al pago" hace POST a `/orders/checkout/`.
3. `orders.views.create_checkout_session`:
   - Lee el carrito de sesion.
   - Valida stock.
   - Crea una `Order` local.
   - Crea sus `OrderItem`.
   - Crea una Stripe Checkout Session.
   - Redirige al usuario a Stripe.
4. Stripe redirige a success o cancel.
5. El webhook `/orders/stripe/webhook/` recibe `checkout.session.completed`.
6. Si el pago esta marcado como `paid`, la orden cambia a `paid` y se descuenta stock.

## 6. Modelos locales

`orders/models.py` guarda:

- `Order`: usuario, email, estado, total, moneda, ids de Stripe y fecha de pago.
- `OrderItem`: producto, nombre congelado del producto, cantidad y precio unitario.

Esto es importante porque Stripe confirma el pago, pero tu sistema necesita conservar su propia orden para inventario, administracion e historial.

## 7. Webhook local

Para probar localmente necesitas Stripe CLI:

```powershell
stripe listen --forward-to localhost:8000/orders/stripe/webhook/
```

El comando entrega un secreto `whsec_...`. Pegalo en:

```env
STRIPE_WEBHOOK_SECRET=whsec_xxx
```

Eventos minimos:

```txt
checkout.session.completed
checkout.session.expired
```

## 8. Migraciones

Despues de modificar modelos:

```powershell
python manage.py makemigrations orders
python manage.py migrate
```

## 9. Prueba manual

1. Ejecuta el servidor Django.
2. Ejecuta Stripe CLI con el forward al webhook.
3. Agrega productos al carrito.
4. Pulsa "Proceder al pago".
5. Usa una tarjeta de prueba de Stripe.
6. Verifica en admin o base de datos:
   - Se crea una `Order`.
   - Se crean sus `OrderItem`.
   - El webhook marca la orden como `paid`.
   - El stock baja despues del pago.

## 10. Recomendaciones antes de produccion

- Cambia `Product.price` de `FloatField` a `DecimalField(max_digits=10, decimal_places=2)`.
- Mueve `SECRET_KEY`, `DEBUG` y `ALLOWED_HOSTS` a `.env`.
- Usa HTTPS obligatorio en produccion.
- No confirmes una orden solo porque el usuario llego a la URL de exito; el webhook es la fuente confiable.
- Considera reserva temporal de inventario si el stock es critico. El flujo actual valida stock antes del pago y descuenta despues del webhook.

## Referencias

- Stripe Checkout: https://docs.stripe.com/payments/checkout/how-checkout-works
- Stripe Checkout Sessions API: https://docs.stripe.com/api/checkout/sessions
- Stripe webhooks: https://docs.stripe.com/webhooks
