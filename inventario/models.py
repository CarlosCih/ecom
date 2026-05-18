from django.db import models
from django.utils.text import slugify
from django.urls import reverse

class Category(models.Model):
    name = models.CharField(max_length=50, unique=True)
    description = models.TextField(blank=True)
    parents = models.ForeignKey(
        'self',
        on_delete=models.CASCADE,
        related_name='children',
        null=True,
        blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Categoría'
        verbose_name_plural = 'Categorías'
        
    def __str__(self):
        return self.name
    
# Create your models here.
class Product(models.Model):
    
    def get_absolute_url(self):
        return reverse('product_detail', kwargs={'slug': self.slug})
    
    name = models.CharField(max_length=100, verbose_name='Nombre')
    category = models.ManyToManyField(
        Category,
        related_name='products',
        blank=True,
        verbose_name='Categorías'
    )
    description = models.TextField(verbose_name='Descripción')
    price = models.FloatField(verbose_name='Precio')
    stock = models.IntegerField(verbose_name='Stock')
    image = models.ImageField(upload_to='products/', null=True, blank=True, verbose_name='Imagen')
    slug = models.SlugField(unique=True, blank=True, verbose_name='Slug')
    active = models.BooleanField(default=True)
    # campos para auditoría
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'Producto'
        verbose_name_plural = 'Productos'
        
    def get_category_names(self):
        return ", ".join(category.name for category in self.category.all())
        
    def __str__(self):
        return self.name
    
    def save(self, *args, **kwargs):
        if not self.slug:
            base_slug = slugify(self.name)
            slug = base_slug
            counter = 1
            while Product.objects.filter(slug=slug).exists():
                slug = f"{base_slug}-{counter}"
                counter += 1
            self.slug = slug
        super().save(*args, **kwargs)

    
    