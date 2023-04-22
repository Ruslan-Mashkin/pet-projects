--[[
НАЗВАНИЕ
    NS1

ОПИСАНИЕ
    Данный скрипт представляет из себя торгового робота на платформе QUIK,
	работающий на основе некоторых данных о цене актива и производных данных.
	Интерфейс представлен окном с таблицей в которой отображаются параметры программы.
	Параметры в столбцах, отмеченных зелёным цветом, являются настраиваемыми. 
	
	
ВЕРСИЯ
    1.0

СОЗДАТЕЛЬ
    Машкин Руслан (https://t.me/ruslan_mashkin )

Дата создания
    16.04.2023
]]--



------------------------------------------------- Инициализируем глобальные переменные --------------------------
account = ""                  -- основной счет
client_code = ""              -- код клиента
script_name = "NS1"           -- название скрипта
is_running = true             -- флаг, указывающий работает ли скрипт
is_stopped = false            -- флаг, указывающий остановлен ли скрипт
row_new_instrument = 0        -- номер строки в таблице, где новый инструмент
clicked_row = 0               -- номер строки в главной таблице, где был клик
clicked_another_row = 0       -- номер строки в других таблицах, где был клик
additional_window_height = 0  -- высота дополнительных окон
main_window_height = 0        -- высота главного окна
main_window_width = 0         -- ширина главного окна
main_window_x_coord = 0       -- X-координата главного окна
main_window_y_coord = 0       -- Y-координата главного окна
rows_in_main_window = 0       -- количество строк главного окна
current_row_number = 0        -- текущий номер строки в таблице
current_column_number = 0     -- текущий номер столбца в таблице
user_input = ""               -- строка ввода пользователя
native_folder_path = ""       -- путь к папке
default_value_1 = 1           -- дефолтное значение для ячейки таблицы
default_value_2 = 10          -- дефолтное значение для ячейки таблицы
current_second = 0            -- для определения секунды в системном вререни
Class_Code = "TQBR"           -- класс торгуемого инструмента
Sec_Code = "SBERP"            -- код торгуемого инструмента
g_lots = 1                    -- количество торгуемых лот


x_variable = 0                -- короткая средняя
y_variable = 0                -- длинная средняя
A_variable = 0                -- разница между вчерашним high и короткой средней
B_variable = 0                -- разница между длинной и короткой средними
-----------------------------------------------------------------------------------------------------------------

------------------------------------------------- Инициализируем рабочие таблицы --------------------------------

-- Создаем основную таблицу
QTable = {}
QTable.__index = QTable

-- Создаем таблицу классов
Class_Table = {}
Class_Table.__index = Class_Table

-- Создаем таблицу инструментов
Sec_Table = {}
Sec_Table.__index = Sec_Table

-- Создаем таблицу информации
Inf_Table = {}
Inf_Table.__index = Inf_Table

-- Создаем таблицу действий
Task_Table = {}
Task_Table.__index = Task_Table

-- Создаем таблицу торгового счета
Account_Table = {}
Account_Table.__index = Account_Table

-- Создаем таблицу кода клиента
CLIENT_CODE_Table = {}
CLIENT_CODE_Table.__index = CLIENT_CODE_Table
-----------------------------------------------------------------------------------------------------------------

------------------------------------------------- Функции скрипта -----------------------------------------------

function OnStop()
--[[
НАЗВАНИЕ
    Обработчик события OnStop()

ОПИСАНИЕ
    Данный обработчик вызывается при остановке торгового робота на платформе QUIK.
	В функции происходит удаление всех созданных таблиц и установка флага is_stopped в true.

ПАРАМЕТРЫ
    Нет параметров.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Нет возвращаемых значений.
]]--
    -- Устанавливаем флаг остановки скрипта
    is_stopped = true
    
    -- Устанавливаем флаг работы скрипта как false
    is_running = false
    
    -- Удаляем созданные таблицы
	DestroyTable(t_id)
	DestroyTable(c_id)
	DestroyTable(s_id)	
	DestroyTable(inf_id)
	DestroyTable(task_id)
	DestroyTable(a_id)
	DestroyTable(cc_id)
end

function OnInit(p_)
--[[
НАЗВАНИЕ: OnInit

ОПИСАНИЕ:
    Данная функция вызывается при первом запуске торгового робота на платформе QUIK.

ПАРАМЕТРЫ:
    p_ - строка. Путь к папке, в которой хранится скрипт.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ:
    Нет возвращаемых значений.
]]--

	native_folder_path = tostring(p_)
end

function main()
--[[
НАЗВАНИЕ
    Главная функция скрипта - main()

ОПИСАНИЕ
    Данная функция запускает главное окно с таблицей.
    Затем функция начинает выполнять основной код скрипта, который выполняется в бесконечном цикле. 
    Если флаг is_stopped установлен в true, то функция завершает работу, бот останавливается.
    Иначе функция вызывает функцию Table_UpDate(), которая обновляет данные в таблице и выполняет необходимые действия.

ПАРАМЕТРЫ
    Нет параметров.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Нет возвращаемых значений
]]--
	InitTable()                      -- Запускаем окно с таблицей
	sleep(1000) 
	local sr=SetSelectedRow(t_id, 1) -- Переводим фокус на первую строку
	while is_running do              -- Безконечный цикл
		if is_stopped then           -- Если флаг остановки установлен, то выходим из цикла
			return
		end
		sleep(100)                   -- Задержка
		Table_UpDate()               -- Обновляем данные в таблице
	end  --while
end  --function

function To_integer(n)
--[[
НАЗВАНИЕ
    Функция преобразования любого числа в целое число - To_integer()

ОПИСАНИЕ
    Данная функция получает на вход любое число и преобразует его в целое число. 
    Если преобразование не удалось, то функция возвращает значение nil.

ПАРАМЕТРЫ
    Аргументы функции:
    * n - любое число , которое нужно преобразовать в целое число.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Возвращаемое значение:
    * Целое число, если преобразование удалось, или nil, если не удалось.
]]--
	return math.tointeger(tonumber(n))
end

function UpdateWindowTitle()
--[[
НАЗВАНИЕ
    Функция обновления заголовка окна - UpdateWindowTitle()

ОПИСАНИЕ
    Данная функция обновляет заголовок главного окна, добавляя к нему текущее время в формате часы:минуты:секунды.
	Это нужно в том числе для индикации работы скрипта 
ПАРАМЕТРЫ
    Нет параметров.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Нет возвращаемых значений.
]]--
	if current_second ~= tonumber(os.date("%S")) then                           -- проверяем, изменилась ли текущая секунда
		current_second = tonumber(os.date("%S"))                                -- если изменилась, то обновляем значение переменной
		SetWindowCaption(tt, script_name.."         "..tostring(os.date("%X"))) -- обновляем заголовок окна
	end
end


function CalculateX(class, sec, period)
--[[
НАЗВАНИЕ
    Функция вычисления значения X - CalculateX()

ОПИСАНИЕ
    Данная функция вычисляет значение X для инструмента по заданным параметрам.

ПАРАМЕТРЫ
    Аргументы функции:
    * class - класс инструмента.
    * sec - код инструмента.
    * period - период скользящей средней для вычисления значения X.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Возвращаемое значение:
    * Значение X для заданного инструмента и периода скользящей средней.
]]
	--Подключаем график
	ds, Error = CreateDataSource(class, sec, tonumber(1440))
	-- Ждет, пока данные будут получены с сервера (на случай, если такой график не открыт)
	while (Error == "" or Error == nil) and ds:Size() == 0 do sleep(1) end
	if Error ~= "" and Error ~= nil then message("Ошибка подключения к графику: "..Error) end

	Size = ds:Size()                  -- Возвращает текущий размер (количество свечей в источнике данных)
	local sum = 0
	for i=1, period do
		sum = sum + ds:C(Size - i)    -- Накапливаем сумму закрытий свечей
	end
	ds:Close()                        -- Удаляет источник данных, отписывается от получения данных

	return sum / period               -- Получаем и возвращаем среднее

end

function CalculateY(class, sec, period)
--[[
НАЗВАНИЕ
    Функция вычисления значения Y - CalculateY()

ОПИСАНИЕ
    Данная функция вычисляет значение Y для инструмента по заданным параметрам.

ПАРАМЕТРЫ
    Аргументы функции:
    * class - класс инструмента.
    * sec - код инструмента.
    * period - период скользящей средней для вычисления значения Y.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Возвращаемое значение:
    * Значение Y для заданного инструмента и периода скользящей средней.
]]	
	--Подключаем график
	ds, Error = CreateDataSource(class, sec, tonumber(1440))
	-- Ждет, пока данные будут получены с сервера (на случай, если такой график не открыт)
	while (Error == "" or Error == nil) and ds:Size() == 0 do sleep(1) end
	if Error ~= "" and Error ~= nil then message("Ошибка подключения к графику: "..Error) end

	Size = ds:Size()                -- Возвращает текущий размер (количество свечей в источнике данных)
	local sum = 0
	for i=1, period do
		sum = sum + ds:C(Size - i)  -- Накапливаем сумму закрытий свечей
	end
	ds:Close()                      -- Удаляет источник данных, отписывается от получения данных

	return sum / period             -- Получаем и возвращаем среднее

end

function isValidPositiveNumber(n)
--[[
НАЗВАНИЕ
    Функция проверки корректности значения переменной - isValidPositiveNumber()
	
ОПИСАНИЕ
    Данная функция проверяет корректность переданного значения переменной.
	
ПАРАМЕТРЫ
    Аргументы функции:
    * n - проверяемое значение переменной.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    * Возвращает true, если переданное значение корректно (число больше 0), иначе - false.
]]  
	res = false                                                 -- устанавливаем значение результата в ложь
	if n == nil or type(n) == "string" or n == "" or n <=0 then -- проверяем значение на nil, тип "string", пустую строку и отрицательные/нулевые числа
		res = false                                             -- если значение не соответствует требованиям, то устанавливаем результат в ложь
	else
		res = true                                              -- иначе устанавливаем результат в истину
	end
	return res                                                  -- возвращаем результат выполнения функции
end

function YesterdayHigh(class, sec)
--[[
НАЗВАНИЕ
    Функция получения максимального значения за вчерашний день - YesterdayHigh()

ОПИСАНИЕ
    Данная функция получает максимальное значение за вчерашний день для заданного инструмента.

ПАРАМЕТРЫ
    Аргументы функции:
    * classcod - класс инструмента.
    * seccod - код инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    * Максимальное значение за вчерашний день для заданного инструмента.
]]  
	ds, Error = CreateDataSource(class, sec, tonumber(1440))
	-- Ждет, пока данные будут получены с сервера (на случай, если такой график не открыт)
	while (Error == "" or Error == nil) and ds:Size() == 0 do sleep(1) end
	if Error ~= "" and Error ~= nil then message("Ошибка подключения к графику: "..Error) end

	Size = ds:Size()     -- Возвращает текущий размер (количество свечей в источнике данных)
	res = ds:H(Size - 1) -- Получаем вчерашний high
	ds:Close()           -- Удаляет источник данных, отписывается от получения данных
	
	return res

end

function Position(sec)
--[[
НАЗВАНИЕ
    Position - функция определения числа лотов в позиции.

ОПИСАНИЕ
    Данная функция определяет количество лотов в текущей позиции по заданному инструменту. 
    Положительное значение указывает на открытую длинную позицию (BUY), отрицательное — на открытую короткую позицию (SELL).

ПАРАМЕТРЫ
    sec (string) - код инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Целое число, количество лотов в позиции.
]]

	position_size = 0
	for i = 0,getNumberOf("depo_limits") - 1 do                 -- проход по "Таблице лимитов по бумагам"
		if getItem("depo_limits",i).sec_code == sec then        -- ЕСЛИ строка по нужному инструменту ТО
			if getItem("depo_limits",i).currentbal > 0 then     -- ЕСЛИ текущая позиция > 0, ТО открыта длинная позиция (BUY)
				BuyVol = getItem("depo_limits",i).currentbal	-- Количество лотов в позиции BUY
				position_size=BuyVol
			else                                                -- ИНАЧЕ открыта короткая позиция (SELL)
				SellVol = getItem("depo_limits",i).currentbal   -- Количество лотов в позиции SELL
				position_size=SellVol
			end
		end
	end
	return position_size
end

function Last_price(class, sec)
--[[
НАЗВАНИЕ
    Last_price - функция получения текущей цены заданного инструмента.

ОПИСАНИЕ
    Данная функция возвращает текущую цену заданного инструмента.

ПАРАМЕТРЫ
    class (string) - код класса инструмента.
    sec (string) - код инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Число, текущая цена заданного инструмента.
]]
	return tonumber(getParamEx(class, sec, "LAST").param_value)
end

function Lot_size(class, sec)
--[[
НАЗВАНИЕ
    Lot_size - функция получения количества бумаг в лоте инструмента.

ОПИСАНИЕ
    Данная функция возвращает количество бумаг в лоте заданного инструмента.

ПАРАМЕТРЫ
    class (string) - код класса инструмента.
    sec (string) - код инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Целое число, количество бумаг в лоте заданного инструмента.
]]
    return tonumber(getParamEx(class, sec, "LOTSIZE").param_value)
end


function Avg_position_price(class, sec)
--[[
НАЗВАНИЕ
    Avg_position_price - функция получения средней цены открытой позиции по заданному инструменту.

ОПИСАНИЕ
    Данная функция возвращает среднюю цену приобретения открытой позиции по заданному инструменту.

ПАРАМЕТРЫ
    class (string) - код класса инструмента.
    sec (string) - код инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Число, средняя цена приобретения открытой позиции заданного инструмента.
]]

  local avg_price = 0
  for i = 0, getNumberOf("depo_limits") - 1 do                  -- проход по "Таблице лимитов по бумагам"
    if getItem("depo_limits", i).sec_code == sec then           -- ЕСЛИ строка по нужному инструменту ТО
      avg_price = getItem("depo_limits", i).awg_position_price  -- Средняя цена приобретения открытой позиции
    end
  end
  return tonumber(avg_price)
end

function Min_price_step(class, sec)
--[[
НАЗВАНИЕ
    Min_price_step - функция получения минимального шага цены для выбранного инструмента.

ПАРАМЕТРЫ
    class (string) - код класса инструмента.
    sec (string) - код инструмента.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Число, минимальный шаг цены для переданного инструмента.
]]
	step=tonumber(getParamEx(Class_Code, Sec_Code, "SEC_PRICE_STEP").param_value) -- минимальный шаг цены
	return step
end

function CorrectPrice(class, sec, p) 
--[[
НАЗВАНИЕ
    CorrectPrice - функция корректировки расчетной цены к виду, принимаемому системой.

ПАРАМЕТРЫ
    class (string) - код класса инструмента.
    sec (string) - код инструмента.
    p (number) - расчетная цена.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Число, скорректированная цена к виду, принимаемому системой.
]]
	local step = Min_price_step(class, sec)       -- получаем минимальный шаг цены
	res = math.floor(p / step) * step             -- получаем корректную цену
	if step == 1 orstep == 10 or step == 100 then -- если шаг цены целое число 
		res = To_integer(res)                     -- то цену преобразовать к целочисленному значению 
	end
	return math.abs(tonumber(res))
end


function CalcIndentPrice(class, sec, price, percent)
--[[
НАЗВАНИЕ
    CalcIndentPrice - функция расчета цены отступа от переданной цены.

ОПИСАНИЕ
    Данная функция рассчитывает цену отступа от переданной цены в зависимости от заданного процента.

ПАРАМЕТРЫ
    class (string) - код класса инструмента.
    sec (string) - код инструмента.
    price (number) - переданная цена.
    percent (number) - процент, на который необходимо сдвинуть цену.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Число, цена отступа для переданной цены с учетом заданного процента.
]]
    local indent_price = price - price / 100 * percent  --рассчитываем цену на заданный процент от переданной цены
    return CorrectPrice(class, sec, indent_price)
end

function CheckAllCellsFilled(i)
--[[
НАЗВАНИЕ
    CheckAllCellsFilled - функция проверки заполнения всех ячеек в строке таблицы.

ОПИСАНИЕ
    Данная функция проверяет заполнение всех ячеек в конкретной строке таблицы.

ПАРАМЕТРЫ
    i (number) - номер строки в таблице.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    true, если все ячейки заполнены корректно, иначе - false.
]]
	-- Инициализация переменной для хранения результата проверки.
	res = false

	-- Получение значений из ячеек таблицы и преобразование в числовой формат.
	local a = tonumber(GetCell(tt, i, 108)["image"])     
	local b = tonumber(GetCell(tt, i, 109)["image"])            
	local c = tonumber(GetCell(tt, i, 114)["image"])
	local d = tonumber(GetCell(tt, i, 115)["image"]) 
	local e = tonumber(GetCell(tt, i, 116)["image"])

	-- Проверка корректности заполнения ячеек, вызов функции isValidPositiveNumber для каждой из них.
	if isValidPositiveNumber(a) and isValidPositiveNumber(b) and isValidPositiveNumber(c) and isValidPositiveNumber(d) and isValidPositiveNumber(e) then

		-- Если все ячейки заполнены корректно, то результату проверки присваивается значение true.
		res = true
	end
  
	-- Возврат значения результата проверки.
	return res
end

function MarketBuy(class, sec, number_lots)
--[[
НАЗВАНИЕ
    MarketBuy - функция открытия позиции путем рыночной покупки.

ОПИСАНИЕ
    Данная функция осуществляет открытие позиции путем рыночной покупки инструмента.

ПАРАМЕТРЫ
    class (string) - код класса инструмента
    sec (string) - код инструмента
    number_lots (number) - количество лотов

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    true, если транзакция успешно отправлена, иначе false.
]]
	local trans_params =
	{
		CLIENT_CODE = client_code,
		CLASSCODE = class,                      -- Код класса
		SECCODE = sec,      		            -- Код инструмента	
		ACCOUNT = account,   			        -- Код счета
		TYPE = "M",        		                -- Тип ('L' - лимитированная, 'M' - рыночная)
		TRANS_ID = tostring(os.time()),         -- Номер транзакции
		OPERATION = "B",         			    -- Операция ('B' - buy, или 'S' - sell)	
		QUANTITY = tostring(number_lots),       -- Количество
		PRICE = "0",                            -- Цена
		ACTION = "NEW_ORDER"                    -- Тип транзакции ('NEW_ORDER' - новая заявка)
	}
	local res = sendTransaction(trans_params)   -- отправка транзакции
	if is_running and string.len(res) ~= 0 then -- если транзакция не выполнена
		message(tostring(getSecurityInfo(class,sec).short_name).."   Транзакция не прошла  ".. tostring(res)) -- вывод сообщения об ошибке
		return false
	else -- иначе не выводится сообщение
		return true
	end 
end

function MarketSell(class, sec, number_lots)
--[[
НАЗВАНИЕ
    MarketSell - функция закрытия позиции путем рыночной продажи.

ОПИСАНИЕ
    Данная функция осуществляет закрытие позиции путем рыночной продажи инструмента.

ПАРАМЕТРЫ
    class (string) - код класса инструмента
    sec (string) - код инструмента
    number_lots (number) - количество лотов

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    true, если транзакция успешно отправлена, иначе false.
]]
	local trans_params =
	{
		CLIENT_CODE = client_code,
		CLASSCODE = class,                      -- Код класса
		SECCODE = sec,      		            -- Код инструмента	
		ACCOUNT = account,   			        -- Код счета
		TYPE = "M",        		                -- Тип ('L' - лимитированная, 'M' - рыночная)
		TRANS_ID = tostring(os.time()),         -- Номер транзакции
		OPERATION = "S",         			    -- Операция ('B' - buy, или 'S' - sell)	
		QUANTITY = tostring(number_lots),       -- Количество
		PRICE = "0",                            -- Цена
		ACTION = "NEW_ORDER"                    -- Тип транзакции ('NEW_ORDER' - новая заявка)
	}
	local res = sendTransaction(trans_params)   -- отправка транзакции
	if is_running and string.len(res) ~= 0 then -- если транзакция не выполнена
		message(tostring(getSecurityInfo(class,sec).short_name).."   Транзакция не прошла  ".. tostring(res)) -- вывод сообщения об ошибке
		return false
	else -- иначе не выводится сообщение
		return true
	end 

end

function OpenPosition(class, sec, number_lots)
--[[
НАЗВАНИЕ
    OpenPosition - функция открытия позиции.

ОПИСАНИЕ
    Данная функция осуществляет открытие позиции путем рыночной покупки инструмента.

ПАРАМЕТРЫ
    class (string) - код класса инструмента
    sec (string) - код инструмента
    number_lots (number) - количество лотов

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    нет


]]
	MarketBuy(class, sec, number_lots)  -- вызов функции MarketBuy для открытия позиции
end

function Delayed_Order(class, sec, number_lots, price)
--[[
НАЗВАНИЕ
    Delayed_Order - функция выставления отложенного ордера типа Тэйк-Профит.

ОПИСАНИЕ
    Данная функция осуществляет выставление отложенного ордера типа Тэйк-Профит путем отправки транзакции на биржу.

ПАРАМЕТРЫ
    class (string) - код класса инструмента
    sec (string) - код инструмента
    number_lots (number) - количество лотов
    price (number) - цена тэйк-профита

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    true, если транзакция успешно отправлена, иначе false.


]]
	local trans_params =
		{
		["ACTION"]              = "NEW_STOP_ORDER",         -- Тип заявки
		["TRANS_ID"]            = tostring(os.time()),      -- Номер транзакции
		["CLASSCODE"]           = class,
		["SECCODE"]             = sec,
		["ACCOUNT"]             = account,
		["OPERATION"]           = "B",                      -- Операция ("B" - покупка(BUY), "S" - продажа(SELL))
		["QUANTITY"]            = tostring(number_lots),    -- Количество в лотах
		["PRICE"]               = tostring(0),              -- Цена, по которой выставится заявка при срабатывании Стоп-Лосса (для рыночной заявки по акциям должна быть 0)
		["STOPPRICE"]           = tostring(price),          -- Цена Тэйк-Профита
		["STOP_ORDER_KIND"]     = "TAKE_PROFIT_STOP_ORDER", -- Тип стоп-заявки
		["EXPIRY_DATE"]         = "TODAY",                  -- Срок действия стоп-заявки ("GTC" – до отмены,"TODAY" - до окончания текущей торговой сессии, Дата в формате "ГГММДД")
		["OFFSET"]              = tostring(0),
		["OFFSET_UNITS"]        = "PERCENTS",               -- Единицы измерения отступа ("PRICE_UNITS" - шаг цены, или "PERCENTS" - проценты)
		["SPREAD"]              = tostring(0),
		["SPREAD_UNITS"]        = "PERCENTS",               -- Единицы измерения защитного спрэда ("PRICE_UNITS" - шаг цены, или "PERCENTS" - проценты)
      -- "MARKET_TAKE_PROFIT" = ("YES", или "NO") должна ли выставится заявка по рыночной цене при срабатывании Тэйк-Профита.
      -- Для рынка FORTS рыночные заявки, как правило, запрещены,
      -- для лимитированной заявки на FORTS нужно указывать заведомо худшую цену, чтобы она сработала сразу же, как рыночная
	    --["MARKET_TAKE_PROFIT"]  = "YES",
		["STOPPRICE2"]          = tostring(0),              -- Цена Стоп-Лосса 
		["IS_ACTIVE_IN_TIME"]   = "NO",
		["CLIENT_CODE"]         = tostring(client_code)
		}
	local res = sendTransaction(trans_params)
	if is_running and string.len(res) ~= 0 then           -- если транзакция не выполнена
		message(tostring(getSecurityInfo(class,sec).short_name).."   Транзакция не прошла  ".. tostring(res)) -- вывод сообщения об ошибке
		return false
	else -- иначе не выводится сообщение
		return true
	end 
end

function ClosePosition(class, sec, number_lots)
--[[
НАЗВАНИЕ
    ClosePosition - функция закрытия позиции.

ОПИСАНИЕ
    Данная функция осуществляет закрытие позиции путем рыночной продажи инструмента.

ПАРАМЕТРЫ
    class (string) - код класса инструмента
    sec (string) - код инструмента
    number_lots (number) - количество лотов

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    нет
]]
	MarketSell(class, sec, number_lots)  -- вызов функции MarketSell для закрытия позиции
 end

function Delete_Delayed_Order(class, sec)
--[[

НАЗВАНИЕ
    Delete_Delayed_Order - функция удаления отложенной заявки.

ОПИСАНИЕ
    Данная функция осуществляет удаление отложенной заявки на сделку.

ПАРАМЕТРЫ
    class (string) - код класса инструмента
    sec (string) - код инструмента

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    true - если транзакция была выполнена
    false - если транзакция не была выполнена

]]
	for i = 0,getNumberOf("stop_orders") - 1 do                     -- Перебираются все отложенные заявки на сделку, которые находятся в таблице "stop_orders"
		if getItem("stop_orders",i).sec_code == sec then            -- Если строка по нужному инструменту не равна нулю
			order=getItem("stop_orders",i).flags
			if bit.band(order,1)>0 then                             -- Если отложенная заявка - это стоп-заявка типа "Тейк-профит" (битовая маска с номером 1)
				order_num = getItem("stop_orders",i).order_num      -- Получение номера заявки
				local trans_params =                                -- Создание таблицы параметров транзакции
					{
					["ACTION"] = "KILL_STOP_ORDER",                 -- Действие - удаление отложенной заявки
					["TRANS_ID"] = tostring(os.time()),             -- Уникальный идентификатор транзакции
					["CLASSCODE"] = class,                          -- Код класса инструмента
					["SECCODE"] = sec,                              -- Код инструмента
					["ACCOUNT"] = account,                          -- Номер счета
					["STOP_ORDER_KIND"] = "TAKE_PROFIT_STOP_ORDER", -- Тип стоп-заявки (Тейк-профит)
					["CLIENT_CODE"] = tostring(client_code),        -- Код клиента
					['STOP_ORDER_KEY'] = tostring(order_num)        -- Номер удаляемой заявки
					}
				local res = sendTransaction(trans_params)           -- Отправление транзакции на удаление отложенной заявки
				if is_running and string.len(res) ~= 0 then         -- Если транзакция не выполнена
					message(tostring(getSecurityInfo(class,sec).short_name).."   Транзакция не прошла  ".. tostring(res)) -- Вывод сообщения об ошибке
					return false -- Возвращается false
				else -- Иначе
					return true -- Возвращается true
				end 
			end
		end
	end  
end
 
function Table_UpDate()
--[[
НАЗВАНИЕ
    Table_UpDate - функция обновления данных в главной таблице.

ОПИСАНИЕ
    Данная функция обновляет данные (цену, количество бумаг в лоте, стоимость лота, значения X и Y переменных, 
    максимальное значение за вчерашний день и значение A переменной) в главной таблице.

ПАРАМЕТРЫ
    Нет параметров.

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Нет возвращаемых значений.
]]  
  UpdateWindowTitle()                    -- обновляем заголовок главного окна
  
	for i = 1, rows_in_main_window do    -- перебор строк главной таблицы
		lot_size = 0                     -- количество бумаг в лоте
		lot_price = 0                    -- стоимость лота
		last_price = 0                   -- последняя цена
		
		-- если строка с инструментом
		if is_running and tostring(GetCell(tt,i,3)["image"])~="" then
		  
			local classcod = tostring(GetCell(tt,i,2)["image"])          -- класс инструмента из таблицы
			local seccod = tostring(GetCell(tt,i,3)["image"])            -- код инструмента из таблицы

			last_price =  tonumber(Last_price(classcod, seccod))         -- получаем последнюю цену инструмента
			SetCell(tt, i, 5, tostring(last_price))                      -- записываем цену в таблицу

			lot_size =  To_integer(tonumber(Lot_size(classcod, seccod))) -- получаем количество бумаг в лоте
			SetCell(tt, i, 6, tostring(lot_size))                        -- записываем число бумаг в лоте в таблицу

			lot_price = last_price * lot_size                            -- вычисляем стоимость лота
			SetCell(tt, i, 7, tostring(lot_price))                       -- записываем стоимость лота в таблицу

			x_period = tonumber(GetCell(tt,i,108)["image"])              -- получаем значение периода для расчета Х-средней из таблицы
			y_period = tonumber(GetCell(tt,i,109)["image"])              -- получаем значение периода для расчета Y-средней из таблицы
			number_lots1 = tonumber(GetCell(tt,i,114)["image"])          -- получаем число лотов для открытия позиции из таблицы
			number_lots2 = tonumber(GetCell(tt,i,115)["image"])          -- получаем число лотов для усреднения из таблицы
			indent_percent = tonumber(GetCell(tt,i,116)["image"])        -- получаем процент отступа из таблицы
			
			yesterday_high = YesterdayHigh(classcod, seccod)             -- получаем максимальное значение за вчерашний день для заданного инструмента
			SetCell(tt, i, 12, tostring(yesterday_high))                 -- записываем максимальное значение за вчерашний день в таблицу

			if isValidPositiveNumber(x_period) and isValidPositiveNumber(y_period) then              -- если значения для расчетов корректны (больше 0)
				x_variable = CalculateX(classcod, seccod, x_period)      -- вычисляем значение Х переменной
				SetCell(tt, i, 10, tostring(x_variable))                 -- записываем значение Х переменной в таблицу

				y_variable = CalculateY(classcod, seccod, y_period)      -- вычисляем значение Y переменной
				SetCell(tt, i, 11, tostring(y_variable))                 -- записываем значение Y переменной в таблицу

				A_variable = yesterday_high - x_variable                 -- вычисляем значение A переменной
				SetCell(tt, i, 13, tostring(A_variable))                 -- записываем значение A переменной в таблицу

				B_variable = y_variable - x_variable                     -- вычисляем значение B переменной
				SetCell(tt, i, 14, tostring(B_variable))                 -- записываем значение B переменной в таблицу
			end
			pos = To_integer(tonumber(Position(seccod)))
			SetCell(tt, i, 16, tostring(pos))                            -- записываем размер позиции в таблицу
			avg_pos_price = tonumber(Avg_position_price(classcod, seccod))
			SetCell(tt, i, 15, tostring(avg_pos_price))                  -- записываем значение средней цены позиции в таблицу

			--    Если значения отступа и цены позиции корректны (больше 0), то производится расчет цены отступа 
			if indent_percent ~= nil and avg_pos_price ~= nil and indent_percent >0 and avg_pos_price > 0 then
				indent_price = CalcIndentPrice(classcod, seccod, avg_pos_price, indent_percent)
				SetCell(tt, i, 17, tostring(indent_price))               -- записываем значение цены отступа в таблицу
			end
			----------------------------------------  Торговая логика  --------------------------------------------------
			if CheckAllCellsFilled(i) then                               -- если все настраеваемые параметры заполнены
				if is_running and tostring(GetCell(tt,i,1)["image"])== "Выключить" then 
					if pos == 0 then  -- если позиция отсутствует
						if A_variable > 0 then
							OpenPosition(classcod, seccod, number_lots1)                                    -- открываем позицию
							sleep(3000)
							avg_pos_price = tonumber(Avg_position_price(classcod, seccod))                  -- получаем значение средней цены позиции
							indent_price = CalcIndentPrice(classcod, seccod, avg_pos_price, indent_percent) -- вычисляем цену отступа 
							Delayed_Order(classcod, seccod, number_lots2, indent_price)                     -- создаем отложенный ордер
						end	
					end
					
					if pos > 0 then -- если позиция существует
						if A_variable < 0 then
							ClosePosition(classcod, seccod, pos)         -- закрываем позицию
							Delete_Delayed_Order(classcod, seccod)       -- удаляем отложенный ордер
							sleep(3000)
						end
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------

--==========================================================ЗОНА ТаблицЫ QTable=====================================================================================
-- Функция инициализации таблицы
function QTable.new()
--[[
НАЗВАНИЕ
    QTable.new - функция инициализации таблицы.

ОПИСАНИЕ
    Данная функция создает новую таблицу для вывода информации на терминал QUIK. 

ПАРАМЕТРЫ
    нет

ВОЗВРАЩАЕМЫЕ ЗНАЧЕНИЯ
    Возвращает объект-таблицу или nil, если создание таблицы не удалось.

КОММЕНТАРИИ
    Функция использует функцию AllocTable() для создания таблицы и возвращает объект-таблицу для последующего использования. 

    При создании новой таблицы инициализируются следующие параметры:
        - t_id (number) - идентификатор таблицы
        - caption (string) - заголовок таблицы
        - created (boolean) - флаг, указывающий, была ли таблица успешно создана
        - curr_col (number) - индекс текущей колонки
        - columns (table) - таблица с описанием параметров столбцов

]]
    t_id = AllocTable()          -- создание новой таблицы
    if t_id ~= nil then          -- проверка успешности создания таблицы
        q_table = {}
        setmetatable(q_table, QTable)
        q_table.t_id=t_id        -- присваивание идентификатора таблицы
        q_table.caption = ""     -- присваивание заголовка таблицы
        q_table.created = false  -- флаг, указывающий, что таблица еще не была создана
        q_table.curr_col=0       -- установка значения текущей колонки
        -- Таблица с описанием параметров столбцов
        q_table.columns={}       -- инициализация списка столбцов
        return q_table           -- возвращение объект-таблицы
    else
        return nil  -- возвращение nil, если создание таблицы не удалось
    end
end
--Создаем и инициализируем экземпляр таблицы QTable
test_table = QTable:new()
-- Функция инициализации таблицы


function InitTable()
    tt = test_table.t_id
		AddColumn(tt, 1, "", true,QTABLE_STRING_TYPE,25)
		AddColumn(tt, 2, " Код класса", true,QTABLE_STRING_TYPE,14)
		AddColumn(tt, 3, " Код бумаги", true,QTABLE_STRING_TYPE,14)
		AddColumn(tt, 4, " Бумага", true,QTABLE_STRING_TYPE,16)
		AddColumn(tt, 5, " Цена бумаги", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 6, " Бумаг в лоте", true,QTABLE_INT_TYPE,16)
		AddColumn(tt, 7, " Стоимость лота", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 10, " x текущее значение", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 11, " y текущее значение", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 12, " High вчерашний ", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 13, " A переменная", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 14, " B переменная", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 15, " Цена позиции", true,QTABLE_STRING_TYPE,15)
		
		AddColumn(tt, 16, " Размер позиции", true,QTABLE_INT_TYPE,15)
		AddColumn(tt, 17, " Цена отступа", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 18, " ", true,QTABLE_STRING_TYPE,15)
		
		AddColumn(tt, 108, " x период (настраеваемый параметр)", true,QTABLE_INT_TYPE,15)
		AddColumn(tt, 109, " y период (настраеваемый параметр)", true,QTABLE_INT_TYPE,15)
		AddColumn(tt, 114, " Число лотов для открытия позиции (настраеваемый параметр)", true,QTABLE_INT_TYPE,15)
		AddColumn(tt, 115, " Число лотов для усреднения (настраеваемый параметр)", true,QTABLE_INT_TYPE,15)
		AddColumn(tt, 116, " Процент отступа (настраеваемый параметр)", true,QTABLE_INT_TYPE,15)

    CreateWindow(tt)
    -- Присваиваем окну заголовок
    SetWindowCaption(tt, script_name)
    -- Задаем позицию окна
	main_window_x_coord=0
	main_window_y_coord=0
	main_window_height=40+15+15+16
	main_window_width=1300
    SetWindowPos(tt, main_window_x_coord, main_window_y_coord, main_window_width, main_window_height)
	--Кнопки
	row = InsertRow(tt, -1)
	SetCell(tt, 1, 1, "Добавить инструмент")
	rows_in_main_window = rows_in_main_window + 1
	
	-- визуально разделяем колонки цветом
	local color_back = RGB(230,230,255)
	for i=2,99,2 do
		SetColor(tt, QTABLE_NO_INDEX, i, color_back, RGB(0,0,0), color_back, RGB(0,0,0))
	end
	-- цвет настраеваемых параметров
	local color_back = RGB(111,255,111)
		for i=100, 116 do
		SetColor(tt, QTABLE_NO_INDEX, i, color_back, RGB(0,0,0), color_back, RGB(0,0,0))
	end

    -- Подписываемся на события
    SetTableNotificationCallback(tt, OnTableEvent)
end

-- Функция обрабатывает события в таблице
function OnTableEvent(t_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		OnStop()
		is_stopped = true
		is_running=false
	end
	if is_running and msg==11 then
		--Подсветка ячейки
		Highlight(task_id,par1,par2,000255000,2,500)
		current_row_number = 0
		current_column_number = 0
	end
	if is_running and par2>1 and msg==11 then
		current_row_number = par1
		current_column_number = par2
		user_input = ""
	end

	if is_running and msg==11 then --Нажатие левой кнопки мыши
		--Подсветка ячейки
		Highlight(t_id,par1,par2,000255000,2,500)	
	end
		--При клике по "Добавить инструмент "
	if is_running and par2==1 and msg==11 then
		if tostring(GetCell(tt,par1,1)["image"])=="Добавить инструмент" then
			row_new_instrument = tonumber(par1)
			InitTable_C() --  Запускаем окно с таблицей классов
		end
		-- Включение
		if tostring(GetCell(tt,par1,1)["image"])=="Включить" then
			clicked_row = tonumber(par1)
			InitTable_task() --  Запускаем окно с таблицей действий
		end
		if tostring(GetCell(tt,par1,1)["image"])=="Выключить" then 
			clicked_row = tonumber(par1)
			Class_Code = GetCell(tt,par1,2)["image"]
			Sec_Code = GetCell(tt,par1,3)["image"]
			SetCell(tt, clicked_row, 1, "Включить")
		end
	end
	-- Клик по названию инструмента
	if is_running and (par2==3 or par2==4) and msg==11 and tostring(GetCell(tt,par1,par2)["image"])~="" then
			clicked_row = tonumber(par1)
			InitTable_inf() --  Запускаем окно с таблицей
	end
	-- Нажатия клавиш клавиатуры
	if is_running and msg==6 then
		if current_column_number >= 100 
		and current_row_number < rows_in_main_window then

			-- цифры
			if par2 >=48 and par2 <=57 then
				user_input = user_input..tostring(par2-48)
			end
			-- точка
			if par2 == 46 then
				user_input = user_input.."."
			end
			if par2 == 45 then
				user_input = user_input.."-"
			end
			-- бэк спейс
			if par2 == 8 then
				user_input = ""
			end
			SetCell(tt, current_row_number, current_column_number, user_input)
			-- ввод
			if par2 == 13 then
				user_input = ""
				current_column_number = current_column_number + 1
				Highlight(t_id,current_row_number,current_column_number,000255000,2,100)
			end
		end
	end

end
--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================
--==========================================================ЗОНА ТаблицЫ Account_Table=====================================================================================
-- Функция инициализации таблицы
function Account_Table.new()
    a_id = AllocTable()
    if a_id ~= nil then
        a_table = {}
		setmetatable(a_table, Account_Table)
		a_table.a_id=a_id
		a_table.caption = ""
		a_table.created = false
		a_table.curr_col=0
		-- Таблица с описанием параметров столбцов
		a_table.columns={}
		return a_table
    else
        return nil
    end
end
--Создаем и инициализируем экземпляр таблицы Account_Table
test_a_table = Account_Table:new()
-- Функция инициализации таблицы
function InitTable_A()
    att = test_a_table.a_id
	sleep(10)
	AddColumn(att, 1, "Счета", true,QTABLE_STRING_TYPE,25)
	AddColumn(att, 2, "Описание", true,QTABLE_STRING_TYPE,44)
    CreateWindow(att)
    -- Присваиваем окну заголовок
    SetWindowCaption(att, "Счета")
    -- Задаем позицию окна
	ox=66
	oy=66
	additional_window_height=40+15
	window_width=400
	vo=0
	for i2 = 0,getNumberOf("trade_accounts") - 1 do
		row = InsertRow(att, -1)
		SetCell(att, row, 1, getItem("trade_accounts",i2).trdaccid)
		vo=vo+15
		SetCell(att, row, 2, getItem("trade_accounts",i2).description)
	end;
	if vo>444 then vo=444 end
	SetWindowPos(att, ox, oy, window_width, additional_window_height+vo)
    -- Подписываемся на события
    SetTableNotificationCallback(att, OnTable_Event_a)
end
-- Функция обрабатывает события в таблице
function OnTable_Event_a(a_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		--SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--Подсветка ячейки
		Highlight(a_id,par1,par2,000255000,2,500)
		-- Что нажато?
		account = tostring(GetCell(a_id,par1,1)["image"])
		--message(Class_Code)
		SetCell(tasktt, clicked_another_row, 7, account)
		DestroyTable(a_id)
		test_a_table = Account_Table:new()
	end
end
--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================
--==========================================================ЗОНА ТаблицЫ CLIENT_CODE_Table=====================================================================================
-- Функция инициализации таблицы
function CLIENT_CODE_Table.new()
    cc_id = AllocTable()
    if cc_id ~= nil then
       cc_table = {}
		setmetatable(cc_table, CLIENT_CODE_Table)
		cc_table.cc_id=cc_id
		cc_table.caption = ""
		cc_table.created = false
		cc_table.curr_col=0
		-- Таблица с описанием параметров столбцов
		cc_table.columns={}
		return cc_table
    else
        return nil
    end
end
--Создаем и инициализируем экземпляр таблицы CLIENT_CODE_Table
test_cc_table = CLIENT_CODE_Table:new()
-- Функция инициализации таблицы
function InitTable_CC()
    cctt = test_cc_table.cc_id
	sleep(10)
	AddColumn(cctt, 1, "Коды клиента", true,QTABLE_STRING_TYPE,25)
    CreateWindow(cctt)
    -- Присваиваем окну заголовок
    SetWindowCaption(cctt, "Коды клиента")
    -- Задаем позицию окна
	ox=111
	oy=111
	additional_window_height=40+15
	window_width=200
	--message('+'..class_list)
	vo=0
	for i2 = 0,getNumberOf("client_codes") - 1 do
		row = InsertRow(cctt, -1)
		SetCell(cctt, row, 1, getItem("client_codes",i2))
		vo=vo+15
	end;
	if vo>444 then vo=444 end
	SetWindowPos(cctt, ox, oy, window_width, additional_window_height+vo)
    -- Подписываемся на события
    SetTableNotificationCallback(cctt, OnTable_Event_cc)
end
-- Функция обрабатывает события в таблице
function OnTable_Event_cc(cc_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		--SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--Подсветка ячейки
		Highlight(cc_id,par1,par2,000255000,2,500)
		-- Что нажато?
		client_code = tostring(GetCell(cc_id,par1,1)["image"])
		--message(Class_Code)
		SetCell(tasktt, clicked_another_row, 8, client_code)
		DestroyTable(cc_id)
		test_cc_table = CLIENT_CODE_Table:new()
	end
end

--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================

--==========================================================ЗОНА ТаблицЫ Task_Table=====================================================================================
-- Функция инициализации таблицы
function Task_Table.new()
    task_id = AllocTable()
    if task_id ~= nil then
        task_table = {}
		setmetatable(task_table, Task_Table)
		task_table.task_id=task_id
		task_table.caption = ""
		task_table.created = false
		task_table.curr_col=0
		-- Таблица с описанием параметров столбцов
		task_table.columns={}
		return task_table
    else
        return nil
    end
end
--Создаем и инициализируем экземпляр таблицы Task_Table
test_task_table = Task_Table:new()
-- Функция инициализации таблицы
function InitTable_task()
    tasktt = test_task_table.task_id
		sleep(10)
		AddColumn(tasktt, 1, "Действие", true,QTABLE_STRING_TYPE,16)
		AddColumn(tasktt, 7, "Торговый счет", true,QTABLE_STRING_TYPE,16)
		AddColumn(tasktt, 8, "Код клиента", true,QTABLE_STRING_TYPE,16)
    CreateWindow(tasktt)
    -- Присваиваем окну заголовок
    SetWindowCaption(tasktt, "Действия для "..GetCell(tt,clicked_row,4)["image"])
    -- Задаем позицию окна
	ox=0
	oy=0
	additional_window_height=40+16
	window_width=300
	class_list = getClassesList() -- список классов
	class_list=string.sub(class_list, 1, -2)
	vo=0
	row = InsertRow(tasktt, -1)
	SetColor(tasktt, 1, 1, RGB(0, 255, 0), RGB(0, 0, 0), RGB(0, 255, 0), RGB(0, 0, 0))
	SetCell(tasktt, 1, 1, "Включить")
	SetCell(tasktt, 1, 7, account)
	SetCell(tasktt, 1, 8, client_code)

	SetWindowPos(tasktt, ox, additional_window_height+16, window_width, additional_window_height+vo+15)
    -- Подписываемся на события
    SetTableNotificationCallback(tasktt, OnTable_Event_task)
end

-- Функция обрабатывает события в таблице
function OnTable_Event_task(task_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		--is_stopped = true
		--is_running=false
	end
	if is_running and msg==11 then
		--Подсветка ячейки
		Highlight(task_id,par1,par2,000255000,2,500)
		current_row_number = 0
		current_column_number = 0
	end
	if is_running and par2>1 and msg==11 then
		current_row_number = par1
		current_column_number = par2
		user_input = ""
	end
	if is_running and par2==7 and msg==11 then
		clicked_another_row = tonumber(par1)
		InitTable_A() --  Запускаем окно с таблицей аккаунта
	end
	if is_running and par2==8 and msg==11 then
		clicked_another_row = tonumber(par1)
		InitTable_CC() --  Запускаем окно с таблицей клиентов
	end
	--Клик по "Включить"
	if is_running and par2==1 and msg==11 then
		if tostring(GetCell(tasktt,par1,1)["image"])=="Включить" then
			row_on = tonumber(par1)
			if  GetCell(tasktt,row_on,7)["image"]=="" 
			or GetCell(tasktt,row_on,8)["image"]=="" then
				message("Не все поля заполнены")
			else
					SetCell(tt, clicked_row, 1, "Выключить")
					DestroyTable(task_id)
					test_task_table = Task_Table:new()
					return
				
			end
		end
	end
	-- Нажатия клавиш клавиатуры
	if is_running and msg==6 then
		-- цифры
		if par2 >=48 and par2 <=57 then
			user_input = user_input..tostring(par2-48)
		end
		-- точка
		if par2 == 46 then
			user_input = user_input.."."
		end
		if par2 == 45 then
			user_input = user_input.."-"
		end
		-- бэк спейс
		if par2 == 8 then
			user_input = ""
		end
		SetCell(tasktt, current_row_number, current_column_number, user_input)
		-- ввод
		if par2 == 13 then
			user_input = ""
			current_column_number = current_column_number + 1
			Highlight(task_id,current_row_number,current_column_number,000255000,2,100)
		end
	end
end
--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================
--==========================================================ЗОНА ТаблицЫ inf_Table=====================================================================================
-- Функция инициализации таблицы
function Inf_Table.new()
    inf_id = AllocTable()
    if inf_id ~= nil then
        inf_table = {}
		setmetatable(inf_table, Inf_Table)
		inf_table.inf_id=inf_id
		inf_table.caption = ""
		inf_table.created = false
		inf_table.curr_col=0
		-- Таблица с описанием параметров столбцов
		inf_table.columns={}
		return inf_table
    else
        return nil
    end
end
--Создаем и инициализируем экземпляр таблицы Inf_Table
test_inf_table = Inf_Table:new()
-- Функция инициализации таблицы
function InitTable_inf()
    inftt = test_inf_table.inf_id
		sleep(10)
		AddColumn(inftt, 1, "Параметр", true,QTABLE_STRING_TYPE,25)
		AddColumn(inftt, 2, "Значение", true,QTABLE_STRING_TYPE,77)
    CreateWindow(inftt)
    -- Присваиваем окну заголовок
    SetWindowCaption(inftt, "Информация о инструменте")
    -- Задаем позицию окна
	ox=0
	oy=0
	additional_window_height=40+15
	window_width=600
	class_list = getClassesList() -- список классов
	class_list=string.sub(class_list, 1, -2)
	--message('+'..class_list)
	vo=0
	for k,v in pairs(getSecurityInfo(tostring(GetCell(tt,clicked_row,2)["image"]), tostring(GetCell(tt,clicked_row,3)["image"]))) do
		if string.len(tostring(v))>0 then
			row = InsertRow(inftt, -1)
			SetCell(inftt, row, 1, k)
			vo=vo+15
			SetCell(inftt, row, 2, tostring(v))
		end
	end
	if vo>444 then vo=444 end
	SetWindowPos(inftt, ox, additional_window_height+16, window_width, additional_window_height+vo+15)
    -- Подписываемся на события
    SetTableNotificationCallback(inftt, OnTable_Event_inf)
end
-- Функция обрабатывает события в таблице
function OnTable_Event_inf(inf_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		
	end
	if msg==11 then
		--Подсветка ячейки
		Highlight(inf_id,par1,par2,000255000,2,500)
		-- Что нажато?
		DestroyTable(inf_id)
		test_inf_table = Inf_Table:new()
	end
end
--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================
--==========================================================ЗОНА ТаблицЫ Class_Table=====================================================================================
-- Функция инициализации таблицы
function Class_Table.new()
    c_id = AllocTable()
    if c_id ~= nil then
        c_table = {}
		setmetatable(c_table, Class_Table)
		c_table.c_id=c_id
		c_table.caption = ""
		c_table.created = false
		c_table.curr_col=0
		-- Таблица с описанием параметров столбцов
		c_table.columns={}
		return c_table
    else
        return nil
    end
end
--Создаем и инициализируем экземпляр таблицы Class_Table
test_c_table = Class_Table:new()
-- Функция инициализации таблицы
function InitTable_C()
    ctt = test_c_table.c_id
	sleep(10)
	AddColumn(ctt, 1, "Код класса", true,QTABLE_STRING_TYPE,25)
	AddColumn(ctt, 2, "Название класса", true,QTABLE_STRING_TYPE,77)
    CreateWindow(ctt)
    -- Присваиваем окну заголовок
    SetWindowCaption(ctt, "Выбрать класс")
    -- Задаем позицию окна
	ox=0
	oy=0
	additional_window_height=40+15
	window_width=600
	class_list = getClassesList() -- список классов
	class_list=string.sub(class_list, 1, -2)
	vo=0
	for i in string.gmatch(class_list, "[^%,]+") do
		row = InsertRow(ctt, -1)
		SetCell(ctt, row, 1, i)
		vo=vo+15
		c_name= getClassInfo(i).name
		SetCell(ctt, row, 2, c_name)
	end
	if vo>444 then vo=444 end
	SetWindowPos(ctt, ox, additional_window_height+15, window_width, additional_window_height+vo)
    -- Подписываемся на события
    SetTableNotificationCallback(ctt, OnTable_Event_c)
end
-- Функция обрабатывает события в таблице
function OnTable_Event_c(c_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--Подсветка ячейки
		Highlight(c_id,par1,par2,000255000,2,500)
		-- Что нажато?
		Class_Code = tostring(GetCell(c_id,par1,1)["image"])
		SetCell(tt, row_new_instrument, 2, Class_Code)
		DestroyTable(c_id)
		test_c_table = Class_Table:new()
		InitTable_S()
	end
end
--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================
--==========================================================ЗОНА ТаблицЫ Sec_Table=====================================================================================
-- Функция инициализации таблицы
function Sec_Table.new()
    s_id = AllocTable()
    if s_id ~= nil then
        s_table = {}
		setmetatable(s_table, Sec_Table)
		s_table.s_id=s_id
		s_table.caption = ""
		s_table.created = false
		s_table.curr_col=0
		-- Таблица с описанием параметров столбцов
		s_table.columns={}
		return s_table
    else
        return nil
    end
end
--Создаем и инициализируем экземпляр таблицы Sec_Table
test_s_table = Sec_Table:new()
-- Функция инициализации таблицы
function InitTable_S()
    stt = test_s_table.s_id
	sleep(1)
	AddColumn(stt, 1, "Код инструмента", true,QTABLE_STRING_TYPE,25)
	AddColumn(stt, 2, "Инструмент", true,QTABLE_STRING_TYPE,55)
    CreateWindow(stt)
    -- Присваиваем окну заголовок
    SetWindowCaption(stt, "Выбрать инструмент")
    -- Задаем позицию окна
	ox=55
	oy=55
	additional_window_height=40+15
	window_width=500
    SetWindowPos(stt, ox, additional_window_height+15, window_width, additional_window_height)
	--Кнопки
	sec_list = getClassSecurities(Class_Code)
	sec_list=string.sub(sec_list, 1, -2)
	vo=0
	for i in string.gmatch(sec_list, "[^%,]+") do
		row = InsertRow(stt, -1)
		SetCell(stt, row, 1, i)
		vo=vo+15
		s_name= getSecurityInfo(Class_Code, i).name
		--message(c_name)
		SetCell(stt, row, 2, s_name)
	end
	if vo>444 then vo=444 end
	SetWindowPos(stt, ox, additional_window_height+15, window_width, additional_window_height+vo)
    -- Подписываемся на события
    SetTableNotificationCallback(stt, OnTable_Event)
end
-- Функция обрабатывает события в таблице
function OnTable_Event(s_id, msg, par1, par2)
--   При закрытии окна
	if msg==24 then
		SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--Подсветка ячейки
		Highlight(s_id,par1,par2,000255000,2,500)
		-- Что нажато?
		Sec_Code = tostring(GetCell(s_id,par1,1)["image"])
		--message(Class_Code)
		SetCell(tt, row_new_instrument, 3, Sec_Code)
		s_name= getSecurityInfo(Class_Code, Sec_Code).short_name
		SetCell(tt, row_new_instrument, 4, s_name)
		last_price =  tonumber(getParamEx(Class_Code,  Sec_Code, "LAST").param_value)
		SetCell(tt, row_new_instrument, 5, tostring(last_price))
		row = InsertRow(tt, -1)
		rows_in_main_window = rows_in_main_window + 1
		SetCell(tt, row, 1, "Добавить инструмент")
		SetCell(tt, row-1, 1, "Включить")
		main_window_height=main_window_height+15
		SetWindowPos(tt, main_window_x_coord, main_window_y_coord, main_window_width, main_window_height)
		DestroyTable(s_id)
		test_s_table = Sec_Table:new()
	end
end
--============================================================КОНЕЦ ЗОНЫ ТАБЛИЦЫ======================================================================================
