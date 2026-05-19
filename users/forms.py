from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib.auth.models import User
from django import forms

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