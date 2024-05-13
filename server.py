# -*- coding: cp1251 -*-

import waitress
import flask
import json
from psycopg2 import connect
import requests
from datetime import date

import config
from sql import dbstore


from controllers import dictionary
from controllers import schedule

app = flask.Flask(__name__)
app.register_blueprint(dictionary.app)
app.register_blueprint(schedule.app)

@app.route("/", methods=["GET"])
def test():
    try:
        data = dbstore.DbStore.execute_select_query_one("SELECT * FROM med.ВидыМетодик")
    except Exception as e:
        data = e
        pass

    try:
        nn = requests.get('{0}://{1}:{2}/fit/{3}'.format(config.forecasting_service['url_scheme'], config.forecasting_service['host'], config.forecasting_service['port'], 123)).json()
    except Exception as e:
        nn = str(e)
        pass

    return json.dumps({
        'text': 'Запустилось',
        'nn_data_test': nn,
        'db_data_test': data,
    })



if __name__ == '__main__':
    waitress.serve(app, **config.server)

