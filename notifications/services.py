import logging
from django.db import IntegrityError, transaction
from django.utils import timezone
from .models import Notification
from .tasks import send_notification_email_task

logger = logging.getLogger('notifications.services')

# Función para construir una clave de deduplicación única para cada evento de notificación
def build_dedupe_key(event_type, user_id, order_id, version='v1'):
    return f"{version}:{event_type}:{user_id}:{order_id}"

# Función para construir el contenido de la notificación basado en el tipo de evento y la orden asociada
def build_event_content(event_type, order):
    if event_type == Notification.EventType.ORDEN_CONFIRMED:
        return {
            'title': 'Tu orden ha sido confirmada',
            'body': f'Hola {order.user.first_name}, tu orden #{order.id} ha sido confirmada. Gracias por comprar con nosotros.',
        }
    if event_type == Notification.EventType.ORDEN_PAID:
        return {
            'title': 'Tu orden ha sido pagada',
            'body': f'Hola {order.user.first_name}, tu orden #{order.id} ha sido pagada exitosamente. Estamos preparando tu envío.',
        }
    if event_type == Notification.EventType.ORDEN_SHIPPED:
        return {
            'title': 'Tu orden ha sido enviada',
            'body': f'Hola {order.user.first_name}, tu orden #{order.id} ha sido enviada. Pronto llegará a tu domicilio.',
        }
    if event_type == Notification.EventType.ORDEN_DELIVERED:
        return {
            'title': 'Tu orden ha sido entregada',
            'body': f'Hola {order.user.first_name}, tu orden #{order.id} ha sido entregada. Esperamos que disfrutes tu compra.',
        }
    if event_type == Notification.EventType.ORDEN_CANCELLED:
        return {
            'title': 'Tu orden ha sido cancelada',
            'body': f'Hola {order.user.first_name}, tu orden #{order.id} ha sido cancelada. Si tienes alguna pregunta, contáctanos.',
        }
    if event_type == Notification.EventType.ORDEN_REFUNDED:
        return {
            'title': 'Tu orden ha sido reembolsada',
            'body': f'Hola {order.user.first_name}, tu orden #{order.id} ha sido reembolsada. El monto se acreditará a tu método de pago en breve.',
        }
    return {
        'title': 'Notificación de tu orden',
        'body': f'Hola {order.user.first_name}, tu orden #{order.id} ha tenido una actualización. Por favor revisa tu cuenta para más detalles.',
    }

# Función para crear una notificación basada en un evento específico    
def create_notification_event(*, user, event_type, order, chanel=Notification.Chanel.IN_APP, send_email=False):
    dedupe_key = build_dedupe_key(event_type, user.id, order.id)
    title, body = build_event_content(event_type, order)
    
    try:
        notification, created = Notification.objects.get_or_create(
            dedupe_key=dedupe_key,
            defaults={
                'user': user,
                'event_type': event_type,
                'chanel': chanel,
                'status': Notification.Status.PENDING,
                'title': title,
                'body': body,
                'payload_json':{
                    'order_id': order.id,
                    'order_status': order.status,
                    'created_at': timezone.now().isoformat(),
                }
            }
        )
    except IntegrityError:
        notification = Notification.objects.get(dedupe_key=dedupe_key)
        created = False
        
    if created and send_email:
        transaction.on_commit(lambda: send_notification_email_task.delay(notification.id))
        
    return notification, created

# Función para marcar una notificación como leída
def mark_notification_as_read(*, notification, user):
    if notification.user_id != user.id:
        logger.warning(f"Usuario {user.id} intentó marcar como leído una notificación que no le pertenece (Notificación {notification.id})")
        return False
    notification.mark_as_read()
    return notification
# Función para marcar todas las notificaciones de un usuario como leídas
def mark_all_notifications_as_read(*, user):
    now = timezone.now()
    return Notification.objects.filter(
        user=user,
    ).exclude(status=Notification.Status.READ).update(
        status=Notification.Status.READ,
        read_at=now,
        updated_at=now,
    )