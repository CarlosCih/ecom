from django.urls import path
from . import views

urlpatterns = [
    # User authentication
    path('register/', views.RegisterView.as_view(), name='register'),
    path('login/', views.LoginView.as_view(), name='login'),
    path('logout/', views.logout_view, name='logout'),
    
    # User profile
    path('profile/', views.ProfileView.as_view(), name='profile'),
    
    # Email verification
    path('email-verification/<str:uidb64>/<str:token>/', views.email_verification, name='email_verification'),
    path('email-verification/success/', views.email_verification_success, name='email_verification_success'),
    path('email-verification/failed/', views.email_verification_failed, name='email_verification_failed'),
    path('email-verification/sent/', views.email_verification_sent, name='email_verification_sent'),
]
