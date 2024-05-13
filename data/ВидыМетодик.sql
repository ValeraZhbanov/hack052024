
CREATE TABLE med.ВидыМетодик (
	Код INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	Название VARCHAR(300),
	КодКатегорииМетодики INT REFERENCES med.КатегорииМетодик (Код),
	РекомендуемыйИнтервалЗаписи INT,
	Активно boolean DEFAULT (true),

	UNIQUE (Название, КодКатегорииМетодики)
);

INSERT INTO med.ВидыМетодик (Название, КодКатегорииМетодики, РекомендуемыйИнтервалЗаписи)
SELECT DISTINCT Название, КодКатегорииМетодики, Интервал
FROM (
VALUES 
(1, 'Компьютерная томография головы', 15),
(1, 'Компьютерная томография лицевого отдела черепа', 15),
(1, 'Компьютерная томография позвоночника (шейный отдел)', 15),
(1, 'Компьютерная томография позвоночника (грудной отдел)', 15),
(1, 'Компьютерная томография позвоночника (поясничный отдел)', 15),
(1, 'Компьютерная томография позвоночника (крестцовый и копчиковый отделы)', 30),
(1, 'Компьютерная томография с оценкой минеральной плотности кости (КТ-денситометрия)', 15),
(1, 'Компьютерная томография костей таза', 20),
(1, 'Компьютерная томография плечевой кости (справа или слева)', 15),
(1, 'Компьютерная томография локтевой и лучевой кости (справа или слева)', 15),
(1, 'Компьютерная томография кисти (справа или слева)', 15),
(1, 'Компьютерная томография бедренной кости (справа или слева)', 15),
(1, 'Компьютерная томография большой и малой берцовой костей (справа или слева)', 15),
(1, 'Компьютерная томография стопы (справа или слева)', 15),
(1, 'Компьютерная томография плечевого сустава (справа или слева)', 15),
(1, 'Компьютерная томография локтевого сустава (справа или слева)', 15),
(1, 'Компьютерная томография лучезапястного сустава (справа или слева)', 15),
(1, 'Компьютерная томография тазобедренного сустава (справа или слева)', 15),
(1, 'Компьютерная томография коленного сустава (справа или слева)', 15),
(1, 'Компьютерная томография голеностопного сустава (справа или слева)', 15),
(1, 'Компьютерная томография височно-нижнечелюстных суставов (обоих)', 15),
(1, 'Компьютерная томография придаточных пазух носа', 15),
(1, 'Компьютерная томография органов грудной полости', 15),
(1, 'Низкодозная компьютерная томография органов грудной полости', 10),
(1, 'Компьютерная томография сердца (коронарный кальций)', 20),
(1, 'Компьютерная томография органов малого таза', 15),
(1, 'Компьютерная томография височной кости', 15),
(1, 'Компьютерная томография глазниц', 15),
(1, 'Компьютерная томография почек и мочевыводящих путей', 15),
(1, 'Компьютерная томография органов брюшной полости', 15),
(1, 'Компьютерная томография надпочечников', 20),
(1, 'Компьютерная томография толстой кишки (КТ-колонография)', 30),
(1, 'Компьютерная томография грудной полости и брюшной полости', 15),
(1, 'Компьютерная томография грудной полости и брюшной полости и органов малого таза', 15),
(1, 'Компьютерная томография головы, грудной полости и брюшной полости и органов малого таза', 20),

(2, 'Магнитно-резонансная томография мягких тканей (с указанием анатомической области)', 30),
(2, 'Магнитно-резонансная томография шейного отдела позвоночника', 30),
(2, 'Магнитно-резонансная томография грудного отдела позвоночника', 30),
(2, 'Магнитно-резонансная томография пояснично-крестцового отдела позвоночника', 30),
(2, 'Магнитно-резонансная томография височно-нижнечелюстных суставов (обоих)', 30),
(2, 'Магнитно-резонансная томография плечевого сустава (справа или слева)', 30),
(2, 'Магнитно-резонансная томография локтевого сустава (справа или слева)', 30),
(2, 'Магнитно-резонансная томография лучезапястного сустава (справа или слева)', 30),
(2, 'Магнитно-резонансная томография кисти (справа или слева)', 30),
(2, 'Магнитно-резонансная томография тазобедренного сустава (справа или слева)', 30),
(2, 'Магнитно-резонансная томография коленного сустава (справа или слева)', 30),
(2, 'Магнитно-резонансная томография голеностопного сустава (справа или слева)', 30),
(2, 'Магнитно-резонансная томография стопы (справа или слева)', 30),
(2, 'Магнитно-резонансная томография преддверно-улиткового органа и мосто-мозжечкового угла', 20),
(2, 'Магнитно-резонансная томография сердца', 40),
(2, 'Магнитно-резонансная томография средостения', 40),
(2, 'МР-артериография (одна область)', 15),
(2, 'МР-венография (одна область)', 15),
(2, 'МР-холангиопанкреатография', 20),
(2, 'Магнитно-резонансная томография головного мозга', 20),
(2, 'Магнитно-резонансная томография основания черепа', 20),
(2, 'Магнитно-резонансная томография головного мозга с функциональными пробами', 60),
(2, 'Магнитно-резонансная томография гипоталамо-гипофизарной области головного мозга', 20),
(2, 'Магнитно-резонансная ликворография головного мозга', 20),
(2, 'Протонная магнитно-резонансная спектроскопия', 60),
(2, 'Магнитно-резонансная томография глазниц', 30),
(2, 'Магнитно-резонансная томография органов малого таза', 30),
(2, 'Магнитно-резонансная томография брюшной полости', 30),
(2, 'Магнитно-резонансная томография шеи', 20),
(2, 'Магнитно-резонансная томография малого таза с применением ректального датчика', 40),
(2, 'Бесконтрастная Магнитно-резонансная урография', 20),
(2, 'Магнитно-резонансная трактография', 20),
(2, 'Функциональная Магнитно-резонансная томография головного мозга с предъявлением стимульного материала', 60),
(2, 'Функциональная Магнитно-резонансная томография головного мозга с DTI "высокого разрешения" с предъявлением стимульного материала', 60),
(2, 'Функциональная Магнитно-резонансная томография головного мозга с одновременным ЭЭГ картированием, с предъявлением стимульного материала', 60),
(2, 'Магнитно-резонансная томография молочных желез', 40),
(2, 'Функциональная Магнитно-резонансная томография сустава', 30),
(2, 'Диффузионно-взвешенная магнитно-резонансная томография всего тела (голова, грудная клетка, брюшная полость, малый таз)', 60),

(3, 'Компьютерная томография головы с контрастированием', 30),
(3, 'Компьютерная томография ангиография головы (с предварительным бесконтрастным сканированием)', 30),
(3, 'Компьютерная томография придаточных пазух носа с контрастированием', 30),
(3, 'Компьютерная томография височных костей с контрастированием', 30),
(3, 'Компьютерная томография глазниц с контрастированием', 20),
(3, 'Компьютерная томография оценка проходимости носослезных каналов', 15),
(3, 'Компьютерная томография ангиография конечностей (верхние или нижние; с предварительным бесконтрастным сканированием)', 30),
(3, 'Компьютерная томография шеи с внутривенным болюсным контрастированием', 25),
(3, 'Компьютерная томография ангиография шеи (с предварительным бесконтрастным сканированием)', 30),
(3, 'Компьютерная томография позвоночника (шейный отдел) с контрастированием', 25),
(3, 'Компьютерная томография позвоночника (грудной отдел) с контрастированием', 25),
(3, 'Компьютерная томография позвоночника (поясничный отдел) с контрастированием', 25),
(3, 'Компьютерная томография позвоночника (крестцовый и копчиковый отделы) с контрастированием', 30),
(3, 'Компьютерная томография органов грудной полости с контрастированием', 25),
(3, 'Компьютерная томография ангиография грудной полости (с предварительным бесконтрастным сканированием)', 30),
(3, 'Компьютерная томография сердца с контрастированием', 25),
(3, 'Компьютерная томография ангиография брюшной полости с контрастированием (с предварительным бесконтрастным сканированием)', 30),
(3, 'Компьютерная томография тонкой кишки с контрастированием (КТ-энтерография)', 25),
(3, 'Компьютерная томография толстой кишки с контрастированием (КТ-колонография)', 30),
(3, 'Компьютерная томография органов малого таза с контрастированием', 25),
(3, 'Компьютерная томография перфузионное исследование головы', 25),
(3, 'Компьютерная томография надпочечников с контрастированием', 25),
(3, 'Компьютерная томография органов брюшной полости с контрастированием', 30),
(3, 'Компьютерная томография грудной полости и брюшной полости с контрастированием', 30),
(3, 'Компьютерная томография грудной полости и брюшной полости и органов малого таза с контрастированием', 30),
(3, 'Компьютерная томография головы, грудной полости и брюшной полости и органов малого таза с внутривенным болюсным контрастированием', 30),

(4, 'Магнитно-резонансная томография мягких тканей с контрастированием (с указанием анатомической области);', 30),
(4, 'Магнитно-резонансная томография шейного отдела позвоночника с контрастированием;', 45),
(4, 'Магнитно-резонансная томография грудного отдела позвоночника с контрастированием;', 45),
(4, 'Магнитно-резонансная томография пояснично-крестцового отдела позвоночника с контрастированием;', 45),
(4, 'Магнитно-резонансная томография височно-нижнечелюстных суставов с контрастированием (обоих);', 45),
(4, 'Магнитно-резонансная томография плечевого сустава с контрастированием (справа или слева);', 45),
(4, 'Магнитно-резонансная томография локтевого сустава с контрастированием (справа или слева);', 45),
(4, 'Магнитно-резонансная томография лучезапястного сустава с контрастированием (справа или слева);', 45),
(4, 'Магнитно-резонансная томография кисти с контрастированием (справа или слева);', 45),
(4, 'Магнитно-резонансная томография тазобедренного сустава с контрастированием (справа или слева);', 45),
(4, 'Магнитно-резонансная томография коленного сустава с контрастированием (справа или слева);', 45),
(4, 'Магнитно-резонансная томография голеностопного сустава с контрастированием (справа или слева);', 45),
(4, 'Магнитно-резонансная томография стопы с контрастированием (справа или слева);', 45),
(4, 'Магнитно-резонансная томография сердца с контрастированием;', 60),
(4, 'Магнитно- резонансная томография ангиография с контрастированием (с указанием анатомической области);', 35),
(4, 'Магнитно-резонансная томография головного мозга с контрастированием;', 35),
(4, 'Магнитно-резонансная перфузия головного мозга;', 40),
(4, 'Магнитно-резонансная томография основания черепа', 35),
(4, 'Магнитно-резонансная томография глазниц с контрастированием;', 45),
(4, 'Магнитно-резонансная томография преддверно-улиткового органа и мосто-мозжечкового угла с контрастированием;', 35),
(4, 'Магнитно-резонансная томография органов малого таза с внутривенным контрастированием;', 50),
(4, 'Магнитно-резонансная томография брюшной полости с внутривенным контрастированием;', 50),
(4, 'Магнитно-резонансная томография шеи с внутривенным контрастированием;', 35),
(4, 'Магнитно-резонансная томография гипоталамо-гипофизарной области головного мозга;', 35),
(4, 'Магнитно-резонансная томография печени с внутривенным контрастированием гепатотропным препаратом;', 50),
(4, 'Магнитно-резонансная томография молочных желез с внутривенным контрастированием;', 60),
(4, 'Пункционная биопсия (молочной железы) под контролем МРТ для забора гистологического материала с внутривенным контрастированием.', 80)

) q(КодКатегорииМетодики, Название, Интервал)


