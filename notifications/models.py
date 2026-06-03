from django.db import models
from django.utils import timezone
from django.conf import settings


# Create your models here.
class Notification(models.Model):
    CHOISES_EVENT_TYPE = {
    ('ORDEN_CONFIRMED', 'Orden Confirmada'),
    ('ORDEN_PAID', 'Orden Pagada'),
    ('ORDEN_REFUNDED', 'Orden Reembolsada'),
    ('ORDEN_SHIPPED', 'Orden Enviada'),
    ('ORDEN_DELIVERED', 'Orden Entregada'),
    ('ORDEN_OUT_FOR_DELIVERY', 'Orden en Camino'),
    ('ORDEN_CANCELLED', 'Orden Cancelada'),
    ('ORDEN_RETURNED', 'Orden Devuelta'),
    ('USER_REGISTERED', 'Usuario Registrado'),
    ('USER_PASSWORD_RESET', 'Restablecimiento de Contraseña'),
    ('USER_PROFILE_UPDATED', 'Perfil Actualizado'),
    ('USER_VERIFICATION', 'Verificación de Usuario'),
    }

    CHOISES_CHANEL = {
        ('IN_APP', 'Notificación en la aplicación'),
        ('EMAIL', 'Correo electrónico'),
        ('SMS', 'Mensaje de texto'),
        ('PUSH', 'Notificación push'),
    }

    CHOISES_STATUS = {
        ('PENDING', 'Pendiente'),
        ('SENT', 'Enviada'),
        ('FAILED', 'Fallida'),
        ('READ', 'Leída'),
    }
    
    user = models.ForeignKey('auth.User', on_delete=models.CASCADE, related_name='notifications', db_index=True, verbose_name='usuario')
    event_type = models.CharField(max_length=50, choices=CHOISES_EVENT_TYPE, verbose_name='tipo de evento', db_index=True)
    title = models.CharField(max_length=255, verbose_name='título')
    body = models.TextField(verbose_name='cuerpo')
    payload_json = models.JSONField(verbose_name='datos adicionales')
    status = models.CharField(max_length=20, choices=CHOISES_STATUS, default='PENDING', verbose_name='estado de la notificación', db_index=True)
    chanel = models.CharField(max_length=20, choices=CHOISES_CHANEL, verbose_name='canal de notificación')
    read_at = models.DateTimeField(null=True, blank=True, verbose_name='fecha de lectura')
    sent_at = models.DateTimeField(null=True, blank=True, verbose_name='fecha de envío')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='fecha de creación', db_index=True)
    updated_at = models.DateTimeField(auto_now=True, verbose_name='fecha de actualización')
    is_read = models.BooleanField(default=False, verbose_name='leído')
    
    class Meta:
        verbose_name = 'Notificación'
        verbose_name_plural = 'Notificaciones'
        ordering = ['-created_at']
        
    def mark_as_read(self):
        if self.status != self.Status.READ:
            self.status = self.Status.READ
            self.read_at = timezone.now()
            self.save(update_fields=['status', 'read_at', 'updated_at'])     
        
    def __str__(self):
        return f"Notificación {self.id} para {self.user.username} - {self.event_type}"