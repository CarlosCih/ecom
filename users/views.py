from django.http import JsonResponse
from django.shortcuts import get_object_or_404, render, redirect
from django.conf import settings
from django.contrib import messages
from django.contrib.auth import login, logout, update_session_auth_hash
from django.contrib.auth.forms import PasswordChangeForm, SetPasswordForm
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views import View
from django.views.decorators.http import require_GET, require_POST
from django.template.loader import render_to_string
from django.urls import reverse
from django.contrib.sites.shortcuts import get_current_site
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str
from django.utils.html import strip_tags
from django.core.mail import EmailMultiAlternatives
from django.db import transaction


from users import forms
from users.forms import CreateUserForm, LoginForm, ProfileForm, UserUpdateForm
from .models import Address, PaymentMethod, Profile
from .token import account_activation_token, password_reset_token
import logging
import requests
import stripe

COUNTRIESNOW_BASE = "https://countriesnow.space/api/v0.1"

logger = logging.getLogger('users')


def stripe_value(obj, key, default=None):
    if obj is None:
        return default
    if isinstance(obj, dict):
        return obj.get(key, default)
    return getattr(obj, key, default)


def get_password_reset_form(user, data=None):
    form = SetPasswordForm(user, data)
    input_class = (
        'block w-full rounded-md border border-gray-300 bg-white px-3 py-2.5 '
        'text-sm text-gray-900 shadow-sm placeholder:text-gray-400 '
        'focus:border-indigo-600 focus:outline-none focus:ring-2 focus:ring-indigo-100'
    )
    for field in form.fields.values():
        field.widget.attrs.update({'class': input_class})
    return form



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
        # Se recibe el email del formulario
        email = request.POST.get('email')
        user = forms.User.objects.filter(email__iexact=email).first()

        if user:
            # Se genera un token de recuperación de contraseña
            uid = urlsafe_base64_encode(force_bytes(user.pk))
            token = password_reset_token.make_token(user)
            reset_url = request.build_absolute_uri(
                reverse('password_reset_confirm', kwargs={'uidb64': uid, 'token': token})
            )
            current_site = get_current_site(request)
            # Se manda el email de recuperación al usuario con el token
            subject = "Recuperación de contraseña"
            html_message = render_to_string('email/recuperacion/recuperacion_contraseña.html', {
                'user': user,
                'domain': current_site.domain,
                'uid': uid,
                'token': token,
                'reset_url': reset_url,
            })
            text_message = strip_tags(html_message)
            # Enviar el email al usuario como HTML
            try:
                email_message = EmailMultiAlternatives(
                    subject=subject,
                    body=text_message,
                    to=[user.email],
                )
                email_message.attach_alternative(html_message, 'text/html')
                email_message.send()
            except Exception as e:
                logger.error("Error al enviar email de recuperación a '%s': %s", user.email, e, exc_info=True)
                return render(request, 'users/password_recovery.html', {
                    'error': 'No se pudo enviar el correo en este momento. Inténtalo de nuevo más tarde.'
                })
        else:
            logger.warning("Intento de recuperación de contraseña para email no registrado: '%s'", email)
        # 
        return render(request, 'users/password_recovery_sent.html')
    
class PasswordResetConfirmView(View):
    def get(self, request, uidb64, token):
        try:
            uid = force_str(urlsafe_base64_decode(uidb64))
            user = forms.User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, forms.User.DoesNotExist) as e:
            logger.warning("Confirmación de recuperación fallida al decodificar uid '%s': %s", uidb64, e)
            user = None

        if user is not None and password_reset_token.check_token(user, token):
            form = get_password_reset_form(user)
            return render(request, 'users/password_reset_confirm.html', {
                'validlink': True,
                'form': form,
            })
        else:
            logger.warning("Token de recuperación inválido para uid '%s'", uidb64)
            return render(request, 'users/password_reset_confirm.html', {'validlink': False})
        
    def post(self, request, uidb64, token):
        try:
            uid = force_str(urlsafe_base64_decode(uidb64))
            user = forms.User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, forms.User.DoesNotExist) as e:
            logger.warning("Confirmación de recuperación fallida al decodificar uid '%s': %s", uidb64, e)
            user = None

        if user is None or not password_reset_token.check_token(user, token):
            logger.warning("Token de recuperación inválido para uid '%s'", uidb64)
            return render(request, 'users/password_reset_confirm.html', {'validlink': False})

        form = get_password_reset_form(user, request.POST)
        if form.is_valid():
            form.save()
            logger.info("Contraseña restablecida para el usuario '%s'", user.username)
            return redirect('password_reset_complete')

        return render(request, 'users/password_reset_confirm.html', {
            'validlink': True,
            'form': form,
        })

class PasswordResetCompleteView(View):
    def get(self, request):
        return render(request, 'users/password_reset_complete.html')

