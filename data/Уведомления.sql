


CREATE TABLE event.Уведомления (
    Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Текст VARCHAR (4096) NOT NULL,
    Ссылка VARCHAR (250) NULL,
    ДатаСоздания TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE event.УведомленияПользователей (
    КодУведомления INT NOT NULL REFERENCES event.Уведомления (Код),
    КодПользователя INT NOT NULL REFERENCES public.users (id),
    PRIMARY KEY (КодУведомления, КодПользователя)
);

CREATE TABLE event.ЖурналОтправки (
    КодУведомления INT NOT NULL REFERENCES event.Уведомления (Код),
    КодПользователя INT NOT NULL REFERENCES public.users (id),
    КодТипаОтправки INT NOT NULL,
    ЧислоПопыток INT NOT NULL DEFAULT (0),
    Отправленно BOOLEAN NOT NULL,

    PRIMARY KEY (КодУведомления, КодПользователя, КодТипаОтправки)
);


--
-- Для цикла отправки уведомления
--
CREATE VIEW event.ОчередьОтправки
AS
SELECT
    Уведомления.*,
    УведомленияПользователей.КодПользователя,

    users.email Почта,
    users.mail_notifications УведомлятьЧерезПочту,
    COALESCE (ЖурналОтправкиПочты.ЧислоПопыток, 0) ЧислоПопытокПочты,
    COALESCE (ЖурналОтправкиПочты.Отправленно, false) ОтправленноНаПочту,

    users.telegram_id Телеграм,
    users.telegram_notifications УведомлятьЧерезТелеграм,
    COALESCE (ЖурналОтправкиТелеграм.ЧислоПопыток, 0) ЧислоПопытокТелеграм,
    COALESCE (ЖурналОтправкиТелеграм.Отправленно, false) ОтправленноТелеграм
FROM event.Уведомления
INNER JOIN event.УведомленияПользователей ON УведомленияПользователей.КодУведомления = Уведомления.Код
INNER JOIN public.users ON users.id = УведомленияПользователей.КодПользователя
LEFT JOIN event.ЖурналОтправки ЖурналОтправкиПочты ON ЖурналОтправкиПочты.КодУведомления = Уведомления.Код
                                                  AND ЖурналОтправкиПочты.КодПользователя = users.id
                                                  AND ЖурналОтправкиПочты.КодТипаОтправки = 1
LEFT JOIN event.ЖурналОтправки ЖурналОтправкиТелеграм ON ЖурналОтправкиТелеграм.КодУведомления = Уведомления.Код
                                                     AND ЖурналОтправкиТелеграм.КодПользователя = users.id
                                                     AND ЖурналОтправкиТелеграм.КодТипаОтправки = 2
ORDER BY Уведомления.ДатаСоздания;


  


--
-- Создает новое уведомление с текстом, ссылкой веб сайта и списком получателей
--
CREATE OR REPLACE FUNCTION event.СоздатьУведомление (_Текст VARCHAR, _Ссылка VARCHAR, _Получатели INT[])
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE _КодУведомления INT;
BEGIN
	INSERT INTO event.Уведомления (Текст, Ссылка)
    VALUES (_Текст, _Ссылка)
    RETURNING Код INTO _КодУведомления;

    INSERT INTO event.УведомленияПользователей (КодУведомления, КодПользователя)
    SELECT _КодУведомления, КодПользователя
    FROM unnest(_Получатели) КодПользователя;
END
$$;


--
-- Для цикла отправки уведомлений, чтобы зафиксировать попытку отправки.
--
CREATE OR REPLACE FUNCTION event.ФиксироватьОтправку(_КодУведомления INT, _КодПользователя INT, _КодТипаОтправки INT, _Отправленно BOOLEAN)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO event.ЖурналОтправки (КодУведомления, КодПользователя, КодТипаОтправки, Отправленно)
    VALUES (_КодУведомления, _КодПользователя, _КодТипаОтправки, _Отправленно)
    ON CONFLICT (КодУведомления, КодПользователя, КодТипаОтправки) DO 
    UPDATE SET ЖурналОтправки.ЧислоПопыток = ЖурналОтправки.ЧислоПопыток + 1,
               ЖурналОтправки.Отправленно = EXCLUDED.Отправленно;
END
$$;
