CREATE SHCEME stg;


CREATE TABLE stg.ГруппыПараметров (
	Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	Название VARCHAR(300) NOT NULL UNIQUE,
);

INSERT INTO stg.Параметры (Название)
VALUES 
('Кадровая структура'),
('Модуль расписания')



CREATE TABLE stg.Параметры (
	Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	Ключ VARCHAR(50) UNIQUE,
	КодГруппы INT NULL REFERENCES stg.ГруппыПараметров (Код),
	Название VARCHAR(300) NOT NULL UNIQUE,
	Значение JSON NULL
);

INSERT INTO stg.Параметры (Ключ, КодГруппы, Название, Значение)
VALUES 
('MinimumRestTimePerWeek', 1, 'Минимальное время отдыха в неделю', to_json('48:00'::interval)),
('TheRateOfHoursFor1Bet', 1, 'Норма часов на 1 ставку', to_json('8:00'::interval)),
('TheNumberOfShiftsInTheCurrentMonth', 2, 'Число смен в текущем месяце', to_json(21)),
('NumberOfWorkingHoursPerMonth', 2, 'Число рабочих часов в месяце', to_json('168:00'::interval)),
('NumberOfWorkingHoursPerMonth', 2, 'Число рабочих часов в месяце', to_json('168:00'::interval)),
('ConditionallyMandatoryDistributionFor1RatePerWeek', 2, 'Условно-обязательно распределение на 1 ставку в неделю', to_json('32:00'::interval)),
('TheMaximumErrorOfTheClockIs1RatePerWeek', 2, 'Максимальная погрешность часов на 1 ставку в неделю', to_json('19:00'::interval)),
('MaximumNumberOfDoctorsPerShift', 2, 'Максимальное число врачей в смену', to_json(260))
ON CONFLICT (Ключ) DO NOTHING;


CREATE VIEW stg.ПараметрыПодробно
AS 
SELECT 
	Параметры.Код,
	Параметры.Ключ,
	Параметры.КодГруппы,
	ГруппыПараметров.Название Группа,
	Параметры.Название,
	Параметры.Значение,
FROM stg.Параметры
INNER JOIN stg.ГруппыПараметров ON ГруппыПараметров.Код = Параметры.КодГруппы

