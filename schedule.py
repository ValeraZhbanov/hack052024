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
        SELECT Код, КодПользователя, Текст, Ссылка, Почта
        FROM event.ОчередьОтправки
        WHERE УведомлятьЧерезПочту
          AND Почта IS NOT NULL
          AND ЧислоПопытокПочты < 3
          AND NOT ОтправленноНаПочту
          AND CURRENT_TIMESTAMP + '-01:00'::interval < ДатаСоздания
        LIMIT 30;
    """)


    # SMTP server...

    pass

def send_telegram():
    events = DbStore.execute_select_query_all("""
        SELECT Код, КодПользователя, Текст, Ссылка, Телеграм
        FROM event.ОчередьОтправки
        WHERE УведомлятьЧерезТелеграм
          AND Телеграм IS NOT NULL
          AND ЧислоПопытокТелеграм < 3
          AND NOT ОтправленноТелеграм
          AND CURRENT_TIMESTAMP + '-01:00'::interval < ДатаСоздания
        LIMIT 30;
    """)

    for event in events:

        message = event['Текст']
        url = event['Ссылка']
        telegram_id = event['Телеграм']
        sended = False

        keyboard = None
        if url is not None:
            keyboard = InlineKeyboardMarkup([[
                InlineKeyboardButton('Перейти на сайт', web_app=WebAppInfo(url=url))
            ]])

        try:
            asyncio.run(application.bot.send_message(telegram_id, message, reply_markup=keyboard))
            sended = True
        except:
            pass

        DbStore.execute_proc('event.ФиксироватьОтправку', [event['Код'], event['КодПользователя'], 2, sended])


scheduler.add_job(id='Уведомление почты', func=send_mail, trigger="interval", seconds=3)
scheduler.add_job(id='Уведомление телеграм', func=send_telegram, trigger="interval", seconds=3)
scheduler.start()
