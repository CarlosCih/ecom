from django.shortcuts import render
from django.conf import settings
from django.core.paginator import Paginator
from django.views.generic import DetailView, ListView
from django.db.models import Count
from .models import Category, Product

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

class CategoriesListView(ListView):
    model = Category
    template_name = 'inventario/categories.html'
    
    def get_context_data(self, **kwargs):
        # Agregar la lista de categorías al contexto
        context = super().get_context_data(**kwargs)
        categories = Category.objects.filter(parents__isnull=True).annotate(
            children_count=Count('children')
        ).order_by('name')
        context['categories'] = categories
        return context

class SubcategoryListView(ListView):
    model = Category
    template_name = 'inventario/subcategories.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        parent = Category.objects.get(pk=self.kwargs['pk'])
        subcategories = Category.objects.filter(parents=parent).annotate(
            children_count=Count('children')
        ).order_by('name')
        # Construir cadena de ancestros para el breadcrumb
        ancestors = []
        node = parent
        while node.parents:
            ancestors.insert(0, node.parents)
            node = node.parents
        context['parent'] = parent
        context['subcategories'] = subcategories
        context['ancestors'] = ancestors
        return context
    
class CategoryProductListView(DetailView):
    model = Category
    template_name = 'inventario/category_products.html'
    
    def get_context_data(self, **kwargs):
        # Agregar la lista de productos de la categoría al contexto
        context = super().get_context_data(**kwargs)
        category = self.get_object()
        products_in_category = Product.objects.filter(category=category, active=True).order_by('name')
        paginator = Paginator(products_in_category, settings.PAGINATION_PAGE_SIZE)
        page_number = self.request.GET.get('page')
        page_obj = paginator.get_page(page_number)
        context['page_obj'] = page_obj
        return context