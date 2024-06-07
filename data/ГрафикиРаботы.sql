
CREATE TABLE hr.ГрафикиРаботы (
	Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	Название VARCHAR(300),
	ДнейЦИкла INT,
	Активно boolean DEFAULT (true)
);

INSERT INTO hr.ГрафикиРаботы (Название, ДнейЦИкла)
VALUES 
('Каждые 7 дней', 7),
('Каждые 4 дня', 4),
('Каждый день', 1),



