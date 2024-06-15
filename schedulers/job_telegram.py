# -*- coding: cp1251 -*-


import os
import json
import requests

import config

from dbstore import DbStore


bot_token = config.telegram['token']


def processing():
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

        random_id = event['Код']
        chat_id = event['Телеграм']
        text = event['Текст']
        webAppUrl = event['Ссылка']
        reply_markup = None
        sended = False

        data = {
            'chat_id': chat_id, 
            'text': text, 
            'parse_mode': 'HTML',
            'random_id': random_id,
        }

        if webAppUrl is not None:
            data['reply_markup']={"inline_keyboard":[[{'text':'Перейти на сайт', 'web_app':{'url':webAppUrl}}]],"one_time_keyboard":True}

        url ="https://api.telegram.org/bot" + bot_token + "/sendMessage"

        try:
            res = requests.get(url, data=data)
            ans = res.json()
            sended = ans['ok']
            print(ans)

            if ans['error_code'] == 429:
                break
        except Exception as e:
            print(e)
            pass

        DbStore.execute_proc('event.ФиксироватьОтправку', [event['Код'], event['КодПользователя'], 2, sended])


