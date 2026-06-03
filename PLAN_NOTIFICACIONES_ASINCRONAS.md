# Plan de notificaciones asíncronas para ecom

## Objetivo
Implementar un sistema de notificaciones estilo marketplace (Amazon/Mercado Libre) que dispare avisos automáticos por eventos del ciclo de compra:
- compra confirmada
- cambio de estado de envío
- en reparto
- entrega completada
- cancelación
- reembolso

## Alcance real del proyecto (práctica)
- Este proyecto está orientado a aprendizaje, portafolio y base reusable.
- No está pensado para producción en su estado actual.
- Las decisiones técnicas deben priorizar simplicidad y velocidad de implementación.
- Se deja una arquitectura escalable como referencia para futuras adaptaciones comerciales.

## Stack recomendado para este proyecto (práctica + escalable)
1. Celery + Redis para procesamiento asíncrono de tareas.
2. Modelo interno de notificaciones (inbox por usuario) en base de datos.
3. Email transaccional como canal inicial.
4. Django Channels + channels-redis para tiempo real en la campana (fase posterior).
5. Proveedor de email vía Anymail (SendGrid, Mailgun o Brevo) cuando se pase a producción.

## Ruta mínima recomendada para práctica (sin sobreingeniería)
1. Empezar con inbox interno en base de datos + vista de notificaciones.
2. Usar Celery solo para eventos clave (compra confirmada/cancelación) y dejar el resto sincronizado temporalmente.
3. Mostrar cambios en UI por polling simple (cada 20-60 segundos) antes de incorporar websockets.
4. Dejar Channels, push y proveedores externos como fase opcional cuando el prototipo esté estable.

## Razón de arquitectura
- Permite desacoplar eventos de negocio del envío real de notificaciones.
- Evita bloquear la respuesta web cuando una compra se confirma.
- Facilita múltiples canales por el mismo evento (in-app, email, push en futuro).
- Escala por fases sin reescribir lo ya construido.

## Modelo de datos sugerido
Crear una entidad Notification con campos base:
- user: usuario destinatario
- event_type: tipo de evento (ORDER_CONFIRMED, ORDER_SHIPPED, etc.)
- title: título de notificación
- body: contenido
- payload_json: datos extra del evento (order_id, tracking, etc.)
- channel: in_app, email, push
- status: pending, sent, failed, read
- read_at: fecha de lectura
- sent_at: fecha de envío
- dedupe_key: clave única para evitar duplicados
- created_at, updated_at

## Catálogo inicial de eventos
- ORDER_CONFIRMED
- ORDER_PAID
- ORDER_SHIPPED
- ORDER_OUT_FOR_DELIVERY
- ORDER_DELIVERED
- ORDER_CANCELLED
- ORDER_REFUNDED

## Flujo recomendado por evento
1. Se actualiza la orden en base de datos.
2. Se publica evento con transaction.on_commit para garantizar consistencia.
3. Celery consume el evento.
4. Celery crea registro en inbox interno.
5. Celery envía email (si aplica por preferencias del usuario).
6. En fase real-time, se emite actualización por websocket al cliente.

## Reglas técnicas críticas
1. Idempotencia:
   - usar dedupe_key única por evento para no duplicar notificaciones.
2. Reintentos:
   - tareas Celery con retry y backoff exponencial.
3. Trazabilidad:
   - log por intento de envío y error por canal.
4. Preferencias de usuario:
   - permitir activar o desactivar categorías por canal.
5. Plantillas por evento:
   - estandarizar asunto y cuerpo para email e in-app.

## Fases de implementación

### Fase 1 (MVP funcional)
- Instalar Celery + Redis.
- Crear modelo Notification.
- Integrar evento ORDER_CONFIRMED.
- Guardar notificación in-app.
- Enviar email de confirmación asíncrono.
- Mostrar contador y listado básico de notificaciones en UI.

### Fase 2
- Integrar eventos de envío y entrega.
- Añadir endpoint para marcar como leído.
- Añadir filtros de notificaciones (no leídas, tipo de evento).

### Fase 3
- Implementar Django Channels.
- Actualizar campana en tiempo real al crear notificación.
- Reducir o eliminar polling en frontend.

### Fase 4
- Preferencias avanzadas por usuario.
- Integrar push móvil y/o WhatsApp.
- Métricas de entrega y aperturas.

