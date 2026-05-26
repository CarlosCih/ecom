from django.http import JsonResponse
from django.shortcuts import get_object_or_404, render, redirect
from django.contrib.auth import login, logout
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views import View
from django.views.decorators.http import require_GET, require_POST
from django.template.loader import render_to_string
from django.contrib.sites.shortcuts import get_current_site
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str
from django.core.mail import EmailMultiAlternatives

from users import forms
from users.forms import CreateUserForm, LoginForm, ProfileForm, UserUpdateForm
from .models import Address, Profile
from .token import account_activation_token, password_reset_token
import logging
import requests

COUNTRIESNOW_BASE = "https://countriesnow.space/api/v0.1"

logger = logging.getLogger('users')



@require_GET
def get_countries(request):
    try:
        response = requests.get(f"{COUNTRIESNOW_BASE}/countries/iso")
        response.raise_for_status()
        data = response.json()
        countries = [item['name'] for item in data.get('data', [])]
        return JsonResponse({'countries': countries})
    except requests.RequestException as e:
        logger.error("Error al obtener países: %s", e, exc_info=True)
        return JsonResponse({'error': 'No se pudieron obtener los países'}, status=500)
    
@require_GET
def get_states(request):
    country = request.GET.get('country')
    if not country:
        return JsonResponse({'error': 'Parámetro "country" es requerido'}, status=400)
    try:
        response = requests.post(f"{COUNTRIESNOW_BASE}/countries/states", json={'country': country})
        response.raise_for_status()
        data = response.json()
        states = [item['name'] for item in data.get('data', {}).get('states', [])]
        return JsonResponse({'states': states})
    except requests.RequestException as e:
        logger.error("Error al obtener estados para país '%s': %s", country, e, exc_info=True)
        return JsonResponse({'error': 'No se pudieron obtener los estados'}, status=500)
    
@require_GET
def get_cities(request):
    country = request.GET.get('country')
    state = request.GET.get('state')
    if not country or not state:
        return JsonResponse({'error': 'Parámetros "country" y "state" son requeridos'}, status=400)
    try:
        response = requests.post(f"{COUNTRIESNOW_BASE}/countries/state/cities", json={'country': country, 'state': state})
        response.raise_for_status()
        data = response.json()
        cities = data.get('data', [])
        return JsonResponse({'cities': cities})
    except requests.RequestException as e:
        logger.error("Error al obtener ciudades para país '%s' y estado '%s': %s", country, state, e, exc_info=True)
        return JsonResponse({'error': 'No se pudieron obtener las ciudades'}, status=500)
    


def email_verification(request, uidb64, token):
    try:
        uid = force_str(urlsafe_base64_decode(uidb64))
        user = forms.User.objects.get(pk=uid)
    except (TypeError, ValueError, OverflowError, forms.User.DoesNotExist) as e:
        logger.warning("Verificación de email fallida al decodificar uid '%s': %s", uidb64, e)
        user = None

    if user is not None and account_activation_token.check_token(user, token):
        user.is_active = True
        user.save()
        return redirect('email_verification_success')
    else:
        logger.warning("Token de verificación inválido para uid '%s'", uidb64)
        return redirect('email_verification_failed')

def email_verification_success(request):
    return render(request, 'email/verificacion/verificacion_cuenta_success.html')

def email_verification_failed(request):
    return render(request, 'email/verificacion/verificacion_cuenta_failed.html')



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
            logger.error("Error al registrar usuario '%s': %s", request.POST.get('username'), e, exc_info=True)
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

class PasswordRecoveryView(View):
    def get(self, request):
        return render(request, 'users/password_recovery.html')
    
    def post(self, request):
        # Aquí se podría manejar la lógica para enviar un email de recuperación de contraseña
        return render(request, 'users/password_recovery.html')

class ProfileView(LoginRequiredMixin, View):
    login_url = 'login'

    def get(self, request):
        profile, _ = Profile.objects.get_or_create(user=request.user)
        return render(request, 'users/perfil.html', {'profile': profile})
    def post(self, request):
        # Aquí se podrían manejar las actualizaciones del perfil del usuario
        return render(request, 'users/perfil.html')
    
