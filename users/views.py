from django.shortcuts import render, redirect
from django.contrib.auth import login, logout
from django.views import View
from django.template.loader import render_to_string
from django.contrib.sites.shortcuts import get_current_site
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str
from django.core.mail import EmailMultiAlternatives
from users import forms
from users.forms import CreateUserForm, LoginForm
from .token import account_activation_token


# Create your views here.

def email_verification(request, uidb64, token):
    
    try:
        uid = force_str(urlsafe_base64_decode(uidb64))
        user = forms.User.objects.get(pk=uid)
    except (TypeError, ValueError, OverflowError, forms.User.DoesNotExist):
        user = None
    
    if user is not None and account_activation_token.check_token(user, token):
        user.is_active = True
        user.save()
        return redirect('email_verification_success')
    else:
        return redirect('email_verification_failed')

def email_verification_success(request):
    return render(request, 'email/verificacion/verificacion_cuenta_success.html')

def email_verification_failed(request):
    return render(request, 'email/verificacion/verificacion_cuenta_failed.html')

def email_verification_sent(request):
    return render(request, 'email/verificacion/verificacion_cuenta_sent.html')

class RegisterView(View):
    def get(self, request):
        if request.user.is_authenticated:
            return redirect('home')
        form = CreateUserForm()
        return render(request, 'users/register.html', {'form': form})
    
    def post(self, request):
        form = CreateUserForm(request.POST)
        try:
            if form.is_valid():
                user = form.save()
                # Se manejara un sistema de verificación de email
                user.is_active = False
                user.save()
                # Obtener el dominio actual para construir el enlace de verificación
                current_site = get_current_site(request)
                # Aquí se podría enviar un email de verificación al usuario
                subject = "Verificación de cuenta"
                html_message = render_to_string('email/verificacion/verificacion_cuenta.html', {
                    'user': user,
                    'domain': current_site.domain,
                    'uid': urlsafe_base64_encode(force_bytes(user.pk)),
                    'token': account_activation_token.make_token(user),
                })
                # Enviar el email al usuario como HTML
                email = EmailMultiAlternatives(
                    subject=subject,
                    body=html_message,
                    to=[user.email],
                )
                email.attach_alternative(html_message, 'text/html')
                email.send()
                return redirect('email_verification_sent')
        except Exception as e:
            form.add_error(None, "Ocurrió un error al registrar el usuario. Por favor, inténtalo de nuevo.")
        return render(request, 'users/register.html', {'form': form})

class LoginView(View):
    def get(self, request):
        if request.user.is_authenticated:
            return redirect('home')
        form = LoginForm(request)
        return render(request, 'users/login.html', {'form': form})
    
    def post(self, request):
        form = LoginForm(request, data=request.POST)
        if form.is_valid():
            login(request, form.get_user())
            return redirect('home')
        return render(request, 'users/login.html', {'form': form})

def logout_view(request):
    # Cerrar sesión del usuario
    logout(request)
    # Cerrar sesión del carrito
    if 'cart_id' in request.session:
        del request.session['cart_id']
    # Redirigir al usuario a la página de inicio de sesión después de cerrar sesión
    return redirect('login')

class ProfileView(View):
    def get(self, request):
        return render(request, 'users/perfil.html')
    def post(self, request):
        # Aquí se podrían manejar las actualizaciones del perfil del usuario
        return render(request, 'users/perfil.html')