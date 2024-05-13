
import waitress
import flask

import json
import keras
import pandas as pd

import config

app = flask.Flask(__name__)


class Model:

    def __init__(self):

        pass

    def predict(self, prev):


        return

    def fit(self):


        return


@app.route("/statistic/<date>", methods=["POST"])
def statistic(date):
    

    return json.dumps({'status': 'OK'})


@app.route("/fit/<date>", methods=["GET"])
def fit(date):
    

    return json.dumps({'status': 'OK'})


if __name__ == '__main__':
    waitress.serve(app, **config.forecasting_service)

