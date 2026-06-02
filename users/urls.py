from django.urls import path
from . import views

urlpatterns = [
    # User authentication
    path('register/', views.RegisterView.as_view(), name='register'),
    path('login/', views.LoginView.as_view(), name='login'),
    path('logout/', views.logout_view, name='logout'),
    
    # User profile
    path('profile/', views.ProfileView.as_view(), name='profile'),
    
    # Settings
    path('settings/', views.SettingsView.as_view(), name='settings'),
    path('settings/informacion_personal/', views.ProfileEditView.as_view(), name='edit_profile'),
    
    # Email verification
    path('email-verification/<str:uidb64>/<str:token>/', views.email_verification, name='email_verification'),
    path('email-verification/success/', views.email_verification_success, name='email_verification_success'),
    path('email-verification/failed/', views.email_verification_failed, name='email_verification_failed'),
    
    # Password reset
    path('password-recovery/', views.PasswordRecoveryView.as_view(), name='password_recovery'),
    path('password-reset-confirm/<str:uidb64>/<str:token>/', views.PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('password-reset-complete/', views.PasswordResetCompleteView.as_view(), name='password_reset_complete'),
    
    # Password change
    path('password-change/', views.PasswordChangeView.as_view(), name='password_change'),
    
    # API endpoints
    path('api/countries/', views.get_countries, name='api_countries'),
    path('api/states/', views.get_states, name='api_states'),
    path('api/cities/', views.get_cities, name='api_cities'),
    
    #direcciones
    path('settings/direcciones/', views.AddressListView.as_view(), name='address_list'),
    path('settings/direcciones/nueva/', views.AddressCreateView.as_view(), name='address_create'),
    path('settings/direcciones/<int:pk>/editar/', views.AddressUpdateView.as_view(), name='address_edit'),
    path('settings/direcciones/<int:pk>/eliminar/', views.AddressDeleteView.as_view(), name='address_delete'),
    
    # Metodos de pago
    path('settings/metodos-de-pago/', views.PaymentMethodListView.as_view(), name='payment_method_list'),
    path('settings/metodos-de-pago/nuevo/', views.PaymentMethodCreateView.as_view(), name='payment_method_create'),
    path('settings/metodos-de-pago/<int:pk>/predeterminado/', views.PaymentMethodDefaultView.as_view(), name='payment_method_default'),
    path('settings/metodos-de-pago/<int:pk>/eliminar/', views.PaymentMethodDeleteView.as_view(), name='payment_method_delete'),
]
