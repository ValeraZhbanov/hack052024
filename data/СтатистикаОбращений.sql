

CREATE TABLE nn.ТипыСтатистики (
	Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	Название VARCHAR(300)
);

INSERT INTO nn.ТипыСтатистики (Название)
VALUES 
('Реальное'),
('Ожидаемое'),
('Реальное на неделю'),-- Дата - понедельник недели
('Ожидаемое на неделю'); -- Дата - понедельник недели


CREATE TABLE nn.СтатистикаОбращений (
	Дата DATE NOT NULL,
	КодТипа INT NOT NULL REFERENCES nn.ТипыСтатистики (Код),
	КодТипаИсследования INT NOT NULL REFERENCES med.ТипыИсследований (Код),

	Значение INT NOT NULL DEFAULT (0),

	PRIMARY KEY (Дата, КодТипа, КодТипаИсследования),

	CHECK (КодТипа IN (3, 4) AND EXTRACT (DOW FROM Дата) = 1)
);


CREATE OR REPLACE VIEW nn.СтатистикаОбращенийТаблицей
AS
SELECT 
	Грпировка.Дата, 
	Грпировка.КодТипа, 
	array_agg(COALESCE (СтатистикаОбращений.Значение, 0)::varchar) Значения
FROM (
	SELECT Дата, КодТипа
	FROM nn.СтатистикаОбращений
	GROUP BY Дата, КодТипа
) Грпировка
CROSS JOIN med.ТипыИсследований

LEFT JOIN nn.СтатистикаОбращений ON СтатистикаОбращений.Дата = Грпировка.Дата
                                AND СтатистикаОбращений.КодТипа = Грпировка.КодТипа
								AND СтатистикаОбращений.КодТипаИсследования = ТипыИсследований.Код
GROUP BY Грпировка.Дата, Грпировка.КодТипа
ORDER BY Грпировка.Дата;




CREATE OR REPLACE VIEW nn.СтатистикаОбращенийТаблицей1
AS
SELECT 
	ТекущаяДата.Дата, 
	json_agg(json_build_object('Тип', row_to_json(ТипыИсследований), 'Значение', COALESCE (
		СтатистикаОбращений1.Значение,
		СтатистикаОбращений2.Значение, 
		(СтатистикаОбращений3.Значение / 7)::int,
		(СтатистикаОбращений4.Значение / 7)::int,
		0
	)::int)) Значения

FROM (
	SELECT Дата::date Дата
	FROM generate_series(
		(CURRENT_DATE + '30 day'::interval)::date,
		(CURRENT_DATE - '69 day'::interval)::date,
		'-1 day'::interval
	) Дата
) ТекущаяДата

CROSS JOIN med.ТипыИсследований

LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений1 ON СтатистикаОбращений1.Дата = ТекущаяДата.Дата
													 AND СтатистикаОбращений1.КодТипа = 1
													 AND СтатистикаОбращений1.КодТипаИсследования = ТипыИсследований.Код

LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений2 ON СтатистикаОбращений2.Дата = ТекущаяДата.Дата
												     AND СтатистикаОбращений2.КодТипа = 2
												     AND СтатистикаОбращений2.КодТипаИсследования = ТипыИсследований.Код

LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений3 ON ТекущаяДата.Дата BETWEEN СтатистикаОбращений3.Дата AND (СтатистикаОбращений3.Дата + '6 day'::interval)
												     AND СтатистикаОбращений3.КодТипа = 3
												     AND СтатистикаОбращений3.КодТипаИсследования = ТипыИсследований.Код

LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений4 ON ТекущаяДата.Дата BETWEEN СтатистикаОбращений4.Дата AND (СтатистикаОбращений4.Дата + '6 day'::interval)
												     AND СтатистикаОбращений4.КодТипа = 4
												     AND СтатистикаОбращений4.КодТипаИсследования = ТипыИсследований.Код
GROUP BY ТекущаяДата.Дата
ORDER BY ТекущаяДата.Дата DESC;





CREATE OR REPLACE VIEW nn.СтатистикаОбращенийТаблицей7
AS
SELECT 
	ТекущаяДата.Дата, 
	json_agg(json_build_object('Тип', row_to_json(ТипыИсследований), 'Значение', COALESCE (
		СтатистикаОбращений3.Значение,
		СтатистикаОбращений4.Значение,
		СтатистикаОбращений12.Значение,
		0
	)::int)) Значения

