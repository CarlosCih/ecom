from django.urls import path
from . import views

app_name = 'notifications'

urlpatterns = [
    path('', views.notifications_list, name='list'),
    path('unread_count/', views.unread_count, name='unread_count'),
    path('<int:pk>/mark_read/', views.mark_read, name='mark_read'),
    path('mark_all_read/', views.mark_all_read, name='mark_all_read'),
]