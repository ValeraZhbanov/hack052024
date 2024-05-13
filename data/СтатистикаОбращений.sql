
CREATE TABLE nn.СтатистикаОбращений (
	Дата DATE PRIMARY KEY,
	Рентгенология INT NOT NULL DEFAULT (0),
	РадионуклиднаяДиагностика INT NOT NULL DEFAULT (0),
	УльтразвуковаяДиагностика INT NOT NULL DEFAULT (0),
	МагнитноРезонанснуаяТомография INT NOT NULL DEFAULT (0),
	МедицинскаяТермография INT NOT NULL DEFAULT (0),
	ИнтервенционнаяРадиология INT NOT NULL DEFAULT (0)
);

INSERT INTO nn.СтатистикаОбращений (
	Дата, 
	Рентгенология, 
	РадионуклиднаяДиагностика, 
	УльтразвуковаяДиагностика, 
	МагнитноРезонанснуаяТомография, 
	МедицинскаяТермография, 
	ИнтервенционнаяРадиология
)
SELECT
	(CURRENT_DATE + (-7 * (q.rw - 1) * INTERVAL'1 day'))::date,
	floor(random() * (1000-0+1) + 0)::int,
	floor(random() * (1000-0+1) + 0)::int,
	floor(random() * (1000-0+1) + 0)::int,
	floor(random() * (1000-0+1) + 0)::int,
	floor(random() * (1000-0+1) + 0)::int,
	floor(random() * (1000-0+1) + 0)::int

FROM (
SELECT ROW_NUMBER() OVER(ORDER BY 0) rw
FROM med.Модальности v1
CROSS JOIN med.Модальности v2
--CROSS JOIN med.Модальности v3
) q



