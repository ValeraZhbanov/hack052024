# -*- coding: cp1251 -*-


import os
import json
import requests

import smtplib
import config

from dbstore import DbStore


def processing():
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
