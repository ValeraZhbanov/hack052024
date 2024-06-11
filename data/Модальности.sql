
CREATE TABLE med.Модальности (
	Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	Название VARCHAR(300),
	Аббр VARCHAR(10) NOT NULL
);

CREATE TABLE med.ТипыИсследований (
	Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	КодМодальности INT NOT NULL REFERENCES med.Модальности (Код),
	Название VARCHAR(300),
	КоличествоУЕВОдномОписании DECIMAL (6, 2) NOT NULL DEFAULT (1.0),
	МинКолИсследованийЗаСмену DECIMAL (6, 2) NOT NULL DEFAULT (1),
	МаксКолИсследованийЗаСмену DECIMAL (6, 2) NOT NULL DEFAULT (10),
	МинКолУЕЗаСмену INT NOT NULL DEFAULT (1),
	МаксКолУЕЗаСмену INT NOT NULL DEFAULT (10),
);

INSERT INTO med.ТипыИсследований (КодМодальности, Название, Аббр)
VALUES 
(1, 'Денситометрия', 'Денс'),
(2, 'КТ', 'КТ'),
(2, 'КТ с КУ 1 зона', 'КТ1'),
(2, 'КТ с КУ 2 и более зон', 'КТ2'),
(3, 'ММГ', 'ММГ'),
(4, 'МРТ', 'МРТ'),
(4, 'МРТ с КУ 1 зона', 'МРТ1'),
(4, 'МРТ с КУ 2 и более зон', 'МРТ2'),
(5, 'РГ', 'РГ'),
(6, 'ФЛГ', 'ФЛГ')

CREATE OR REPLACE VIEW med.ТипыИсследованийПодробно
AS
SELECT
	ТипыИсследований.*,
	row_to_json(Модальности) Модальность
FROM med.ТипыИсследований
INNER JOIN med.Модальности ON Модальности.Код = ТипыИсследований.КодМодальности
