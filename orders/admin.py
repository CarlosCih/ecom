from django.contrib import admin

from .models import Order, OrderItem


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    readonly_fields = ('product', 'product_name', 'quantity', 'unit_price', 'subtotal')


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'email', 'status', 'total', 'currency', 'created_at', 'paid_at')
    list_filter = ('status', 'currency', 'created_at')
    search_fields = ('id', 'email', 'stripe_checkout_session_id', 'stripe_payment_intent_id')
    readonly_fields = (
        'stripe_checkout_session_id',
        'stripe_payment_intent_id',
        'paid_at',
        'created_at',
        'updated_at',
    )
    inlines = [OrderItemInline]
