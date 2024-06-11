# -*- coding: cp1251 -*-

import waitress
import flask
import flask_apscheduler

import os
import json
import joblib
import keras
import datetime
import pandas as pd
import numpy as np

from sklearn.preprocessing import MinMaxScaler

import config
from dbstore import DbStore


BASENAME = os.path.basename(__file__)
PATH = os.path.abspath(__file__).replace(BASENAME, "")



app = flask.Flask(__name__)
scheduler = flask_apscheduler.APScheduler()


class Model:

    def __init__(self):

        input_size = 48
        output_size = DbStore.execute_select_query_one("SELECT count(*) output_size FROM med.ТипыИсследований")['output_size']
        
        inputs = keras.layers.Input(shape=(input_size, output_size))

        hide = keras.layers.LSTM(256, return_sequences=True)(inputs)
        hide = keras.layers.LSTM(256, return_sequences=False)(hide)

        outputs = keras.layers.Dense(output_size, activation=keras.activations.sigmoid)(hide)

        model = keras.Model(inputs=inputs, outputs=outputs)

        model.load_weights(os.path.join(PATH, "AI_data", "model_by_7.h5"))

        scaler = joblib.load(os.path.join(PATH, "AI_data", "scaler7.gz"))

        self.input_size = input_size
        self.output_size = output_size
        self.model = model
        self.scaler = scaler


    def predict(self):

        def predict_next(rows, count):
            X = self.scaler.transform(rows[-self.input_size :])
            result = []

            for it in range(count):

                new_row = self.model.predict(X.reshape(1, -1, 10), verbose=0)[0]

                result.append(new_row)

                X = np.concatenate([X[1 :], [new_row]])

            if len(result) != 0:
                result = self.scaler.inverse_transform(result)
        
            return np.array(result)


        rows = DbStore.execute_select_query_all("SELECT * FROM nn.СтатистикаОбращенийДляГенерации")

        prep_rows = np.array(list(map(lambda row: row['Значения'], rows)), dtype=np.float32)

        last_date = rows[-1]['Дата']

        need_gen = int((datetime.date.today() + datetime.timedelta(days=7*5) - last_date).days / 7)

        new_rows = predict_next(prep_rows, need_gen).astype(np.int32)

        args = []

        for weak in range(new_rows.shape[0]):

            date = last_date + datetime.timedelta(days=7 * (weak + 1))

            for it in range(new_rows.shape[1]):

                type_index = it + 1
        
                args.append({
                    'Дата': str(date),
                    'КодТипа': 4,
                    'КодТипаИсследования': type_index,
                    'Значение': int(new_rows[weak, it]),             
                })

        if len(args) > 0:
            DbStore.execute_proc('nn.СтатистикаОбращенийСохранить', [json.dumps(args)])


    def fit(self):


        return



def predict():
    Model().predict()
    return



def fit():
    

    return


if __name__ == '__main__':


    scheduler.add_job(id='Прогнозирование', func=predict, trigger="cron", hour=3, minute=0)
    scheduler.add_job(id='Обучение', func=fit, trigger="cron", day_of_week='6', hour=3, minute=0)

    #scheduler.add_job(id='тест', func=predict, trigger="interval", seconds=3)

    scheduler.start()


    waitress.serve(app, **config.forecasting_service)

