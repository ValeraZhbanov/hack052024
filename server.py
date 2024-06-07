# -*- coding: cp1251 -*-

import waitress
import flask
import json
import requests

import config
from dbstore import DbStore


import schedule

app = flask.Flask(__name__)





if __name__ == '__main__':
    waitress.serve(app, **config.server)

