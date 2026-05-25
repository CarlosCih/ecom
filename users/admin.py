from django.contrib import admin
from .models import PaymentMethod, Profile


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
	list_display = (
		'user',
		'telefono',
		'curp',
		'rfc',
		'pais',
		'estado',
		'ciudad',
	)
	list_filter = ('pais', 'estado', 'ciudad')
	search_fields = ('user__username', 'user__email', 'telefono', 'curp', 'rfc')
	raw_id_fields = ('user',)
	fieldsets = (
		(
			'Usuario',
			{
				'fields': ('user',),
			},
		),
		(
			'Datos personales',
			{
				'fields': ('telefono', 'fecha_nacimiento', 'curp', 'rfc'),
			},
		),
		(
			'Direccion',
			{
				'fields': ('pais', 'estado', 'ciudad', 'calle'),
			},
		),
		(
			'Imagen',
			{
				'fields': ('profile_picture',),
			},
		),
	)


@admin.register(PaymentMethod)
class PaymentMethodAdmin(admin.ModelAdmin):
	list_display = (
		'user',
		'card_brand',
		'last4',
		'expiration_month',
		'expiration_year',
		'is_default',
	)
	list_filter = ('card_brand', 'is_default', 'expiration_year')
	search_fields = ('user__username', 'user__email', 'last4', 'stripe_payment_method_id')
	raw_id_fields = ('user',)
