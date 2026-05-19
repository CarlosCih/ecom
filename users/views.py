from django.shortcuts import render, redirect
from django.contrib.auth import login, logout
from django.views import View

from users import forms
from users.forms import CreateUserForm, LoginForm


# Create your views here.

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
                login(request, user)
                return redirect('home')
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
    logout(request)
    return redirect('login')

class ProfileView(View):
    def get(self, request):
        return render(request, 'users/profile.html')