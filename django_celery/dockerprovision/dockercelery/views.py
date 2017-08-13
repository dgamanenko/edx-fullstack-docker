from __future__ import unicode_literals 
from django.shortcuts import render
from django.contrib.auth.views import login
from django.contrib.auth.decorators import login_required

from dockerprovision.tasks import makeTask

from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt

from anyjson import serialize

from dockerprovision.tasks import makeTask

@login_required
def index(request):
	return HttpResponse('pong')

@csrf_exempt
@login_required
def webhook(request):

    retval=makeTask(Makefile='/Users/dgamanenko/devstack/docker-fullstack/fullstack/Makefile', make_param=request.GET['make']);

    if retval == 0:
    	response = {'status': 'success', 'retval': retval}
    else:
    	response = {'status': 'fail', 'retval': retval}

    return HttpResponse(serialize(response))
