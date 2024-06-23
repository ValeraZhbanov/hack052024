# -*- coding: cp1251 -*-


import os
import json
import requests

import smtplib
import config

from dbstore import DbStore



class EventHrText:
    day = DbStore.execute_select_query_one("SELECT Значение#>>'{}' День FROM stg.Параметры WHERE Ключ = 'eventHrDay'")['День']

    def processing():
        DbStore.execute_select_query_all("""
            SELECT * FROM event.СоздатьУведомление(
	            (SELECT Значение#>>'{}' FROM stg.Параметры WHERE Ключ = 'eventHrText'),
	            NULL,
	            (SELECT array_agg(id) FROM public.users WHERE role_id = 4)
            )
        """)



class EventSchText:
    day = DbStore.execute_select_query_one("SELECT Значение#>>'{}' День FROM stg.Параметры WHERE Ключ = 'eventSchDay'")['День']

    def processing():
        DbStore.execute_select_query_all("""
            SELECT * FROM event.СоздатьУведомление(
	            (SELECT Значение#>>'{}' FROM stg.Параметры WHERE Ключ = 'eventSchText'),
	            NULL,
	            (SELECT array_agg(id) FROM public.users WHERE role_id = 2)
            )
        """)

