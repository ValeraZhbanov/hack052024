# -*- coding: cp1251 -*-

import flask

import os
import json
import requests

app = flask.Blueprint('dictionary', __name__)


dicts = {
    'dictname': ['column1', 'column2']    
}


@app.route("/dictionary/<dict>", methods=["POST"])
def dictionary_set(dict):


    return json.dumps({})


@app.route("/dictionary/<dict>", methods=["GET"])
def dictionary_get(dict):


    return json.dumps({})


@app.route("/dictionary/<dict>", methods=["GET"])
def dictionary_select(dict):


    return json.dumps([])

