from django.shortcuts import render
from django.views.generic import DetailView
from .models import Product

# Create your views here.
def home(request):
    # Lista de productos
    products = Product.objects.filter(active=True)
    return render(request, 'inventario/index.html', {'products': products})

class ProductDetailView(DetailView):
    model = Product
    template_name = 'inventario/detail.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        product_detail = self.get_object()
        context['product'] = product_detail
        return context