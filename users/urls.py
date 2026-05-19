from django.urls import path
from . import views

urlpatterns = [
    # User authentication
    path('register/', views.RegisterView.as_view(), name='register'),
    path('login/', views.LoginView.as_view(), name='login'),
    path('logout/', views.logout_view, name='logout'),
    
    # User profile
    path('profile/', views.ProfileView.as_view(), name='profile'),
]
