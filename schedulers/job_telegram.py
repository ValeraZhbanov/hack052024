# -*- coding: cp1251 -*-


import os
import json
import requests

import config

from dbstore import DbStore


bot_token = config.telegram['token']


def processing():
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

        random_id = event['���']
        chat_id = event['��������']
        text = event['�����']
        webAppUrl = event['������']
        reply_markup = None
        sended = False

        data = {
            'chat_id': chat_id, 
            'text': text, 
            'parse_mode': 'HTML',
            'random_id': random_id,
        }

        if webAppUrl is not None:
            data['reply_markup']={"inline_keyboard":[[{'text':'������� �� ����', 'web_app':{'url':webAppUrl}}]],"one_time_keyboard":True}

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

        DbStore.execute_proc('event.�������������������', [event['���'], event['���������������'], 2, sended])


