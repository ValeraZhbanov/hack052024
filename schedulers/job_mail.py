# -*- coding: cp1251 -*-


import os
import json
import requests

import smtplib
import config

from dbstore import DbStore


def processing():
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