## Dependencias sugeridas
- celery
- redis
- django-celery-results (opcional)
- channels
- channels-redis
- django-anymail

## Configuración base esperada
- Servicio Redis activo.
- Worker Celery ejecutándose.
- Beat Celery opcional si se requieren tareas programadas.
- Variables de entorno para proveedor de correo.

## Riesgos comunes y mitigación
1. Duplicados por reintentos:
   - proteger con dedupe_key y validación previa de existencia.
2. Notificaciones enviadas sin commit real:
   - publicar tarea solo dentro de transaction.on_commit.
3. Cuellos de botella de email:
   - usar proveedor transaccional y colas.
4. Falta de observabilidad:
   - registrar estados y errores por notificación.

## Criterios de éxito
- La confirmación de compra no depende de enviar correo en tiempo de respuesta HTTP.
- Cada evento relevante genera notificación trazable en base de datos.
- El usuario puede ver historial y estado de lectura.
- La solución permite sumar canales sin tocar la lógica central de negocio.

## Orden práctico de trabajo recomendado en este repositorio
1. Crear app dedicada: notifications.
2. Implementar modelo y migraciones.
3. Integrar Celery en configuración de proyecto.
4. Disparar evento ORDER_CONFIRMED desde flujo de orders.
5. Añadir vista y endpoint de notificaciones del usuario.
6. Conectar campana en base template.
7. Agregar eventos de envío, entrega y cancelación.

## Nota final
Esta estrategia mantiene compatibilidad con el estilo actual del proyecto (Django con templates) y permite crecer de manera progresiva hacia una experiencia de notificaciones comparable con ecommerces grandes.

----- ----- -------------------------------------------------------------

Primera Fase:

## Primera Fase (MVP implementable)

Objetivo de la fase:
- Tener notificaciones internas funcionando para ORDER_CONFIRMED.
- Envia9r confirmación por email de forma asíncrona.
- Mostrar notificaciones al usuario en interfaz web.

### 1) Crear la app notifications

Que se configura:
- Nueva app Django dedicada para encapsular lógica de notificaciones.

Por que se configura:
- Evita mezclar responsabilidades en orders/users.
- Facilita escalar a nuevos eventos sin deuda técnica.

Pasos:
1. Crear app notifications.
2. Agregar notifications en INSTALLED_APPS.
3. Definir estructura base: models.py, services.py, tasks.py, urls.py, views.py.

Estructura sugerida de archivos (MVP):
- notifications/
- notifications/__init__.py: inicialización de app.
- notifications/apps.py: configuración Django de la app.
- notifications/models.py: modelos Notification (y opcionalmente NotificationPreference).
- notifications/admin.py: listados, filtros y búsqueda para revisión rápida en admin.
- notifications/services.py: capa de dominio para crear eventos y deduplicar.
- notifications/tasks.py: tareas Celery para canales asíncronos (email).
- notifications/views.py: listado de notificaciones y endpoint de marcar leídas.
- notifications/urls.py: rutas de la app.
- notifications/selectors.py (opcional): consultas de lectura (no leídas, recientes, por tipo).
- notifications/tests.py: pruebas unitarias de deduplicación, permisos y flujos.
- notifications/migrations/: historial de migraciones.

Plantillas sugeridas:
- templates/notifications/list.html: bandeja de notificaciones del usuario.
- templates/notifications/partials/item.html: item reutilizable de notificación.
- templates/email/notifications/order_confirmed.html: plantilla email por evento.

Convención recomendada para mantener orden:
- models.py solo define datos y reglas de integridad.
- services.py aplica reglas de negocio (crear notificación, dedupe_key, disparar tarea).
- tasks.py solo canaliza envío asíncrono y actualización de estados.
- views.py evita lógica pesada; solo orquesta request/response.

Rutas sugeridas (MVP):
- GET /notifications/: lista del usuario autenticado.
- GET /notifications/unread-count/: contador para campana (JSON).
- POST /notifications/<id>/read/: marcar una notificación como leída.
- POST /notifications/read-all/: marcar todas como leídas.

Idea de implementación incremental de archivos:
1. Crear app + models.py + admin.py.
2. Crear services.py y conectar desde flujo de orders.
3. Crear tasks.py para email asíncrono.
4. Crear views.py + urls.py + templates.
5. Agregar tests.py para cerrar MVP con confianza.

