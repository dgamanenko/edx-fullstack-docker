from dockercelery import celery_app
from time import sleep
import os
import subprocess
from django.conf import settings

@celery_app.task()
def makeTask(Makefile=settings.EDX_DOCKER_FULLSTACK_MAKEFILE, make_param='help'):
 
    makeTask.update_state(state='PROGRESS', meta={'progress': 0})
    
    commands = 'cd {path} && make --makefile={make} {param}'.format(
                    path=os.path.dirname(os.path.realpath(Makefile)),
                    make=Makefile,
                    param=make_param)
    process = subprocess.Popen('/bin/bash', stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    out, err = process.communicate(commands.encode('utf-8'))
    retval = process.wait()
    
    return retval
 
 