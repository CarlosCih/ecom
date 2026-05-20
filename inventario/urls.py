from django.urls import path
from inventario import views


urlpatterns = [
    path('', views.home, name='home'),
    path('product/<slug:slug>/', views.ProductDetailView.as_view(), name='product_detail'),
    
    #Categorías
    path('categories/', views.CategoriesListView.as_view(), name='category_list'),
    path('category/<int:pk>/subcategories/', views.SubcategoryListView.as_view(), name='subcategory_list'),
    path('category/<int:pk>/products/', views.CategoryProductListView.as_view(), name='category_products'),


]