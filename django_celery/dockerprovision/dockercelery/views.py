from __future__ import unicode_literals 
from django.shortcuts import render
from django.contrib.auth.views import login
from django.contrib.auth.decorators import login_required

from dockerprovision.tasks import make as make_provision

from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt

from anyjson import serialize

@login_required
def webhook(request):
    result = make_provision(Makefile='/Users/dgamanenko/devstack/docker-fullstack/fullstack/Makefile', make_param=request.GET['make'])
    response = {'status': 'success', 'retval': result}
    return HttpResponse(serialize(response))
