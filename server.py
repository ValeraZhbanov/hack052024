# -*- coding: cp1251 -*-

import waitress
import flask
import flask_apscheduler

import config


from schedulers import job_mail
from schedulers import job_telegram
from schedulers import job_generatesch


scheduler = flask_apscheduler.APScheduler()
app = flask.Flask(__name__)


if __name__ == '__main__':
    scheduler.init_app(app)

    scheduler.add_job(id='Уведомление почты', func=job_mail.processing, trigger="interval", seconds=10, max_instances=1)
    scheduler.add_job(id='Уведомление телеграм', func=job_telegram.processing, trigger="interval", seconds=10, max_instances=1)

    scheduler.add_job(id='Генерация расписания', func=job_generatesch.processing, trigger="interval", seconds=1, max_instances=32)


    scheduler.start()

    waitress.serve(app, **config.server)

