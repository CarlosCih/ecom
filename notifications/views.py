from django.contrib.auth.decorators import login_required
from django.http import JsonResponse, HttpResponseForbidden
from django.shortcuts import get_object_or_404, render, redirect
from django.views.decorators.http import require_POST
from .models import Notification
from .services import mark_notification_as_read, mark_all_notifications_as_read

# Función para mostrar la lista de notificaciones del usuario
@login_required
def notifications_list(request):
    notifications = Notification.objects.filter(user=request.user).order_by('-created_at')[:50]
    return render(request, 'notifications/notifications_list.html', {'notifications': notifications})

# Función para marcar una notificación como leída
@login_required
def unread_count(request):
    count = Notification.objects.filter(user=request.user,).exclude(status=Notification.Status.READ).count()
    return JsonResponse({'unread_count': count})

@login_required
@require_POST
def mark_read(request, pk):
    notifications = get_object_or_404(Notification, pk=pk)
    try:
        mark_notification_as_read(notification=notifications, user=request.user)
    except PermissionError:
        return HttpResponseForbidden("No tienes permiso para marcar esta notificación como leída.")
    return redirect('notifications:list')

@login_required
@require_POST
def mark_all_read(request):
    mark_all_notifications_as_read(user=request.user)
    return redirect('notifications:list')