FROM (
	SELECT Дата::date Дата
	FROM generate_series(
		((CURRENT_DATE + '30 day'::interval)::date - ((EXTRACT (DOW FROM (CURRENT_DATE + '30 day'::interval)::date) - 1)::varchar || ' day')::interval)::date, 
		(CURRENT_DATE - '120 day'::interval)::date,
		'-7 day'::interval
	) Дата
) ТекущаяДата

CROSS JOIN med.ТипыИсследований

LEFT JOIN (

	SELECT 
		(ТекущаяДата.Дата - ((EXTRACT (DOW FROM ТекущаяДата.Дата) - 1)::varchar || ' day')::interval)::date Дата,
		ТипыИсследований.Код КодТипаИсследования,
		SUM(COALESCE (
			СтатистикаОбращений1.Значение,
			СтатистикаОбращений2.Значение, 
			(СтатистикаОбращений3.Значение / 7),
			(СтатистикаОбращений4.Значение / 7)
		))::int Значение

	FROM (
		SELECT Дата
		FROM nn.СтатистикаОбращений
		WHERE КодТипа in (1, 2)
	) ТекущаяДата

	CROSS JOIN med.ТипыИсследований

	LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений1 ON СтатистикаОбращений1.Дата = ТекущаяДата.Дата
														 AND СтатистикаОбращений1.КодТипа = 1
														 AND СтатистикаОбращений1.КодТипаИсследования = ТипыИсследований.Код

	LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений2 ON СтатистикаОбращений2.Дата = ТекущаяДата.Дата
														 AND СтатистикаОбращений2.КодТипа = 2
														 AND СтатистикаОбращений2.КодТипаИсследования = ТипыИсследований.Код

	LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений3 ON ТекущаяДата.Дата BETWEEN СтатистикаОбращений3.Дата AND (СтатистикаОбращений3.Дата + '6 day'::interval)
														 AND СтатистикаОбращений3.КодТипа = 3
														 AND СтатистикаОбращений3.КодТипаИсследования = ТипыИсследований.Код

	LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений4 ON ТекущаяДата.Дата BETWEEN СтатистикаОбращений4.Дата AND (СтатистикаОбращений4.Дата + '6 day'::interval)
														 AND СтатистикаОбращений4.КодТипа = 4
														 AND СтатистикаОбращений4.КодТипаИсследования = ТипыИсследований.Код
	GROUP BY (ТекущаяДата.Дата - ((EXTRACT (DOW FROM ТекущаяДата.Дата) - 1)::varchar || ' day')::interval)::date,
	         ТипыИсследований.Код

) СтатистикаОбращений12 ON СтатистикаОбращений12.Дата = ТекущаяДата.Дата  
                       AND СтатистикаОбращений12.КодТипаИсследования = ТипыИсследований.Код


LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений3 ON СтатистикаОбращений3.Дата = ТекущаяДата.Дата
												     AND СтатистикаОбращений3.КодТипа = 3
												     AND СтатистикаОбращений3.КодТипаИсследования = ТипыИсследований.Код

LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений4 ON СтатистикаОбращений4.Дата = ТекущаяДата.Дата
												     AND СтатистикаОбращений4.КодТипа = 4
												     AND СтатистикаОбращений4.КодТипаИсследования = ТипыИсследований.Код
GROUP BY ТекущаяДата.Дата
ORDER BY ТекущаяДата.Дата;






