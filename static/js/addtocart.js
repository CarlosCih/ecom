// Evento para capturar el click en el botón "Agregar al carrito"
$(document).on('click', '#atc', function(e) {
    const btn = $(this);
    $.ajax({
        type: "POST",
        url: btn.data('url'),
        data: {
            'product_id': btn.data('id'),
            'csrfmiddlewaretoken': getCookie('csrftoken'),
            'quantity': $('#quantity').val()
        },
        success: function(json) {
            console.log("Respuesta del servidor:", json);
            document.getElementById('cart-count').textContent = json.cart_quantity;
            Swal.fire({
                title: "Producto agregado al carrito",
                icon: "success",
                draggable: true
            });
            
        }
    });
})