Validacion:
- Django levanta sin errores al registrar la app.
- Se puede importar notifications en shell sin fallos.

Resultado esperado:
- Módulo aislado y listo para crecimiento.

### 2) Modelo Notification y migraciones

Que se configura:
- Entidad Notification para inbox interno con trazabilidad.

Por que se configura:
- Es la fuente de verdad para mostrar historial al usuario.
- Permite estado de lectura y reintentos por canal.

Campos minimos recomendados en MVP:
- user (FK a usuario)
- event_type (char)
- title (char)
- body (text)
- payload_json (JSONField)
- status (pending/sent/failed/read)
- channel (in_app/email)
- dedupe_key (unique)
- read_at (nullable)
- sent_at (nullable)
- created_at / updated_at

Diseño sugerido del modelo (más específico):

Enumeraciones recomendadas:
- event_type:
   - ORDER_CONFIRMED
   - ORDER_SHIPPED
   - ORDER_OUT_FOR_DELIVERY
   - ORDER_DELIVERED
   - ORDER_CANCELLED
- channel:
   - in_app
   - email
- status:
   - pending
   - sent
   - failed
   - read

Campos con tipo sugerido:
- user: ForeignKey(settings.AUTH_USER_MODEL, on_delete=CASCADE, related_name='notifications')
- event_type: CharField(max_length=50, db_index=True)
- channel: CharField(max_length=20, db_index=True)
- status: CharField(max_length=20, db_index=True, default='pending')
- title: CharField(max_length=160)
- body: TextField()
- payload_json: JSONField(default=dict, blank=True)
- dedupe_key: CharField(max_length=200, unique=True)
- read_at: DateTimeField(null=True, blank=True)
- sent_at: DateTimeField(null=True, blank=True)
- created_at: DateTimeField(auto_now_add=True, db_index=True)
- updated_at: DateTimeField(auto_now=True)

Indices y constraints recomendados:
- índice compuesto (user, status, created_at) para bandeja y no leídas.
- índice compuesto (user, event_type, created_at) para filtros por tipo.
- unique en dedupe_key para idempotencia.
- constraint opcional: read_at no nulo solo cuando status = read.

Formato sugerido para dedupe_key:
- <event_type>:<user_id>:<order_id>:<status_version>
- ejemplo conceptual:
   ORDER_SHIPPED:15:2301:v1

Nota práctica para dedupe_key:
- En ORDER_CONFIRMED puede usar order_id fijo (una sola vez por orden).
- En eventos de estado cambiante, incluir versión o timestamp lógico para permitir eventos distintos sin duplicar el mismo.

Modelo opcional útil desde el inicio (si quieres personalización):
- NotificationPreference
   - user
   - event_type
   - allow_in_app (bool)
   - allow_email (bool)

Ventaja:
- te prepara para producto reusable sin rehacer el núcleo.

Comportamientos recomendados en el modelo:
- método mark_as_read(): setea status=read y read_at.
- propiedad is_unread: status != read.
- Meta ordering: created_at descendente.

Pasos:
1. Definir modelo en notifications/models.py.
2. Crear migration.
3. Aplicar migration.
4. Registrar modelo en admin para inspección rápida.

Sugerencia para admin.py:
- list_display: user, event_type, channel, status, created_at, sent_at, read_at.
- list_filter: event_type, channel, status, created_at.
- search_fields: user__username, title, body, dedupe_key.
- readonly_fields: created_at, updated_at.

Validacion:
- Tabla creada correctamente en base de datos.
- Se pueden crear/consultar notificaciones en admin.

Resultado esperado:
- Inbox persistente listo para alimentar UI y auditoría.

### 3) Configurar Celery + Redis

Que se configura:
- Procesamiento asíncrono de tareas de notificación.

Por que se configura:
- Evita que el request web espere el envío de correos.
- Permite reintentos y tolerancia a fallos.

Pasos:
1. Instalar dependencias: celery, redis.
2. Configurar celery.py a nivel proyecto.
3. Importar app Celery en ecom/__init__.py.
4. Definir broker y backend con variables de entorno.
5. Levantar worker local para pruebas.

