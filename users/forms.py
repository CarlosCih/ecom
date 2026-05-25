from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib.auth.models import User
from django import forms
from users.models import *

INPUT_CLASS = (
    'w-full px-3 py-2 border border-gray-300 rounded-lg text-gray-900 text-sm '
    'placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 '
    'focus:border-transparent transition'
)

class CreateUserForm(UserCreationForm):
    username = forms.CharField(
        max_length=150,
        validators=[],
        help_text='',
        label='Nombre de usuario',
        widget=forms.TextInput(attrs={'class': INPUT_CLASS}),
    )

    class Meta:
        model = User
        fields = ['username', 'email', 'password1', 'password2']

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            field.widget.attrs.update({'class': INPUT_CLASS})

    def _post_clean(self):
        # Quita temporalmente los validadores del modelo para el campo username
        username_field = self.instance._meta.get_field('username')
        original_validators = username_field.validators
        username_field.validators = []
        try:
            super()._post_clean()
        finally:
            username_field.validators = original_validators

    def clean_username(self):
        username = self.cleaned_data.get('username')
        if not username.replace('_', '').replace(' ', '').isalnum():
            raise forms.ValidationError("El nombre de usuario solo puede contener letras, números, guiones bajos y espacios.")
        return username
    
class LoginForm(AuthenticationForm):
    username = forms.CharField(
        max_length=150,
        validators=[],
        help_text='',
        label='Nombre de usuario',
        widget=forms.TextInput(attrs={'class': INPUT_CLASS}),
    )
    class Meta:
        model = User
        fields = ['username', 'password']

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            field.widget.attrs.update({'class': INPUT_CLASS})
            
class UserUpdateForm(forms.ModelForm):
    class Meta:
        model = User
        fields = ['first_name', 'last_name', 'username', 'email']
        labels = {
            'first_name': 'Nombre',
            'last_name': 'Apellidos',
            'username': 'Nombre de usuario',
            'email': 'Correo electrónico',
        }
        widgets = {
            'first_name': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'last_name': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'username': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'email': forms.EmailInput(attrs={'class': INPUT_CLASS}),
        }

    def clean_email(self):
        email = self.cleaned_data.get('email')
        qs = User.objects.filter(email=email).exclude(pk=self.instance.pk)
        if qs.exists():
            raise forms.ValidationError('Ya existe una cuenta con este correo electrónico.')
        return email

    def clean_username(self):
        username = self.cleaned_data.get('username')
        qs = User.objects.filter(username=username).exclude(pk=self.instance.pk)
        if qs.exists():
            raise forms.ValidationError('Ese nombre de usuario ya está en uso.')
        return username

class ProfileForm(forms.ModelForm):
    fecha_nacimiento = forms.DateField(
        required=False,
        input_formats=['%Y-%m-%d'],
        widget=forms.DateInput(attrs={'class': INPUT_CLASS, 'type': 'date'}),
    )

    class Meta:
        model = Profile
        fields = ['telefono', 'fecha_nacimiento', 'curp', 'rfc', 'profile_picture']
        widgets = {
            'telefono': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'curp': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'rfc': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'profile_picture': forms.ClearableFileInput(attrs={'class': INPUT_CLASS}),
        }
        
class AddressForm(forms.ModelForm):
    class Meta:
        model = Address
        fields = ['pais', 'estado', 'ciudad', 'calle', 'codigo_postal', 'numero_exterior', 'numero_interior', 'referencias']
        widgets = {
            'pais': forms.Select(attrs={'class': INPUT_CLASS}),
            'estado': forms.Select(attrs={'class': INPUT_CLASS}),
            'ciudad': forms.Select(attrs={'class': INPUT_CLASS}),
            'calle': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'codigo_postal': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'numero_exterior': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'numero_interior': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'referencias': forms.Textarea(attrs={'class': INPUT_CLASS, 'rows': 3}),
        }

    telefono_input = forms.CharField(
        required=False,
        label='Teléfono de contacto',
        max_length=20,
        widget=forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'Ej. +52 55 1234 5678'}),
    )

    def __init__(self, *args, **kwargs):
        self._user = kwargs.pop('user', None)
        super().__init__(*args, **kwargs)
        self._profile = None
        if self._user is not None:
            self._profile = Profile.objects.filter(user=self._user).first()
            if self._profile and self._profile.telefono:
                # Ya tiene teléfono: pre-llenamos y ocultamos
                self.fields['telefono_input'].initial = self._profile.telefono
                self.fields['telefono_input'].widget = forms.HiddenInput()
            else:
                # No tiene teléfono: es requerido
                self.fields['telefono_input'].required = True

    def save(self, commit=True):
        address = super().save(commit=False)
        telefono_val = self.cleaned_data.get('telefono_input')
        if self._profile is not None:
            if telefono_val and not self._profile.telefono:
                self._profile.telefono = telefono_val
                self._profile.save(update_fields=['telefono'])
            address.telefono = self._profile
        if commit:
            address.save()
        return address

    def clean_codigo_postal(self):
        codigo_postal = self.cleaned_data.get('codigo_postal')
        if not codigo_postal.isdigit():
            raise forms.ValidationError('El código postal debe contener solo números.')
        if len(codigo_postal) < 4 or len(codigo_postal) > 10:
            raise forms.ValidationError('El código postal debe tener entre 4 y 10 dígitos.')
        return codigo_postal