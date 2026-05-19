from django.shortcuts import render
from django.conf import settings
from django.core.paginator import Paginator
from django.views.generic import DetailView
from .models import Product

# Create your views here.
def home(request):
    # Lista de productos activos
    products = Product.objects.filter(active=True).order_by('-stock')
    paginator = Paginator(products, settings.PAGINATION_PAGE_SIZE)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    return render(request, 'inventario/index.html', {'page_obj': page_obj})

class ProductDetailView(DetailView):
    model = Product
    template_name = 'inventario/detail.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        product_detail = self.get_object()
        context['product'] = product_detail
        return context