Configuracion minima sugerida:
- CELERY_BROKER_URL=redis://localhost:6379/0
- CELERY_RESULT_BACKEND=redis://localhost:6379/1
- CELERY_TASK_ACKS_LATE=True
- CELERY_TASK_DEFAULT_RETRY_DELAY=30

Validacion:
- Worker inicia y detecta tareas registradas.
- Tarea de prueba ejecuta y retorna OK.

Resultado esperado:
- Pipeline asíncrono operativo para enviar notificaciones.

### 4) Servicio de dominio para crear notificaciones

Que se configura:
- Capa service en notifications/services.py.

Por que se configura:
- Centraliza reglas (deduplicación, formato, estado inicial).
- Evita lógica duplicada en views y signals.

Pasos:
1. Implementar función create_notification_event(...).
2. Generar dedupe_key consistente por evento.
3. Guardar notificación con status pending.
4. Encolar tarea Celery de envío de email cuando aplique.

Validacion:
- Repetir el mismo evento no duplica registros.
- Eventos distintos generan registros distintos.

Resultado esperado:
- Punto único y mantenible para emitir notificaciones.

### 5) Integrar evento ORDER_CONFIRMED desde orders

Que se configura:
- Disparo de evento cuando una compra queda confirmada.

Por que se configura:
- Es el evento más crítico y el primer caso de uso real.

Pasos:
1. Ubicar flujo de confirmación en orders (view/service).
2. Envolver la persistencia de orden en transacción.
3. Disparar create_notification_event dentro de transaction.on_commit.

Validacion:
- Si la transacción falla, no se crea notificación.
- Si confirma compra, se crea notificación y se encola email.

Resultado esperado:
- Consistencia entre estado de orden y notificación emitida.

### 6) Tarea Celery para email transaccional

Que se configura:
- notifications/tasks.py con envío de correo y manejo de error.

Por que se configura:
- Separa envío de canal email del ciclo HTTP.
- Permite reintentos automáticos sin afectar UX.

Pasos:
1. Crear tarea send_order_confirmed_email(notification_id).
2. Cargar plantilla de email por evento.
3. Enviar correo con timeout razonable.
4. En success: actualizar sent_at/status=sent.
5. En error: status=failed y retry con backoff.

Validacion:
- Correo llega cuando hay SMTP válido.
- Con fallo SMTP, el sistema registra error y reintenta.

Resultado esperado:
- Canal email confiable para eventos críticos.

### 7) Endpoints y UI de notificaciones

Que se configura:
- Vista de listado de notificaciones del usuario.
- Endpoint para marcar como leída.
- Integración de contador en campana de base template.

Por que se configura:
- Da visibilidad inmediata al usuario de su estado de compra.

Pasos:
1. Crear endpoint GET de notificaciones (HTML o JSON).
2. Crear endpoint POST mark-as-read.
3. Mostrar badge de no leídas en campana.
4. Mostrar lista básica (titulo, fecha, estado, acción).

Validacion:
- Badge incrementa al crear notificación.
- Badge disminuye al marcar como leída.
- Usuario solo ve sus propias notificaciones.

Resultado esperado:
- Inbox funcional en interfaz y usable en flujo diario.

### 8) Checklist de cierre de Primera Fase

Checklist:
- App notifications creada y registrada.
- Modelo Notification migrado.
- Celery + Redis funcionando en local.
- Evento ORDER_CONFIRMED disparando notificación.
- Email asíncrono operativo con manejo de errores.
- Campana con contador y listado básico funcionando.

Criterio de terminado:
- Confirmar compra genera notificación interna y email sin bloquear request principal.

## Segunda Fase (eventos de envío, entrega y cancelación)

Objetivo:
- Extender el mismo patrón a estados logísticos del pedido.

### 1) Normalizar estados de order

Que se configura:
- Catálogo de estados de orden y transición permitida.

Por que se configura:
- Evita estados inválidos y notificaciones incoherentes.

Pasos:
1. Definir enum de estados en orders.
2. Validar transiciones en un servicio.
3. Mapear transición -> evento de notificación.

### 2) Disparo de eventos por cada cambio

Eventos a cubrir:
- ORDER_SHIPPED
- ORDER_OUT_FOR_DELIVERY
- ORDER_DELIVERED
- ORDER_CANCELLED

Pasos:
1. Disparar evento on_commit en cada transición válida.
2. Reusar create_notification_event para todos.
3. Actualizar plantillas de mensaje por evento.

