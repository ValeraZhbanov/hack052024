# -*- coding: cp1251 -*-

import flask

import os
import json
import requests

app = flask.Blueprint('schedule', __name__)


@app.route("/schedule/generate", methods=["GET"])
def schedule_generate(����������, �������������):


    return json.dumps({})


@app.route("/schedule", methods=["GET"])
def schedule(����������, �������������, ����������, ���������������):


    return json.dumps([])
