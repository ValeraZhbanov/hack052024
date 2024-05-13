
CREATE TABLE med.КатегорииМетодик (
	Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	Название VARCHAR(100) UNIQUE,
    Активно boolean DEFAULT (true)
)

INSERT INTO med.КатегорииМетодик(Название)
VALUES ('КТ одной анатомической области у взрослых и у детей (без контрастирования)'),
       ('МРТ одной анатомической области у взрослых и у детей (без контрастирования)'),
       ('КТ одной анатомической области у взрослых и у детей с внутривенным контрастированием'),
       ('МРТ одной анатомической области у взрослых и у детей с внутривенным контрастированием')