### 3) Filtros y experiencia de usuario

Que se configura:
- Filtro por no leídas/tipo/fecha.

Resultado esperado:
- Usuario identifica rápido el estado actual de sus pedidos.

Checklist de cierre de Segunda Fase:
- Todos los estados clave generan notificación.
- Vista con filtros básicos disponible.
- Sin duplicados ante reintentos.

## Tercera Fase (tiempo real con Channels)

Objetivo:
- Evitar polling y actualizar campana en tiempo real.

### 1) Configuración ASGI y Channels

Que se configura:
- channels y channels-redis.
- ASGI routing para websocket de notificaciones.

Pasos:
1. Configurar ASGI_APPLICATION.
2. Definir CHANNEL_LAYERS con Redis.
3. Crear consumer por usuario autenticado.

### 2) Publicación de eventos a websocket

Pasos:
1. Tras crear Notification, emitir mensaje a grupo de usuario.
2. En frontend, escuchar evento y actualizar badge/lista.

Validacion:
- Con sesión abierta en dos pestañas, ambas reciben actualización.

Checklist de cierre de Tercera Fase:
- Badge en vivo sin refrescar.
- Marca de leído sincronizada en tiempo real.

## Cuarta Fase (producto reusable)

Objetivo:
- Convertir el módulo en plantilla adaptable para futuros clientes.

### 1) Configuración por cliente/proyecto

Que se configura:
- Plantillas por marca.
- Catálogo de eventos activables.
- Preferencias por canal por usuario.

### 2) Endurecimiento funcional (sin exigir producción completa)

Que se mejora:
- métricas básicas de envío y lectura
- panel admin para reintentos manuales
- export simple de historial

Resultado esperado:
- Módulo demostrable, vendible como base y personalizable por necesidad.

## Guia de implementación semanal sugerida (práctica)

Semana 1:
1. Crear app notifications y modelo.
2. Configurar Celery + Redis.
3. Integrar ORDER_CONFIRMED.
4. Mostrar campana con contador y listado.

Semana 2:
1. Agregar eventos de envío, entrega y cancelación.
2. Implementar filtros y marcar leídas.
3. Mejorar plantillas de mensajes y emails.

Semana 3:
1. Integrar Channels para tiempo real (opcional).
2. Preparar módulo como plantilla reusable.

## Definición de éxito para proyecto de práctica

Se considera exitoso si:
- Se demuestra flujo completo de compra -> notificación -> lectura.
- Hay trazabilidad en base de datos de los eventos principales.
- El código queda modular y fácil de adaptar a futuros casos.

## Código base sugerido para implementar el plan

Nota:
- Los siguientes fragmentos son base MVP para adaptar a tu estilo actual.
- La idea es acelerar implementación sin sobreingeniería.

### A) Código sugerido para notifications/models.py

Objetivo:
- Definir Notification con idempotencia, lectura y trazabilidad.

Ejemplo:

   from django.conf import settings
   from django.db import models
   from django.utils import timezone


   class Notification(models.Model):
      class EventType(models.TextChoices):
         ORDER_CONFIRMED = 'ORDER_CONFIRMED', 'Orden Confirmada'
         ORDER_SHIPPED = 'ORDER_SHIPPED', 'Orden Enviada'
         ORDER_OUT_FOR_DELIVERY = 'ORDER_OUT_FOR_DELIVERY', 'Orden en camino'
         ORDER_DELIVERED = 'ORDER_DELIVERED', 'Orden Entregada'
         ORDER_CANCELLED = 'ORDER_CANCELLED', 'Orden Cancelada'

      class Channel(models.TextChoices):
         IN_APP = 'IN_APP', 'In app'
         EMAIL = 'EMAIL', 'Email'

      class Status(models.TextChoices):
         PENDING = 'PENDING', 'Pendiente'
         SENT = 'SENT', 'Enviada'
         FAILED = 'FAILED', 'Fallida'
         READ = 'READ', 'Leida'

      user = models.ForeignKey(
         settings.AUTH_USER_MODEL,
         on_delete=models.CASCADE,
         related_name='notifications',
         db_index=True,
      )
      event_type = models.CharField(max_length=50, choices=EventType.choices, db_index=True)
      channel = models.CharField(max_length=20, choices=Channel.choices, default=Channel.IN_APP, db_index=True)
      status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING, db_index=True)
      title = models.CharField(max_length=160)
      body = models.TextField()
      payload_json = models.JSONField(default=dict, blank=True)
      dedupe_key = models.CharField(max_length=200, unique=True)
      read_at = models.DateTimeField(null=True, blank=True)
      sent_at = models.DateTimeField(null=True, blank=True)
      created_at = models.DateTimeField(auto_now_add=True, db_index=True)
      updated_at = models.DateTimeField(auto_now=True)

      class Meta:
         ordering = ['-created_at']
         indexes = [
            models.Index(fields=['user', 'status', '-created_at']),
            models.Index(fields=['user', 'event_type', '-created_at']),
         ]

      def mark_as_read(self):
         if self.status != self.Status.READ:
            self.status = self.Status.READ
            self.read_at = timezone.now()
            self.save(update_fields=['status', 'read_at', 'updated_at'])

