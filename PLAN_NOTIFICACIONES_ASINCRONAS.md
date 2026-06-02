# Plan de notificaciones asíncronas para ecom

## Objetivo
Implementar un sistema de notificaciones estilo marketplace (Amazon/Mercado Libre) que dispare avisos automáticos por eventos del ciclo de compra:
- compra confirmada
- cambio de estado de envío
- en reparto
- entrega completada
- cancelación
- reembolso

## Stack recomendado para este proyecto
1. Celery + Redis para procesamiento asíncrono de tareas.
2. Modelo interno de notificaciones (inbox por usuario) en base de datos.
3. Email transaccional como canal inicial.
4. Django Channels + channels-redis para tiempo real en la campana (fase posterior).
5. Proveedor de email vía Anymail (SendGrid, Mailgun o Brevo) cuando se pase a producción.

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