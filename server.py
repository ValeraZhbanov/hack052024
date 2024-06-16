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
    Дата = flask.request.args.get('Дата')
    Утверждено = flask.request.args.get('Утверждено')
    КодВерсииПроектаРасписания = flask.request.args.get('КодВерсииПроектаРасписания')

    where = []

    if Утверждено is not None:
        Дата = datetime.datetime.strptime(Дата, "%d.%m.%Y").date()
        where.append("Диапазон = date_trunc('month', %(Дата)s)")
        where.append("Утверждено = %(Утверждено)s")

    if КодВерсииПроектаРасписания is not None:
        where.append("КодВерсииПроектаРасписания = %(КодВерсииПроектаРасписания)s")


    if len(where) == 0:
        return

    ЗаписиРасписания = DbStore.execute_select_query_all("SELECT * FROM sch.РасписаниеДокторовТаблицей WHERE " + " AND ".join(where), {
        'Дата': Дата,
        'Утверждено': Утверждено,
        'КодВерсииПроектаРасписания': КодВерсииПроектаРасписания,
    })


    ЗаписиРасписания = pd.DataFrame(ЗаписиРасписания)

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

    for it in range(ЗаписиРасписания.shape[0]):
        days = max(days, len(ЗаписиРасписания['СменыНаМесяц'][0]))

    days1 = int(np.floor(31 / 2))
    days2 = int(days - days1)

    cols=['Фамилия, Имя, Отчество', 'Модальность', 'Дополнительные модальности', 'Ставка', 'Таб.№', 
          '-', *[it + 1 for it in range(days1)], 'Итого за 1 пол. месяца', *[it + 1 + days1 for it in range(days2)], 'Итого за 2 пол. месяца', 
          'Норма часов по графику', 'Норма часов за полный месяц', 'Дата', 'Подпись']

    rows = np.empty((ЗаписиРасписания.shape[0] * 4, len(cols)), dtype=object)

    for it in range(ЗаписиРасписания.shape[0]):
        target_it = it * 4

        rows[target_it : target_it + 4, 0] = ЗаписиРасписания['ФИО'][it]
        rows[target_it : target_it + 4, 1] = ", ".join((map(lambda e: e['Модальность']['Аббр'] if e['Модальность']['Аббр'] is not None else e['Модальность']['Название'], filter(lambda e: e['Основная'], ЗаписиРасписания['Модальности'][it]))))
        rows[target_it : target_it + 4, 2] = ", ".join((map(lambda e: e['Модальность']['Аббр'] if e['Модальность']['Аббр'] is not None else e['Модальность']['Название'], filter(lambda e: not e['Основная'], ЗаписиРасписания['Модальности'][it]))))
        rows[target_it : target_it + 4, 3] = str(ЗаписиРасписания['Ставка'][it])
        rows[target_it : target_it + 4, 4] = ЗаписиРасписания['ТабНомер'][it]

        rows[target_it + 0, 5] = 'с'
        rows[target_it + 1, 5] = 'до'
        rows[target_it + 2, 5] = 'перерыв'
        rows[target_it + 3, 5] = 'отраб.'

        shift = 6

        if not pd.isnull(ЗаписиРасписания['Итог1'][it]):
            rows[target_it : target_it + 4, shift + days1] = ЗаписиРасписания['Итог1'][it].to_pytimedelta().total_seconds() / 60 / 60

        for i, val in enumerate(ЗаписиРасписания['СменыНаМесяц'][it]):

            if i == days1:
                shift += 1

            if val['Смена'] is None:
                continue

            ВремяНачала = datetime.datetime.strptime(val['Смена']['ВремяНачала'], "%H:%M:%S").time()
            Продолжительность = pd.Timedelta(val['Смена']['Продолжительность']).to_pytimedelta()
            Перерыв = pd.Timedelta(val['Смена']['Перерыв']).to_pytimedelta()
            ВремяОкончания = time_plus(time_plus(ВремяНачала, Продолжительность), Перерыв)

            rows[target_it + 0, shift + i] = ВремяНачала.strftime("%H:%M")
            rows[target_it + 1, shift + i] = ВремяОкончания.strftime("%H:%M")
            rows[target_it + 2, shift + i] = timedeltetstr(Перерыв)
            rows[target_it + 3, shift + i] = timedeltetstr(Продолжительность)


        if not pd.isnull(ЗаписиРасписания['Итог2'][it]):
            rows[target_it : target_it + 4, shift + days] = ЗаписиРасписания['Итог2'][it].to_pytimedelta().total_seconds() / 60 / 60

        if not pd.isnull(ЗаписиРасписания['НормаЧасовПоГрафику'][it]):
            rows[target_it : target_it + 4, shift + days + 1] = ЗаписиРасписания['НормаЧасовПоГрафику'][it].to_pytimedelta().total_seconds() / 60 / 60
        if not pd.isnull(ЗаписиРасписания['НормаЧасовЗаПолныйМесяц'][it]):
            rows[target_it : target_it + 4, shift + days + 2] = ЗаписиРасписания['НормаЧасовЗаПолныйМесяц'][it].to_pytimedelta().total_seconds() / 60 / 60

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

    scheduler.add_job(id='Уведомление почты', func=job_mail.processing, trigger="interval", seconds=10, max_instances=1)
    scheduler.add_job(id='Уведомление телеграм', func=job_telegram.processing, trigger="interval", seconds=10, max_instances=1)

    scheduler.add_job(id='Генерация расписания', func=job_generatesch.processing, trigger="interval", seconds=1, max_instances=32)


    scheduler.start()

    waitress.serve(app, **config.server)

