from django.shortcuts import render
from django.views import View
from django.shortcuts import render
from django.http import JsonResponse
from pprint import pprint
from django.core.validators import validate_email
from django.core.exceptions import ValidationError
import time
import math
from datetime import datetime
#from .models import People
import requests

# Create your views here.
class MainView(View):
    
    def get(self, request):
        context = {}
        # person = People(first_name='Start',last_name='now',email='email', cloudcheck=True)
        # person.save()

        #return render(request, 'index.html', context)
        return JsonResponse({}, status=200)