### B) Código sugerido para notifications/services.py

Objetivo:
- Centralizar creación de notificaciones, deduplicación y encolado.

Ejemplo:

   import logging
   from django.db import IntegrityError, transaction
   from django.utils import timezone
   from notifications.models import Notification
   from notifications.tasks import send_notification_email_task

   logger = logging.getLogger('notifications')


   def build_dedupe_key(event_type, user_id, order_id, version='v1'):
      return f'{event_type}:{user_id}:{order_id}:{version}'


   def build_event_content(event_type, order):
      if event_type == Notification.EventType.ORDER_CONFIRMED:
         return (
            'Compra confirmada',
            f'Tu orden #{order.id} fue confirmada correctamente.'
         )
      if event_type == Notification.EventType.ORDER_CANCELLED:
         return (
            'Compra cancelada',
            f'La orden #{order.id} fue cancelada.'
         )
      return (
         'Actualizacion de orden',
         f'Hubo un cambio en la orden #{order.id}.'
      )


   def create_notification_event(*, user, event_type, order, channel=Notification.Channel.IN_APP, send_email=False):
      dedupe_key = build_dedupe_key(event_type, user.id, order.id)
      title, body = build_event_content(event_type, order)

      try:
         notification, created = Notification.objects.get_or_create(
            dedupe_key=dedupe_key,
            defaults={
               'user': user,
               'event_type': event_type,
               'channel': channel,
               'status': Notification.Status.PENDING,
               'title': title,
               'body': body,
               'payload_json': {
                  'order_id': order.id,
                  'order_status': order.status,
                  'created_at': timezone.now().isoformat(),
               },
            },
         )
      except IntegrityError:
         notification = Notification.objects.get(dedupe_key=dedupe_key)
         created = False

      if created and send_email:
         transaction.on_commit(lambda: send_notification_email_task.delay(notification.id))

      return notification, created


   def mark_notification_as_read(*, notification, user):
      if notification.user_id != user.id:
         raise PermissionError('No puedes modificar notificaciones de otro usuario.')
      notification.mark_as_read()
      return notification


   def mark_all_notifications_as_read(*, user):
      now = timezone.now()
      return Notification.objects.filter(user=user).exclude(status=Notification.Status.READ).update(
         status=Notification.Status.READ,
         read_at=now,
         updated_at=now,
      )

### C) Código sugerido para notifications/tasks.py

Objetivo:
- Ejecutar envío email fuera del request principal.

Ejemplo:

   import logging
   from celery import shared_task
   from django.core.mail import send_mail
   from django.utils import timezone
   from notifications.models import Notification

   logger = logging.getLogger('notifications')


   @shared_task(bind=True, autoretry_for=(Exception,), retry_backoff=True, retry_kwargs={'max_retries': 3})
   def send_notification_email_task(self, notification_id):
      notification = Notification.objects.select_related('user').get(id=notification_id)

      if not notification.user.email:
         logger.warning('Usuario sin email para notification_id=%s', notification_id)
         return 'skipped-no-email'

      send_mail(
         subject=notification.title,
         message=notification.body,
         from_email=None,
         recipient_list=[notification.user.email],
         fail_silently=False,
      )

      notification.status = Notification.Status.SENT
      notification.sent_at = timezone.now()
      notification.save(update_fields=['status', 'sent_at', 'updated_at'])
      return 'sent'

### D) Código sugerido para notifications/views.py

