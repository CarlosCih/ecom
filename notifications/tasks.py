from django.db import transaction, IntegrityError
from celery import shared_task
from django.core.mail import send_mail
from django.utils import timezone
from .models import Notification
import logging

logger = logging.getLogger('notifications.tasks')

@shared_task(bind=True, autoretry_for=(Exception,), retry_backoff=True, retry_kwargs={'max_retries': 3})
def send_notification_email_task(self, notification_id):
    notification = Notification.objects.select_related('user').get(id=notification_id)
    if not notification.user.email:
         logger.warning('Usuario sin email para notification_id=%s', notification_id)
         return 'skipped-no-email'
    send_mail(
        subject=notification.title,
        message=notification.body,
        from_email=None,  # Usa DEFAULT_FROM_EMAIL
        recipient_list=[notification.user.email],
        fail_silently=False,
    )
    
    notification.status = Notification.Status.SENT
    notification.sent_at = timezone.now()
    notification.save(update_fields=['status', 'sent_at', 'updated_at'])
    return 'email-sent'