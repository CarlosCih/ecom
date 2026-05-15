from django import template

# Los tags personalizados se utilizan para agregar funcionalidades específicas a las plantillas de Django. En este caso, se define un filtro personalizado llamado "to" que convierte un número en un rango de números (inclusive). Esto es útil para generar opciones en un select, por ejemplo, para la cantidad de productos en el carrito.

register = template.Library()

@register.filter
def to(start, end):
    # Convierte un número a un rango de números (inclusive)
    return range(start, end + 1)