class ProfileView(LoginRequiredMixin, View):
    login_url = 'login'

    def get(self, request):
        profile, _ = Profile.objects.get_or_create(user=request.user)
        addresses = Address.objects.filter(user=request.user)
        active_address = addresses.order_by('-is_default', '-id').first()
        active_payment_method = PaymentMethod.objects.filter(user=request.user).order_by('-is_default', '-id').first()
        return render(request, 'users/perfil.html', {
            'profile': profile,
            'active_address': active_address,
            'active_payment_method': active_payment_method,
            'address_count': addresses.count(),
        })
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


def get_or_create_user_profile(user):
    profile, _ = Profile.objects.get_or_create(user=user)
    return profile


def get_or_create_stripe_customer(user):
    profile = get_or_create_user_profile(user)
    if profile.stripe_customer_id:
        try:
            stripe.Customer.retrieve(profile.stripe_customer_id)
            return profile.stripe_customer_id
        except stripe.StripeError as exc:
            logger.warning("No se pudo recuperar el cliente Stripe '%s' para '%s': %s", profile.stripe_customer_id, user.username, exc)
    customer_kwargs = {'metadata': {'django_user_id': str(user.id)}}
    if user.email:
        customer_kwargs['email'] = user.email
    full_name = user.get_full_name()
    if full_name:
        customer_kwargs['name'] = full_name
    customer = stripe.Customer.create(**customer_kwargs)
    profile.stripe_customer_id = stripe_value(customer, 'id')
    profile.save(update_fields=['stripe_customer_id'])
    return profile.stripe_customer_id


def set_stripe_default_payment_method(user, stripe_payment_method_id=''):
    profile = get_or_create_user_profile(user)
    if not profile.stripe_customer_id:
        return
    stripe.Customer.modify(
        profile.stripe_customer_id,
        invoice_settings={'default_payment_method': stripe_payment_method_id or None},
    )


def build_stripe_payment_method_context(user):
    stripe.api_key = settings.STRIPE_SECRET_KEY
    setup_intent_client_secret = ''
    stripe_error_message = ''

    try:
        customer_id = get_or_create_stripe_customer(user)
        setup_intent = stripe.SetupIntent.create(
            customer=customer_id,
            payment_method_types=['card'],
            usage='off_session',
            metadata={'django_user_id': str(user.id)},
        )
        setup_intent_client_secret = setup_intent.client_secret
    except stripe.StripeError as exc:
        stripe_error_message = f'No se pudo preparar el formulario de tarjeta: {exc}'
        logger.error("Error al crear SetupIntent para '%s': %s", user.username, exc, exc_info=True)

    return {
        'stripe_public_key': settings.STRIPE_PUBLIC_KEY,
        'setup_intent_client_secret': setup_intent_client_secret,
        'stripe_error_message': stripe_error_message,
    }


class PaymentMethodListView(LoginRequiredMixin, View):
    login_url = 'login'
    template_name = 'configuraciones/metodos_pagos/metodos_de_pagos.html'

    def get(self, request):
        stripe.api_key = settings.STRIPE_SECRET_KEY
        setup_intent_client_secret = ''
        stripe_error_message = ''
        setup_intent_id = request.GET.get('setup_intent')
        redirect_status = request.GET.get('redirect_status')

        if setup_intent_id:
            try:
                setup_intent = stripe.SetupIntent.retrieve(setup_intent_id)
                payment_method_id = stripe_value(setup_intent, 'payment_method')
                setup_status = stripe_value(setup_intent, 'status')
                if redirect_status == 'succeeded' and setup_status == 'succeeded' and payment_method_id:
                    self.save_payment_method(request.user, payment_method_id)
                    messages.success(request, 'Tarjeta guardada correctamente.')
                    return redirect('payment_method_list')
                if redirect_status and redirect_status != 'succeeded':
                    messages.error(request, 'No fue posible guardar la tarjeta. Intenta nuevamente.')
            except (stripe.StripeError, ValueError) as exc:
                logger.error("Error al procesar SetupIntent para '%s': %s", request.user.username, exc, exc_info=True)
                messages.error(request, 'Ocurrió un error al validar la tarjeta con Stripe.')

        stripe_context = build_stripe_payment_method_context(request.user)

        payment_methods = PaymentMethod.objects.filter(user=request.user).order_by('-is_default', '-id')
        return render(request, self.template_name, {
            'payment_methods': payment_methods,
            'active_payment_method': payment_methods.first(),
            **stripe_context,
        })

    def save_payment_method(self, user, payment_method_id):
        customer_id = get_or_create_stripe_customer(user)
        payment_method = stripe.PaymentMethod.retrieve(payment_method_id)
        attached_customer = stripe_value(payment_method, 'customer')
        if attached_customer and attached_customer != customer_id:
            raise ValueError('El método de pago pertenece a otro cliente de Stripe.')
        if not attached_customer:
            stripe.PaymentMethod.attach(payment_method_id, customer=customer_id)
            payment_method = stripe.PaymentMethod.retrieve(payment_method_id)
        card = stripe_value(payment_method, 'card')
        if not card:
            raise ValueError('Solo se permiten tarjetas como método de pago.')
        billing_details = stripe_value(payment_method, 'billing_details')
        cardholder_name = stripe_value(billing_details, 'name') or user.get_full_name() or user.username
        is_first_method = not PaymentMethod.objects.filter(user=user).exists()

        with transaction.atomic():
            method, created = PaymentMethod.objects.update_or_create(
                user=user,
                stripe_payment_method_id=payment_method_id,
                defaults={
                    'last4': stripe_value(card, 'last4', ''),
                    'card_brand': stripe_value(card, 'brand', ''),
                    'expiration_month': stripe_value(card, 'exp_month') or 0,
                    'expiration_year': stripe_value(card, 'exp_year') or 0,
                    'cardholder_name': cardholder_name,
                    'is_default': is_first_method,
                },
            )
            if method.is_default:
                PaymentMethod.objects.filter(user=user).exclude(pk=method.pk).update(is_default=False)
                set_stripe_default_payment_method(user, method.stripe_payment_method_id)
            elif created and not PaymentMethod.objects.filter(user=user, is_default=True).exclude(pk=method.pk).exists():
                method.is_default = True
                method.save(update_fields=['is_default'])
                PaymentMethod.objects.filter(user=user).exclude(pk=method.pk).update(is_default=False)
                set_stripe_default_payment_method(user, method.stripe_payment_method_id)


