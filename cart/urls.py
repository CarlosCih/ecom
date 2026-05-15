from django.urls import path

from . import views

urlpatterns = [
    path('add', views.add_to_cart, name='add_to_cart'),
    path('cart-overview', views.CartView.as_view(), name='cart_overview'),
    path('remove', views.remove_from_cart, name='remove_from_cart'),
]
