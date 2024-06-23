# -*- coding: cp1251 -*-


import os
import json
import requests

import smtplib
import config

from dbstore import DbStore



class EventHrText:
    day = DbStore.execute_select_query_one("SELECT ��������#>>'{}' ���� FROM stg.��������� WHERE ���� = 'eventHrDay'")['����']

    def processing():
        DbStore.execute_select_query_all("""
            SELECT * FROM event.������������������(
	            (SELECT ��������#>>'{}' FROM stg.��������� WHERE ���� = 'eventHrText'),
	            NULL,
	            (SELECT array_agg(id) FROM public.users WHERE role_id = 4)
            )
        """)



class EventSchText:
    day = DbStore.execute_select_query_one("SELECT ��������#>>'{}' ���� FROM stg.��������� WHERE ���� = 'eventSchDay'")['����']

    def processing():
        DbStore.execute_select_query_all("""
            SELECT * FROM event.������������������(
	            (SELECT ��������#>>'{}' FROM stg.��������� WHERE ���� = 'eventSchText'),
	            NULL,
	            (SELECT array_agg(id) FROM public.users WHERE role_id = 2)
            )
        """)

