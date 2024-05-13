# -*- coding: cp1251 -*-

import psycopg2
import psycopg2.extras

import config

class DbStore:
    def connect():
        return psycopg2.connect(**config.doc_schedule)


    def execute_select_query_one(query, params=None):
        with DbStore.connect() as conn, conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor) as cursor:
            cursor.execute(query, params)
            return cursor.fetchone()

    def execute_select_query_all(query, params=None):
        with DbStore.connect() as conn, conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor) as cursor:
            cursor.execute(query, params)
            return cursor.fetchall()

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
