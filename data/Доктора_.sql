
CREATE TABLE hr.Доктора (
	Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	ФИО VARCHAR(300),
    Ставка DECIMAL (6, 2) NOT NULL DEFAULT (0),
    ТабНомер VARCHAR(100) NULL,

	Активно boolean DEFAULT (true)
);

CREATE TABLE hr.МодальностиДокторов (

	КодДоктора INT REFERENCES hr.Доктора (Код),
	КодМодальности INT REFERENCES med.Модальности (Код),
	Основная boolean DEFAULT (false),
	Активно boolean DEFAULT (true),

	PRIMARY KEY (КодДоктора, КодМодальности)
);

CREATE TABLE hr.НормыДокторов (

	КодДоктора INT NOT NULL REFERENCES hr.Доктора (Код) PRIMARY KEY,

    НормаЧасов INTERVAL NOT NULL,
	МинКолИсследований DECIMAL (6, 2) NOT NULL,
	МаксКолИсследований DECIMAL (6, 2) NOT NULL
);

CREATE OR REPLACE VIEW hr.НормыДокторовПодробно 
AS
SELECT 
    row_to_json(Доктора) Доктор, 
    COALESCE (НормаЧасов, Параметры.Значение::varchar::interval) НормаЧасов,
    МинКолИсследований,
    МаксКолИсследований
FROM hr.Доктора
LEFT JOIN hr.НормыДокторов ON НормыДокторов.КодДоктора = Доктора.Код,
(SELECT * FROM stg.Параметры WHERE Ключ = 'NumberOfWorkingHoursPerMonth') Параметры





CREATE OR REPLACE FUNCTION hr.ДоктораSet (
	_Код INT,
	_ФИО VARCHAR(300),
	_ТабНомер VARCHAR(100),
    _Ставка DECIMAL (6, 2),
	_Активно boolean,
    _КодОсновнойМодальности INT,
    _КодыМодальностей INT[]
)
RETURNS SETOF hr.ДоктораПодробно
LANGUAGE plpgsql
AS $$
BEGIN
    IF (_Код IS NULL) THEN
		INSERT INTO hr.Доктора (ФИО, Ставка, ТабНомер, Активно)
        VALUES (_ФИО, _Ставка, _ТабНомер, _Активно)
        RETURNING Код INTO _Код;
    ELSE
        UPDATE hr.Доктора 
        SET ФИО = COALESCE (_ФИО, ФИО),
            Ставка = COALESCE (_Ставка, Ставка),
            ТабНомер = COALESCE (_ТабНомер, ТабНомер),
            Активно = COALESCE (_Активно, Активно)
        WHERE Код = _Код;
	END IF;

    IF (_КодыМодальностей IS NOT NULL) THEN 

        UPDATE hr.МодальностиДокторов
        SET Активно = false
        WHERE КодДоктора = _Код
          AND NOT (КодМодальности = ANY (_КодыМодальностей) OR КодМодальности = _КодОсновнойМодальности);

        UPDATE hr.МодальностиДокторов
        SET Активно = (КодМодальности = _КодОсновнойМодальности)
        WHERE КодДоктора = _Код;

        INSERT INTO hr.МодальностиДокторов (КодДоктора, КодМодальности, Основная) 
        SELECT DISTINCT _Код КодДоктора, КодМодальности, КодМодальности = _КодОсновнойМодальности
        FROM unnest(_КодыМодальностей || ARRAY[_КодОсновнойМодальности]) КодМодальности
        ON CONFLICT (КодДоктора, КодМодальности) DO UPDATE SET Активно = true;
    END IF;

	RETURN QUERY
    SELECT *
    FROM hr.ДоктораПодробно
    WHERE Код = _Код;
END
$$;






CREATE TABLE hr.ТипыОтпусков (
	Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	Название VARCHAR(300)
);

INSERT INTO hr.ТипыОтпусков (Название)
VALUES ('Отпуск'), ('Отгул');