CREATE OR REPLACE VIEW nn.СтатистикаОбращенийДляГенерации
AS
SELECT *
FROM (
	SELECT 
		ТекущаяДата.Дата, 
		array_agg(COALESCE (
			СтатистикаОбращений3.Значение,
			СтатистикаОбращений4.Значение,
			СтатистикаОбращений12.Значение,
			0
		)::int) Значения

	FROM (
		SELECT Дата::date Дата
		FROM generate_series(
			(SELECT MAX(Дата) FROM nn.СтатистикаОбращений WHERE КодТипа = 4), 
			((SELECT MAX(Дата) FROM nn.СтатистикаОбращений WHERE КодТипа = 4) - '700 day'::interval)::date,
			'-7 day'::interval
		) Дата
	) ТекущаяДата

	CROSS JOIN med.ТипыИсследований

	LEFT JOIN (

		SELECT 
			(ТекущаяДата.Дата - ((EXTRACT (DOW FROM ТекущаяДата.Дата) - 1)::varchar || ' day')::interval)::date Дата,
			ТипыИсследований.Код КодТипаИсследования,
			SUM(COALESCE (
				СтатистикаОбращений1.Значение,
				СтатистикаОбращений2.Значение, 
				(СтатистикаОбращений3.Значение / 7),
				(СтатистикаОбращений4.Значение / 7)
			))::int Значение

		FROM (
			SELECT Дата
			FROM nn.СтатистикаОбращений
			WHERE КодТипа in (1, 2)
		) ТекущаяДата

		CROSS JOIN med.ТипыИсследований

		LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений1 ON СтатистикаОбращений1.Дата = ТекущаяДата.Дата
															 AND СтатистикаОбращений1.КодТипа = 1
															 AND СтатистикаОбращений1.КодТипаИсследования = ТипыИсследований.Код

		LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений2 ON СтатистикаОбращений2.Дата = ТекущаяДата.Дата
															 AND СтатистикаОбращений2.КодТипа = 2
															 AND СтатистикаОбращений2.КодТипаИсследования = ТипыИсследований.Код

		LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений3 ON ТекущаяДата.Дата BETWEEN СтатистикаОбращений3.Дата AND (СтатистикаОбращений3.Дата + '6 day'::interval)
															 AND СтатистикаОбращений3.КодТипа = 3
															 AND СтатистикаОбращений3.КодТипаИсследования = ТипыИсследований.Код

		LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений4 ON ТекущаяДата.Дата BETWEEN СтатистикаОбращений4.Дата AND (СтатистикаОбращений4.Дата + '6 day'::interval)
															 AND СтатистикаОбращений4.КодТипа = 4
															 AND СтатистикаОбращений4.КодТипаИсследования = ТипыИсследований.Код
		GROUP BY (ТекущаяДата.Дата - ((EXTRACT (DOW FROM ТекущаяДата.Дата) - 1)::varchar || ' day')::interval)::date,
				 ТипыИсследований.Код

	) СтатистикаОбращений12 ON СтатистикаОбращений12.Дата = ТекущаяДата.Дата  
						   AND СтатистикаОбращений12.КодТипаИсследования = ТипыИсследований.Код


	LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений3 ON СтатистикаОбращений3.Дата = ТекущаяДата.Дата
														 AND СтатистикаОбращений3.КодТипа = 3
														 AND СтатистикаОбращений3.КодТипаИсследования = ТипыИсследований.Код

	LEFT JOIN nn.СтатистикаОбращений СтатистикаОбращений4 ON СтатистикаОбращений4.Дата = ТекущаяДата.Дата
														 AND СтатистикаОбращений4.КодТипа = 4
														 AND СтатистикаОбращений4.КодТипаИсследования = ТипыИсследований.Код
	GROUP BY ТекущаяДата.Дата
	ORDER BY ТекущаяДата.Дата DESC
	LIMIT 100
) q
ORDER BY Дата;





CREATE OR REPLACE FUNCTION nn.СтатистикаОбращенийSet (
	_Дата DATE,
	_КодТипа INT,
	_КодТипаИсследования INT,
	_Значение INT
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO nn.СтатистикаОбращений (Дата, КодТипа, КодТипаИсследования, Значение)
	VALUES (_Дата, _КодТипа, _КодТипаИсследования, _Значение)
    ON CONFLICT (Дата, КодТипа, КодТипаИсследования) DO 
    UPDATE SET Значение = EXCLUDED.Значение;
END
$$;


CREATE OR REPLACE FUNCTION nn.СтатистикаОбращенийСохранить (
	_Данные JSON -- массив объектов по аналогии с параметрами nn.СтатистикаОбращенийSet
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO nn.СтатистикаОбращений (Дата, КодТипа, КодТипаИсследования, Значение)
	SELECT Дата, КодТипа, КодТипаИсследования, Значение
	FROM json_array_elements(_Данные) t (col),
	     json_to_record(t.col) x(Дата DATE, КодТипа INT, КодТипаИсследования INT, Значение INT)
    ON CONFLICT (Дата, КодТипа, КодТипаИсследования) DO 
    UPDATE SET Значение = EXCLUDED.Значение;
END
$$;


