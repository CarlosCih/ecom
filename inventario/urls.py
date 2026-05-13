from django.urls import path
from inventario import views


urlpatterns = [
    path('', views.home, name='home'),
    path('product/<slug:slug>/', views.ProductDetailView.as_view(), name='product_detail'),
]