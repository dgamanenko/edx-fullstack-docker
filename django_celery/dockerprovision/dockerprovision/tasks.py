from __future__ import absolute_import, unicode_literals
from celery import shared_task
import os
import subprocess

@shared_task
#Usage example: from dockerprovision.tasks import make; sp=make.delay(Makefile='/Users/dgamanenko/devstack/docker-fullstack/fullstack/Makefile', make_param='dev.up');
def make(Makefile='../Makefile', make_param='help'):
    
    commands = 'cd {path} && make --makefile={make} {param}'.format(
                    path=os.path.dirname(os.path.realpath(Makefile)),
                    make=Makefile,
                    param=make_param)

    process = subprocess.Popen('/bin/bash', stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    out, err = process.communicate(commands.encode('utf-8'))
    
    return out.decode('utf-8')
