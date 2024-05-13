# -*- coding: cp1251 -*-

import flask

import os
import json
import requests

app = flask.Blueprint('schedule', __name__)


@app.route("/schedule/generate", methods=["GET"])
def schedule_generate(ДатаНачала, ДатаОкончания):


    return json.dumps({})


@app.route("/schedule", methods=["GET"])
def schedule(ДатаНачала, ДатаОкончания, КодДоктора, КодОборудования):


    return json.dumps([])