class ProfileEditView(LoginRequiredMixin, View):
    login_url = 'login'
    template_name = 'users/info_perfil.html'

    def get(self, request):
        profile, _ = Profile.objects.get_or_create(user=request.user)
        user_form = UserUpdateForm(instance=request.user)
        profile_form = ProfileForm(instance=profile)
        return render(request, self.template_name, {
            'profile': profile,
            'user_form': user_form,
            'profile_form': profile_form,
        })

    def post(self, request):
        profile, _ = Profile.objects.get_or_create(user=request.user)
        user_form = UserUpdateForm(request.POST, instance=request.user)
        profile_form = ProfileForm(request.POST, request.FILES, instance=profile)
        if user_form.is_valid() and profile_form.is_valid():
            user_form.save()
            profile_form.save()
            logger.info("Perfil actualizado para el usuario '%s'", request.user.username)
            return redirect('profile')
        logger.warning(
            "Formulario inválido al actualizar perfil de '%s' — user_form: %s | profile_form: %s",
            request.user.username, user_form.errors, profile_form.errors
        )
        return render(request, self.template_name, {
            'profile': profile,
            'user_form': user_form,
            'profile_form': profile_form,
        })
        
## Configuraciones
class SettingsView(LoginRequiredMixin, View):
    login_url = 'login'
    template_name = 'configuraciones/index.html'

    def get(self, request):
        return render(request, self.template_name)
    
class AddressListView(LoginRequiredMixin, View):
    login_url = 'login'
    template_name = 'configuraciones/direcciones/list.html'

    def get(self, request):
        addresses = Address.objects.filter(user=request.user)
        return render(request, self.template_name, {'addresses': addresses})
    
class AddressCreateView(LoginRequiredMixin, View):
    login_url = 'login'
    template_name = 'configuraciones/direcciones/form.html'


    def get(self, request):
        form = forms.AddressForm(user=request.user)
        return render(request, self.template_name, {'form': form})
    
    def post(self, request):
        form = forms.AddressForm(request.POST, user=request.user)
        if form.is_valid():
            address = form.save(commit=False)
            address.user = request.user
            address.save()
            logger.info("Nueva dirección creada para el usuario '%s'", request.user.username)
            return redirect('address_list')
        logger.warning("Formulario inválido al crear dirección para '%s': %s", request.user.username, form.errors)
        return render(request, self.template_name, {'form': form})
    
class AddressUpdateView(LoginRequiredMixin, View):
    login_url = 'login'
    template_name = 'configuraciones/direcciones/form.html'

    def get(self, request, pk):
        address = get_object_or_404(Address, pk=pk, user=request.user)
        form = forms.AddressForm(instance=address, user=request.user)
        return render(request, self.template_name, {'form': form})

    def post(self, request, pk):
        address = get_object_or_404(Address, pk=pk, user=request.user)
        form = forms.AddressForm(request.POST, instance=address, user=request.user)
        if form.is_valid():
            form.save()
            logger.info("Dirección actualizada para el usuario '%s'", request.user.username)
            return redirect('address_list')
        logger.warning("Formulario inválido al actualizar dirección para '%s': %s", request.user.username, form.errors)
        return render(request, self.template_name, {'form': form})

class AddressDeleteView(LoginRequiredMixin, View):
    login_url = 'login'
    template_name = 'configuraciones/direcciones/confirm_delete.html'

    def get(self, request, pk):
        address = get_object_or_404(Address, pk=pk, user=request.user)
        return render(request, self.template_name, {'address': address})

    def post(self, request, pk):
        address = get_object_or_404(Address, pk=pk, user=request.user)
        address.delete()
        logger.info("Dirección eliminada para el usuario '%s'", request.user.username)
        return redirect('address_list')

class PasswordChangeView(LoginRequiredMixin, View):
    login_url = 'login'
    template_name = 'configuraciones/cambiar_contraseña.html'
    
    def get(self, request):
        return render(request, self.template_name)
    
    def post(self, request):
        # Aquí se podría manejar la lógica para cambiar la contraseña del usuario
        return render(request, self.template_name)

    