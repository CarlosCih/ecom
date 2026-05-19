from django import template

register = template.Library()

@register.filter
def to(start, end):
    return range(start, end + 1)

@register.simple_tag
def page_range(page_obj, delta=2):
    """
    Retorna una lista de números de página con None como separador (ellipsis).
    Siempre incluye la primera y última página, y current ± delta.
    """
    paginator = page_obj.paginator
    current = page_obj.number
    total = paginator.num_pages

    # Construir el conjunto de páginas a mostrar
    pages = set()
    pages.add(1)
    pages.add(total)
    for i in range(current - delta, current + delta + 1):
        if 1 <= i <= total:
            pages.add(i)

    # Ordenar y agregar None donde hay saltos
    sorted_pages = sorted(pages)
    result = []
    prev = None
    for p in sorted_pages:
        if prev is not None and p - prev > 1:
            result.append(None)  # ellipsis
        result.append(p)
        prev = p
    return result

