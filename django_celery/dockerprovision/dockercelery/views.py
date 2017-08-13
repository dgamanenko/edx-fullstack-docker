from __future__ import unicode_literals 
from django.shortcuts import render
from django.contrib.auth.views import login
from django.contrib.auth.decorators import login_required

from dockerprovision.tasks import makeTask

from django.http import HttpResponse, HttpResponseRedirect
from django.core.urlresolvers import reverse

from django.views.decorators.csrf import csrf_exempt

from anyjson import serialize

from dockerprovision.tasks import makeTask

import simplejson as json
from celery.result import AsyncResult

@login_required
def index(request):
	return HttpResponse('pong')

@csrf_exempt
@login_required
def webhook(request):

    retval=makeTask.delay(Makefile='/Users/dgamanenko/devstack/docker-fullstack/fullstack/Makefile', make_param=request.GET['make']);

    if retval == 0:
    	response = {'status': 'success', 'retval': retval}
    else:
    	response = {'status': 'fail', 'retval': retval}

    return HttpResponse(serialize(response))

@csrf_exempt
@login_required
def pollstate(request):
    """ A view to report the progress to the user """
    if 'job' in request.GET:
        job_id = request.GET['job']
    else:
        return HttpResponse('No job id given.')

    job = AsyncResult(job_id)
    
    data = job.result or job.state
    return HttpResponse(json.dumps(data), content_type='application/json')

@csrf_exempt
@login_required
def initwork(request):
    """ A view to start a background job and redirect to the status page """
    job = makeTask.delay(Makefile='/Users/dgamanenko/devstack/docker-fullstack/fullstack/Makefile', make_param=request.GET['make'])
    return HttpResponseRedirect(reverse('pollstate') + '?job=' + job.id)
