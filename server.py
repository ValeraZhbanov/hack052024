# -*- coding: cp1251 -*-

import waitress
import flask
import flask_apscheduler

import io
import datetime
import pandas as pd
import numpy as np

import config

from schedulers import job_mail
from schedulers import job_telegram
from schedulers import job_generatesch

from dbstore import DbStore

scheduler = flask_apscheduler.APScheduler()
app = flask.Flask(__name__)


@app.route("/report", methods=["GET"])
def get_report():
    ���� = flask.request.args.get('����')
    ���������� = flask.request.args.get('����������')
    �������������������������� = flask.request.args.get('��������������������������')

    where = []

    if ���������� is not None:
        ���� = datetime.datetime.strptime(����, "%d.%m.%Y").date()
        where.append("�������� = date_trunc('month', %(����)s)")
        where.append("���������� = %(����������)s")

    if �������������������������� is not None:
        where.append("�������������������������� = %(��������������������������)s")


    if len(where) == 0:
        return

    ���������������� = DbStore.execute_select_query_all("SELECT * FROM sch.�������������������������� WHERE " + " AND ".join(where), {
        '����': ����,
        '����������': ����������,
        '��������������������������': ��������������������������,
    })


    ���������������� = pd.DataFrame(����������������)

    def time_plus(time, timedelta):
        start = datetime.datetime(2000, 1, 1, hour=time.hour, minute=time.minute, second=time.second)
        end = start + timedelta
        return end.time()

    def timedeltetstr(delta):
        total_seconds = delta.total_seconds()
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        return f"{int(hours):02d}.{int(minutes):02d}"


    days = 0

    for it in range(����������������.shape[0]):
        days = max(days, len(����������������['������������'][0]))

    days1 = int(np.floor(31 / 2))
    days2 = int(days - days1)

    cols=['�������, ���, ��������', '�����������', '�������������� �����������', '������', '���.�', 
          '-', *[it + 1 for it in range(days1)], '����� �� 1 ���. ������', *[it + 1 + days1 for it in range(days2)], '����� �� 2 ���. ������', 
          '����� ����� �� �������', '����� ����� �� ������ �����', '����', '�������']

    rows = np.empty((����������������.shape[0] * 4, len(cols)), dtype=object)

    for it in range(����������������.shape[0]):
        target_it = it * 4

        rows[target_it : target_it + 4, 0] = ����������������['���'][it]
        rows[target_it : target_it + 4, 1] = ", ".join((map(lambda e: e['�����������']['����'] if e['�����������']['����'] is not None else e['�����������']['��������'], filter(lambda e: e['��������'], ����������������['�����������'][it]))))
        rows[target_it : target_it + 4, 2] = ", ".join((map(lambda e: e['�����������']['����'] if e['�����������']['����'] is not None else e['�����������']['��������'], filter(lambda e: not e['��������'], ����������������['�����������'][it]))))
        rows[target_it : target_it + 4, 3] = str(����������������['������'][it])
        rows[target_it : target_it + 4, 4] = ����������������['��������'][it]

        rows[target_it + 0, 5] = '�'
        rows[target_it + 1, 5] = '��'
        rows[target_it + 2, 5] = '�������'
        rows[target_it + 3, 5] = '�����.'

        shift = 6

        if not pd.isnull(����������������['����1'][it]):
            rows[target_it : target_it + 4, shift + days1] = ����������������['����1'][it].to_pytimedelta().total_seconds() / 60 / 60

        for i, val in enumerate(����������������['������������'][it]):

            if i == days1:
                shift += 1

            if val['�����'] is None:
                continue

            ����������� = datetime.datetime.strptime(val['�����']['�����������'], "%H:%M:%S").time()
            ����������������� = pd.Timedelta(val['�����']['�����������������']).to_pytimedelta()
            ������� = pd.Timedelta(val['�����']['�������']).to_pytimedelta()
            �������������� = time_plus(time_plus(�����������, �����������������), �������)

            rows[target_it + 0, shift + i] = �����������.strftime("%H:%M")
            rows[target_it + 1, shift + i] = ��������������.strftime("%H:%M")
            rows[target_it + 2, shift + i] = timedeltetstr(�������)
            rows[target_it + 3, shift + i] = timedeltetstr(�����������������)


        if not pd.isnull(����������������['����2'][it]):
            rows[target_it : target_it + 4, shift + days] = ����������������['����2'][it].to_pytimedelta().total_seconds() / 60 / 60

        if not pd.isnull(����������������['�������������������'][it]):
            rows[target_it : target_it + 4, shift + days + 1] = ����������������['�������������������'][it].to_pytimedelta().total_seconds() / 60 / 60
        if not pd.isnull(����������������['�����������������������'][it]):
            rows[target_it : target_it + 4, shift + days + 2] = ����������������['�����������������������'][it].to_pytimedelta().total_seconds() / 60 / 60

    df = pd.DataFrame(rows, columns=cols).set_index(cols)

    output_excel = io.BytesIO()
    writer = pd.ExcelWriter(output_excel, engine="xlsxwriter")

    df.to_excel(writer, sheet_name="Sheet1", merge_cells=True)
    writer.close()

    output_excel.seek(0)
    response = flask.make_response(output_excel)
    response.headers.set('Content-Type', 'application/vnd.ms-excel')
    response.headers.set('Content-Disposition', 'attachment', filename='data.xlsx')
    return response



if __name__ == '__main__':
    scheduler.init_app(app)

    scheduler.add_job(id='����������� �����', func=job_mail.processing, trigger="interval", seconds=10, max_instances=1)
    scheduler.add_job(id='����������� ��������', func=job_telegram.processing, trigger="interval", seconds=10, max_instances=1)

    scheduler.add_job(id='��������� ����������', func=job_generatesch.processing, trigger="interval", seconds=1, max_instances=32)


    scheduler.start()

    waitress.serve(app, **config.server)

