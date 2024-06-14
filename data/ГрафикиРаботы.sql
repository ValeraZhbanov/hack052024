
CREATE TABLE hr.ГрафикиРаботы (
	Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	Название VARCHAR(300),
    РабочихДней INT NOT NULL DEFAULT 0,
    ВыходныхДней INT NOT NULL DEFAULT 0,
    ДнейЦикла INT NOT NULL GENERATED ALWAYS AS (РабочихДней + ВыходныхДней) STORED,
    ПоДнямНедели BOOLEAN DEFAULT (false),
);



CREATE TABLE hr.ТипыРабочихСмен (
	Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ВремяНачала TIME NOT NULL,
    Продолжительность TIME NOT NULL,
    Перерыв TIME NOT NULL,

    Ночная BOOLEAN DEFAULT (false),

    CHECK ('00:00' < Продолжительность),
    CHECK (Перерыв < Продолжительность)
);

INSERT INTO hr.ТипыРабочихСмен (ВремяНачала, Продолжительность, Перерыв, Ночная)
VALUES
('08:00'::time, '06:00'::time, '00:30'::time, false),
('08:00'::time, '07:00'::time, '00:30'::time, false),
('08:00'::time, '08:00'::time, '00:30'::time, false),
('08:00'::time, '11:00'::time, '01:00'::time, false),
('08:00'::time, '12:00'::time, '01:00'::time, false),

('09:00'::time, '06:00'::time, '00:30'::time, false),
('09:00'::time, '07:00'::time, '00:30'::time, false),
('09:00'::time, '08:00'::time, '00:30'::time, false),
('09:00'::time, '11:00'::time, '01:00'::time, false),
('09:00'::time, '12:00'::time, '01:00'::time, false),

('14:00'::time, '06:00'::time, '00:30'::time, false),
('14:00'::time, '07:00'::time, '00:30'::time, false),
('14:00'::time, '08:00'::time, '00:30'::time, false),
('14:00'::time, '12:00'::time, '01:00'::time, false),

('20:00'::time, '12:00'::time, '01:00'::time, true)



CREATE TABLE hr.РабочиеСменыДокторов (

	КодДоктора INT REFERENCES hr.Доктора (Код),

	Дата DATE DEFAULT (CURRENT_DATE),

	КодТипаРабочейСмены INT NOT NULL REFERENCES hr.ТипыРабочихСмен (Код),

	PRIMARY KEY (КодДоктора, Дата),
);


CREATE VIEW hr.РабочиеСменыДокторовПодробно
AS 
SELECT
    РабочиеСменыДокторов.*
    row_to_json(ТипыРабочихСмен) ТипРабочейСмены
FROM hr.РабочиеСменыДокторов
INNER JOIN hr.ТипыРабочихСмен ON ТипыРабочихСмен.Код = РабочиеСменыДокторов.КодТипаРабочейСмены;


CREATE OR REPLACE FUNCTION hr.ГрафикиРаботыВДатах (
    _ДатаНачала DATE,
    _ДатаОкончания DATE,
    _КодГрафикаРаботы INT
)
RETURNS SETOF DATE 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT Период.Дата
    FROM hr.ГрафикиРаботы 
    CROSS JOIN (
        SELECT ROW_NUMBER() OVER (ORDER BY Дата) - 1 Номер, Дата::date
        FROM generate_series(_ДатаНачала, _ДатаОкончания, '1 day') Дата
    ) Период
    WHERE ГрафикиРаботы.Код = _КодГрафикаРаботы
      AND ((ГрафикиРаботы.ПоДнямНедели AND EXTRACT (DOW FROM Период.Дата) BETWEEN 1 AND ГрафикиРаботы.РабочихДней)
       OR (NOT ГрафикиРаботы.ПоДнямНедели AND Период.Номер % ГрафикиРаботы.ДнейЦикла BETWEEN 0 AND (ГрафикиРаботы.РабочихДней - 1)));
END
$$;


