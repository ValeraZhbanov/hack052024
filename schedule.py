# -*- coding: cp1251 -*-

import flask
import flask_apscheduler

import os
import json
import requests
import asyncio

import smtplib

from telegram import InlineKeyboardMarkup, InlineKeyboardButton, WebAppInfo
from telegram.ext import Application

import config

from dbstore import DbStore


scheduler = flask_apscheduler.APScheduler()
application = Application.builder().token(config.telegram['token']).build()


def send_mail():
    events = DbStore.execute_select_query_all("""
        SELECT ���, ���������������, �����, ������, �����
        FROM event.���������������
        WHERE ��������������������
          AND ����� IS NOT NULL
          AND ����������������� < 3
          AND NOT ������������������
          AND CURRENT_TIMESTAMP + '-01:00'::interval < ������������
        LIMIT 30;
    """)


    # SMTP server...

    pass

def send_telegram():
    events = DbStore.execute_select_query_all("""
        SELECT ���, ���������������, �����, ������, ��������
        FROM event.���������������
        WHERE �����������������������
          AND �������� IS NOT NULL
          AND �������������������� < 3
          AND NOT �������������������
          AND CURRENT_TIMESTAMP + '-01:00'::interval < ������������
        LIMIT 30;
    """)

    for event in events:

        message = event['�����']
        url = event['������']
        telegram_id = event['��������']
        sended = False

        keyboard = None
        if url is not None:
            keyboard = InlineKeyboardMarkup([[
                InlineKeyboardButton('������� �� ����', web_app=WebAppInfo(url=url))
            ]])

        try:
            asyncio.run(application.bot.send_message(telegram_id, message, reply_markup=keyboard))
            sended = True
        except:
            pass

        DbStore.execute_proc('event.�������������������', [event['���'], event['���������������'], 2, sended])


scheduler.add_job(id='����������� �����', func=send_mail, trigger="interval", seconds=3)
scheduler.add_job(id='����������� ��������', func=send_telegram, trigger="interval", seconds=3)
scheduler.start()
