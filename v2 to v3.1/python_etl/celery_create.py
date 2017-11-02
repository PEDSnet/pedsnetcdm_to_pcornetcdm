from __future__ import absolute_import

from celery import Celery

# instantiate Celery
celery = Celery(include=[
                         'demographicsETL'
                        ])

# import celery config file
celery.config_from_object('celery_config')

if __name__ == '__main__':
    celery.start()