CREATE OR REPLACE FUNCTION hr.РабочиеСменыСоздатьНаПромежуток (
    _КодДоктора INT,

    _ДатаНачала DATE,
    _ДатаОкончания DATE,
    _КодГрафикаРаботы INT,
    _КодТипаРабочейСмены INT
)
RETURNS SETOF hr.РабочиеСменыДокторовПодробно
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE 
    FROM hr.РабочиеСменыДокторов
    WHERE КодДоктора = _КодДоктора
      AND Дата BETWEEN _ДатаНачала AND _ДатаОкончания;

    INSERT INTO hr.РабочиеСменыДокторов (КодДоктора, Дата, КодТипаРабочейСмены)
    SELECT _КодДоктора, Дата, _КодТипаРабочейСмены
    FROM hr.ГрафикиРаботыВДатах (_ДатаНачала, _ДатаОкончания, _КодГрафикаРаботы) Дата;


    IF (
		EXISTS (
			SELECT *
			FROM hr.РабочиеСменыДокторов РабочиеСменыДокторов0
            INNER JOIN hr.ТипыРабочихСмен ТипыРабочихСмен0 ON ТипыРабочихСмен0.Код = РабочиеСменыДокторов0.КодТипаРабочейСмены

            INNER JOIN hr.РабочиеСменыДокторов РабочиеСменыДокторов1 ON РабочиеСменыДокторов1.КодДоктора = РабочиеСменыДокторов0.КодДоктора
                                                                    AND РабочиеСменыДокторов1.Дата = (РабочиеСменыДокторов0.Дата + '-1 day'::interval)
            INNER JOIN hr.ТипыРабочихСмен ТипыРабочихСмен1 ON ТипыРабочихСмен1.Код = РабочиеСменыДокторов1.КодТипаРабочейСмены

            INNER JOIN hr.РабочиеСменыДокторов РабочиеСменыДокторов2 ON РабочиеСменыДокторов2.КодДоктора = РабочиеСменыДокторов1.КодДоктора
                                                                    AND РабочиеСменыДокторов2.Дата = (РабочиеСменыДокторов1.Дата + '-1 day'::interval)
            INNER JOIN hr.ТипыРабочихСмен ТипыРабочихСмен2 ON ТипыРабочихСмен2.Код = РабочиеСменыДокторов2.КодТипаРабочейСмены

            WHERE РабочиеСменыДокторов0.КодДоктора = _КодДоктора
              AND ТипыРабочихСмен0.Продолжительность >= '11:00'::interval
              AND ТипыРабочихСмен1.Продолжительность >= '11:00'::interval
              AND ТипыРабочихСмен2.Продолжительность >= '11:00'::interval
		)
        OR 
		EXISTS (
			SELECT *
			FROM hr.РабочиеСменыДокторов РабочиеСменыДокторов0
            INNER JOIN hr.ТипыРабочихСмен ТипыРабочихСмен0 ON ТипыРабочихСмен0.Код = РабочиеСменыДокторов0.КодТипаРабочейСмены

            LEFT JOIN hr.РабочиеСменыДокторов РабочиеСменыДокторов1 ON РабочиеСменыДокторов1.КодДоктора = РабочиеСменыДокторов0.КодДоктора
                                                                   AND РабочиеСменыДокторов1.Дата = (РабочиеСменыДокторов0.Дата + '1 day'::interval)

            WHERE РабочиеСменыДокторов0.КодДоктора = _КодДоктора
              AND ТипыРабочихСмен0.Ночная
              AND РабочиеСменыДокторов1.КодДоктора IS NOT NULL
		)
        OR 
		EXISTS (
			SELECT 
				КодДоктора,
				EXTRACT (YEAR FROM Дата), 
				EXTRACT (WEEK FROM Дата), 
				SUM(ТипыРабочихСмен.Продолжительность) Продолжительность
			FROM hr.РабочиеСменыДокторов
            INNER JOIN hr.ТипыРабочихСмен ON ТипыРабочихСмен.Код = РабочиеСменыДокторов.КодТипаРабочейСмены
			WHERE КодДоктора = _КодДоктора
			GROUP BY 
				КодДоктора,
				EXTRACT (YEAR FROM Дата),
				EXTRACT (WEEK FROM Дата)
			HAVING SUM(ТипыРабочихСмен.Продолжительность) >= ('168:00'::interval - (SELECT Значение::varchar::interval FROM stg.Параметры WHERE Параметры.Ключ = 'MinimumRestTimePerWeek'))
        )
        OR 
		EXISTS (
			SELECT 
				КодДоктора,
				EXTRACT (YEAR FROM Дата), 
				EXTRACT (MONTH FROM Дата), 
				SUM(ТипыРабочихСмен.Продолжительность) Продолжительность
			FROM hr.РабочиеСменыДокторов
            INNER JOIN hr.ТипыРабочихСмен ON ТипыРабочихСмен.Код = РабочиеСменыДокторов.КодТипаРабочейСмены
			WHERE КодДоктора = _КодДоктора
			GROUP BY 
				КодДоктора,
				EXTRACT (YEAR FROM Дата),
				EXTRACT (MONTH FROM Дата)
			HAVING SUM(ТипыРабочихСмен.Продолжительность) >= (SELECT Значение::varchar::interval FROM stg.Параметры WHERE Параметры.Ключ = 'NumberOfWorkingHoursPerMonth')
        )
        OR 
		EXISTS (
			SELECT 
				Дата, 
                ТипыРабочихСмен.Код
			FROM hr.РабочиеСменыДокторов
            INNER JOIN hr.ТипыРабочихСмен ON ТипыРабочихСмен.Код = РабочиеСменыДокторов.КодТипаРабочейСмены
			GROUP BY 
				Дата, 
                ТипыРабочихСмен.Код
			HAVING COUNT(*) >= (SELECT Значение::varchar::int FROM stg.Параметры WHERE Параметры.Ключ = 'MaximumNumberOfDoctorsPerShift')
        )
	) THEN
		RAISE EXCEPTION 'Условия соблюдения графика не соблюдены';
	END IF;


    RETURN QUERY
    SELECT *
    FROM hr.РабочиеСменыДокторовПодробно
    WHERE КодДоктора = _КодДоктора
      AND Дата BETWEEN _ДатаНачала AND _ДатаОкончания;
END
$$;


SELECT (
    SELECT 1
    FROM hr.РабочиеСменыСоздатьНаПромежуток (
        Код, 
        '20.04.2024'::date, '20.08.2024'::date, 
        (random() * 3 + 1)::int, 
        (random() * 14 + 1)::int
    ) 
    LIMIT 1
)
FROM hr.Доктора