from django.shortcuts import render
from django.views import View

# Create your views here.
def register(request):
    return render(request, 'users/register.html')

def login_view(request):
    return render(request, 'users/login.html')

def logout_view(request):
    return render(request, 'users/logout.html')

class ProfileView(View):
    def get(self, request):
        return render(request, 'users/profile.html')