CREATE TABLE hr.ОтпускаДокторов (
	Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

	КодДоктора INT REFERENCES hr.Доктора (Код),

	ДатаНачала DATE,

	ДатаОкончания DATE,

    КодТипаОтпуска INT REFERENCES hr.ТипыОтпусков (Код),

	Активно boolean DEFAULT (true)
);

CREATE VIEW hr.ОтпускаДокторовПодробно
AS 
SELECT
    ОтпускаДокторов.*,
    row_to_json(ТипыОтпусков) ТипОтпуска
FROM hr.ОтпускаДокторов 
INNER JOIN hr.ТипыОтпусков ON ТипыОтпусков.Код = ОтпускаДокторов.КодТипаОтпуска;

INSERT INTO hr.ОтпускаДокторов (КодДоктора, ДатаНачала, ДатаОкончания, КодТипаОтпуска)
SELECT Код, ДатаНачала, ДатаНачала + Длит, КодТипа
FROM (
    SELECT 
        Доктора.Код, 
        (((random() * 20 + 10)::int::varchar) || '.0' || ((random() + 6)::int::varchar) || '.2024')::date ДатаНачала,
        ((random() * 3)::int::varchar || ' day')::interval Длит,
        (random() * 1 + 1)::int КодТипа
    FROM hr.Доктора
) q
WHERE NOT EXISTS (
    SELECT * 
    FROM hr.ОтпускаДокторов 
    WHERE ОтпускаДокторов.КодДоктора = q.Код 
      AND daterange(ОтпускаДокторов.ДатаНачала, ОтпускаДокторов.ДатаОкончания) && daterange(q.ДатаНачала, (q.ДатаНачала + q.Длит)::date)
)



CREATE OR REPLACE FUNCTION hr.ОтпускаSet (
    _Код INT,
	_КодДоктора INT,
	_ДатаНачала DATE,
	_ДатаОкончания DATE,
    _Активно BOOLEAN
)
RETURNS SETOF hr.ОтпускаДокторов
LANGUAGE plpgsql
AS $$
BEGIN
    IF (_Код IS NULL) THEN
        RETURN QUERY
        INSERT INTO hr.ОтпускаДокторов (КодДоктора, ДатаНачала, ДатаОкончания) 
        VALUES (_КодДоктора, _ДатаНачала, _ДатаОкончания)
		RETURNING *;
    ELSE
		RETURN QUERY
        UPDATE hr.ОтпускаДокторов 
        SET ДатаНачала = COALESCE (_ДатаНачала, ДатаНачала),
            ДатаОкончания = COALESCE (_ДатаОкончания, ДатаОкончания),
            Активно = COALESCE (_Активно, Активно)
        WHERE Код = _Код
		RETURNING *;
	END IF;
END
$$;



CREATE OR REPLACE VIEW hr.ДоктораПодробно
AS
SELECT
    Доктора.*,
    МодальностиДокторов.Модальности,
    ОтпускаДокторов.Отпуска

FROM hr.Доктора

LEFT JOIN (
    SELECT КодДоктора, json_agg(json_build_object('Основная', Основная, 'Модальность', row_to_json(Модальности)) ORDER BY Основная DESC) Модальности
    FROM hr.МодальностиДокторов
    INNER JOIN med.Модальности ON Модальности.Код = МодальностиДокторов.КодМодальности
	WHERE МодальностиДокторов.Активно
    GROUP BY КодДоктора
) МодальностиДокторов ON МодальностиДокторов.КодДоктора = Доктора.Код

LEFT JOIN (
    SELECT КодДоктора, json_agg(row_to_json(ОтпускаДокторовПодробно)) Отпуска
    FROM hr.ОтпускаДокторовПодробно
	WHERE Активно AND CURRENT_DATE <= ДатаОкончания
    GROUP BY КодДоктора
) ОтпускаДокторов ON ОтпускаДокторов.КодДоктора = Доктора.Код





