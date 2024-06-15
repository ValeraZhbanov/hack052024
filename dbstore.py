# -*- coding: cp1251 -*-

import psycopg2
import psycopg2.extras

import config



class DbStore:
    def connect():
        return psycopg2.connect(**config.doc_schedule)


    def execute_select_query_one(query, params=None):
        with DbStore.connect() as conn, conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cursor:
            cursor.execute(query, params)
            return cursor.fetchone()

    def execute_select_query_all(query, params=None):
        with DbStore.connect() as conn, conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cursor:
            cursor.execute(query, params)
            return cursor.fetchall()

    def execute_select_query_generator(query, params=None, batchsize=50):
        with DbStore.connect() as conn, conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cursor:
            cursor.execute(query, params)
            while True:
                batch =  cursor.fetchmany(batchsize)
                if len(batch) == 0: break
                yield batch

    def execute_update_query(query, params):
        with DbStore.connect() as conn, conn.cursor() as cursor:
            cursor.execute(query, params)
            conn.commit()
            return cursor.rowcount

    def execute_delete_query(query, params):
        DbStore.execute_update_query(query, params)

    def execute_insert_query(query, params):
        with DbStore.connect() as conn, conn.cursor() as cursor:
            cursor.execute(query, params)
            new_id = cursor.fetchone()[0]
            conn.commit()
            return new_id

    def execute_proc(func_name, params=None):
        with DbStore.connect() as conn, conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cursor:
            cursor.callproc(func_name, params)
            conn.commit()
            return cursor.fetchall()