from django.db import models

# Create your models here.
class Profile(models.Model):
    # Relación uno a uno con el modelo User de Django
    user = models.OneToOneField('auth.User', on_delete=models.CASCADE)
    telefono = models.CharField(max_length=20, blank=True, null=True)
    fecha_nacimiento = models.DateField(blank=True, null=True)
    #idientificador oficial personal
    curp = models.CharField(max_length=20, blank=True, null=True)
    #identificador fiscal
    rfc = models.CharField(max_length=13, blank=True, null=True)
    pais = models.CharField(max_length=255, blank=True, null=True)
    estado = models.CharField(max_length=255, blank=True, null=True)
    ciudad = models.CharField(max_length=255, blank=True, null=True)
    calle = models.CharField(max_length=255, blank=True, null=True)
    profile_picture = models.ImageField(upload_to='profile_pictures/', blank=True, null=True)
    
    class Meta:
        verbose_name = 'Perfil'
        verbose_name_plural = 'Perfiles'
        
    def __str__(self):
        return f"Perfil de {self.user.username}"
    
class PaymentMethod(models.Model):
    user = models.ForeignKey('auth.User', on_delete=models.CASCADE)
    stripe_payment_method_id = models.CharField(max_length=255)  # ej. pm_1ABC...
    last4 = models.CharField(max_length=4)                        # últimos 4 dígitos
    card_brand = models.CharField(max_length=50)                  # visa, mastercard, etc.
    expiration_month = models.PositiveSmallIntegerField()
    expiration_year = models.PositiveSmallIntegerField()
    cardholder_name = models.CharField(max_length=255)
    is_default = models.BooleanField(default=False)

    class Meta:
        verbose_name = 'Método de Pago'
        verbose_name_plural = 'Métodos de Pago'

    def __str__(self):
        return f"{self.card_brand} ...{self.last4} ({self.user.username})"