Objetivo:
- Exponer listado, contador y acciones de lectura.

Ejemplo:

   from django.contrib.auth.decorators import login_required
   from django.http import JsonResponse, HttpResponseForbidden
   from django.shortcuts import get_object_or_404, render, redirect
   from django.views.decorators.http import require_POST
   from notifications.models import Notification
   from notifications.services import mark_notification_as_read, mark_all_notifications_as_read


   @login_required
   def notification_list(request):
      notifications = Notification.objects.filter(user=request.user).order_by('-created_at')[:50]
      return render(request, 'notifications/list.html', {'notifications': notifications})


   @login_required
   def unread_count(request):
      count = Notification.objects.filter(
         user=request.user,
      ).exclude(status=Notification.Status.READ).count()
      return JsonResponse({'unread_count': count})


   @login_required
   @require_POST
   def mark_read(request, pk):
      notification = get_object_or_404(Notification, pk=pk)
      try:
         mark_notification_as_read(notification=notification, user=request.user)
      except PermissionError:
         return HttpResponseForbidden('No permitido')
      return redirect('notifications:list')


   @login_required
   @require_POST
   def mark_all_read(request):
      mark_all_notifications_as_read(user=request.user)
      return redirect('notifications:list')

### E) Código sugerido para notifications/urls.py

Ejemplo:

   from django.urls import path
   from notifications import views

   app_name = 'notifications'

   urlpatterns = [
      path('', views.notification_list, name='list'),
      path('unread-count/', views.unread_count, name='unread_count'),
      path('<int:pk>/read/', views.mark_read, name='mark_read'),
      path('read-all/', views.mark_all_read, name='mark_all_read'),
   ]

### F) Código sugerido para ecom/celery.py y settings

Objetivo:
- Registrar Celery en proyecto para tareas asíncronas.

ecom/celery.py:

   import os
   from celery import Celery

   os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ecom.settings')

   app = Celery('ecom')
   app.config_from_object('django.conf:settings', namespace='CELERY')
   app.autodiscover_tasks()

ecom/__init__.py:

   from .celery import app as celery_app

   __all__ = ('celery_app',)

settings.py (variables mínimas):

   CELERY_BROKER_URL = env('CELERY_BROKER_URL', default='redis://localhost:6379/0')
   CELERY_RESULT_BACKEND = env('CELERY_RESULT_BACKEND', default='redis://localhost:6379/1')
   CELERY_TASK_ACKS_LATE = True
   CELERY_TASK_DEFAULT_RETRY_DELAY = 30

### G) Código sugerido para integrar ORDER_CONFIRMED en orders/views.py

Objetivo:
- Disparar notificación solo cuando la transacción de pago realmente confirma.

Ejemplo conceptual dentro de _mark_order_paid_from_session:

   from notifications.models import Notification
   from notifications.services import create_notification_event
   from django.db import transaction

   ...

   if order.user_id:
      transaction.on_commit(
         lambda: create_notification_event(
            user=order.user,
            event_type=Notification.EventType.ORDER_CONFIRMED,
            order=order,
            channel=Notification.Channel.IN_APP,
            send_email=True,
         )
      )

### H) Código sugerido para campana en template base

Objetivo:
- Mostrar contador de no leídas sin romper diseño actual.

Ejemplo de script simple con polling:

   <script>
     async function refreshUnreadCount() {
      try {
        const response = await fetch('/notifications/unread-count/', {
         headers: { 'X-Requested-With': 'XMLHttpRequest' }
        });
        if (!response.ok) return;
        const data = await response.json();
        const badge = document.getElementById('notification-count');
        if (badge) badge.textContent = data.unread_count;
      } catch (error) {
        console.error('No se pudo actualizar contador de notificaciones', error);
      }
     }

     refreshUnreadCount();
     setInterval(refreshUnreadCount, 30000);
   </script>

## Checklist técnico de consistencia antes de codificar

1. Renombrar en modelo el campo chanel a channel para evitar errores futuros.
2. Agregar dedupe_key unique si aún no existe en Notification.
3. Corregir textos de choices y mantener convención única de nombres.
4. Definir logger notifications en settings para trazabilidad mínima.
5. Probar flujo completo con un pago exitoso simulado y verificar:
   - notificación creada
   - email encolado
   - contador actualizado
