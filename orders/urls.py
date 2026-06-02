from django.urls import path

from . import views

urlpatterns = [
    # Crear orden de compra
    path('orden/', views.OrderCreateView.as_view(), name='order_create'),
    
    # Orden de compra stripe
    path('checkout/', views.create_checkout_session, name='create_checkout_session'),
    path('checkout/success/', views.checkout_success, name='checkout_success'),
    path('checkout/cancel/', views.checkout_cancel, name='checkout_cancel'),
    path('stripe/webhook/', views.stripe_webhook, name='stripe_webhook'),
    
    # Compras anteriores
    path('historial/', views.OrderHistoryView.as_view(), name='order_history'),
]