class PaymentMethodCreateView(LoginRequiredMixin, View):
    login_url = 'login'
    template_name = 'configuraciones/metodos_pagos/new_metodo_pago.html'
    
    def get(self, request):
        return render(request, self.template_name, build_stripe_payment_method_context(request.user))

    def post(self, request):
        # Esta vista se mantiene para manejar la redirección después de agregar una tarjeta, pero la lógica principal se maneja en PaymentMethodListView
        return redirect('payment_method_list')

class PaymentMethodDefaultView(LoginRequiredMixin, View):
    login_url = 'login'

    def post(self, request, pk):
        stripe.api_key = settings.STRIPE_SECRET_KEY
        payment_method = get_object_or_404(PaymentMethod, pk=pk, user=request.user)
        try:
            with transaction.atomic():
                PaymentMethod.objects.filter(user=request.user).update(is_default=False)
                payment_method.is_default = True
                payment_method.save(update_fields=['is_default'])
            set_stripe_default_payment_method(request.user, payment_method.stripe_payment_method_id)
            messages.success(request, 'Método de pago actualizado como predeterminado.')
        except stripe.StripeError as exc:
            logger.error("Error al marcar método predeterminado para '%s': %s", request.user.username, exc, exc_info=True)
            messages.error(request, 'No se pudo actualizar el método predeterminado en Stripe.')
        return redirect('payment_method_list')


class PaymentMethodDeleteView(LoginRequiredMixin, View):
    login_url = 'login'

    def post(self, request, pk):
        stripe.api_key = settings.STRIPE_SECRET_KEY
        payment_method = get_object_or_404(PaymentMethod, pk=pk, user=request.user)
        method_id = payment_method.stripe_payment_method_id
        was_default = payment_method.is_default
        try:
            stripe.PaymentMethod.detach(method_id)
        except stripe.StripeError as exc:
            logger.error("Error al desasociar método '%s' para '%s': %s", method_id, request.user.username, exc, exc_info=True)
            messages.error(request, 'No se pudo eliminar la tarjeta en Stripe. Intenta de nuevo.')
            return redirect('payment_method_list')

        with transaction.atomic():
            payment_method.delete()
            next_method = PaymentMethod.objects.filter(user=request.user).order_by('-id').first()
            if next_method and (was_default or not PaymentMethod.objects.filter(user=request.user, is_default=True).exists()):
                next_method.is_default = True
                next_method.save(update_fields=['is_default'])

        try:
            next_default = PaymentMethod.objects.filter(user=request.user, is_default=True).first()
            set_stripe_default_payment_method(
                request.user,
                next_default.stripe_payment_method_id if next_default else '',
            )
        except stripe.StripeError as exc:
            logger.error("Error al sincronizar método predeterminado tras eliminar para '%s': %s", request.user.username, exc, exc_info=True)

        messages.success(request, 'Tarjeta eliminada correctamente.')
        return redirect('payment_method_list')


class PasswordChangeView(LoginRequiredMixin, View):
    login_url = 'login'
    template_name = 'configuraciones/cambiar_contraseña.html'

    def get(self, request):
        form = PasswordChangeForm(request.user)
        return render(request, self.template_name, {'form': form})
    
    def post(self, request):
        form = PasswordChangeForm(request.user, request.POST)
        if form.is_valid():
            form.save()
            update_session_auth_hash(request, form.user)
            logger.info("Contraseña cambiada para el usuario '%s'", request.user.username)
            return render(request, self.template_name, {
                'form': PasswordChangeForm(request.user),
                'success_message': 'Tu contraseña se actualizó correctamente.',
            })

        logger.warning(
            "Formulario inválido al cambiar contraseña para '%s': %s",
            request.user.username, form.errors
        )
        return render(request, self.template_name, {'form': form})

    
