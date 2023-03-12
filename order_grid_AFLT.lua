--    Бот предназначен для покупки и продажи бумаг по принципу сетки ордеров, 
--    но выставляет по одному ордеру с каждой стороны. 
--    Каждую сделку записывает в файл на память чтобы помнить состояние между запусками.
--    Использует самописный таймер для снижения частоты совершения сделок при проскальзываниях.
--    

require("m_trader")                    --  импорт файла с библиотекой


-- присванивание переменным начальных базовых значений торгового алгоритма
Class_Code = "TQBR"                    -- класс торгуемого инструмента
Sec_Code = "AFLT"                      -- код торгуемого инструмента
agent = "order_grid_"..Sec_Code        -- имя бота
g_lots = 1                             -- количество торгуемых лот
target = 1                             -- цель
commission = 0.2                       -- комиссия
spred = target + commission 		   -- спред между моими заявками в процентах
otstup = 0.2						   -- отступ от предыдущей заявки в процентах
reserve = 0                                  -- число лотов которые нельзя продавать
is_target_growth = true                      -- приращивание цели
price_file_name = agent.."_"..g_lots..".txt" -- имя файла для сохранения последнего исполненого уровня 
date_file_name = agent.."_".."date"..".txt"  -- имя файла для сохранения даты

start_work_time = 100000
finish_work_time = 234800

price = 0
is_run = true                                -- переменная для безконечного цикла
pause_size = 3

finish_timer = 0                             -- переменные для таймера
start_timer = 0

sled_zaavka_short = getParamEx(Class_Code, Sec_Code, "last").param_value      -- уровень ближайшей продажи (инициализация)
sled_zaavka_long = sled_zaavka_short                                          -- уровень ближайшей покупки (инициализация)
poslednaa_operacia=""
step=tonumber(getParamEx(Class_Code, Sec_Code, "SEC_PRICE_STEP").param_value) -- минимальный шаг цены


function OnStop()
--[[
Колбэк функция, вызываемая при нажатии кнопки "Остановить"
]]--
    is_run = false                                      -- переменная для безконечного цикла
end

function get_file_info()
--[[
получение значения из файла
]]--
	res = ""
	f = io.open(getScriptPath().."\\"..price_file_name,"r+")	-- Открывает файл в режиме "чтения"
	for line in f:lines() do res = line end
	return tonumber(res)
end

function set_file_info(text)
--[[
Запись значения в файл.
Записывается цена по которой должна была произойти сделка.
Продажа записывается со знаком минус
]]--
	f = io.open(getScriptPath().."\\"..price_file_name,"w")	-- Открывает файл в режиме "записи"
	f:write(text)                                        	-- Запись в файл
	f:flush()	                                            -- Сохраняет изменения в файле
	f:close()                                           	-- Закрывает файл
end

function checking_file()
--[[
первое создание файла
значение соответствует лучшей цене спроса
]]--
	price = getParamEx(Class_Code, Sec_Code, "BID").param_value -- лучшая цена спроса
	f = io.open(getScriptPath().."\\"..price_file_name,"r+")    -- Пытается открыть файл в режиме "чтения/записи"
	if f == nil then                                            -- Если файл не существует
		f = io.open(getScriptPath().."\\"..price_file_name,"w")       -- Создает файл в режиме "записи"
		f:write(price)                                          -- Запись в файл 
		f:flush()                                               -- Сохраняет изменения в файле
	end
	f:close()                                                   -- Закрывает файл
	sleep(1000)
end

function today_month_day() -- int
--[[
Текущее число месяца в системном времени
]]--
	return tonumber(os.date("%d")) 
end

function saved_date() -- int
--[[
 Возвращает сохраненное в файле число месяца
]]--
	res = nil
	f = io.open(getScriptPath().."\\"..date_file_name,"r+")     -- Пытается открыть файл в режиме "чтения/записи"
	if f == nil then                                            -- Если файл не существует
		local today = today_month_day()                         -- сегодняшнее число месяца
		f = io.open(getScriptPath().."\\"..date_file_name,"w")  -- Создает файл в режиме "записи"
		f:write(today)                                          -- Запись в файл 
		f:flush()                                               -- Сохраняет изменения в файле
		res = today
	else
		for line in f:lines() do res = line end
	end
	f:close()                                                   -- Закрывает файл
	return tonumber(res)
end

function save_date()
--[[
Запись числа месяца в файл.
]]--
	f = io.open(getScriptPath().."\\"..date_file_name,"w")	-- Открывает файл в режиме "записи"
	f:write(today_month_day())                            	-- Запись в файл
	f:flush()	                                            -- Сохраняет изменения в файле
	f:close()                                           	-- Закрывает файл

end

function vrema() -- int
--[[
получение локального времени в виде числа в формате ЧЧММСС
]]--
	if os.sysdate().min<10 then minuta=tostring("0"..os.sysdate().min) else minuta=tostring(os.sysdate().min)  end
	if os.sysdate().sec<10 then sekunda=tostring("0"..os.sysdate().sec) else sekunda=tostring(os.sysdate().sec)  end
	return tonumber(tostring(os.sysdate().hour)..minuta..sekunda)
end

function server_time()  --  int
--[[
получение серверного времени в виде числа в формате ЧЧММСС
]]--
	s = ""
	stime = GetInfoParam("SERVERTIME")
	for w in stime:gmatch("%d+") do 
		s = s..w
	end
	return tonumber(s)
end

function work_time()  --  bool
--[[
проверка вхождения в рамки рабочего времени
]]--
    res = false
	if vrema() >= start_work_time and vrema() < finish_work_time then
	    res = true
	end
	return res
end

function delta_server_time(n)  --  bool
--[[
Проверка отставания серверного времени от локального.
n - максимально возможное отставание
]]--
	res = false
	host_time = vrema()
	serv_time = server_time()
	if serv_time == nil then serv_time = 0 end
	if math.abs(host_time - serv_time) < n then
		res = true
	end
	return res
end

function get_timer()  --  bool
--[[
работает ли таймер
]]--
	res = false
	if vrema() < finish_timer then res = true end
	return res
end

function set_timer(t)
--[[
включение тамера  на t секунд
]]--
	start_timer = vrema()
	finish_timer = start_timer + t
end

function session()  --  bool
--[[
состояние торговой сессии
]]--
	return getParamEx(Class_Code, Sec_Code, "TRADINGSTATUS").param_value
end

function last_price()
--[[
текущая цена
Если цена неадекватная, то берем лучшую цену из стакана
]]--
    res = tonumber(getParamEx(Class_Code, Sec_Code, "LAST").param_value)
    if res == 0 or res == nil then
	    if get_file_info() > 0 then
		    res = tonumber(getParamEx(Class_Code, Sec_Code, "BID").param_value)
		else
		    res = tonumber(getParamEx(Class_Code, Sec_Code, "OFFER").param_value)
		end
	end
	return res
end

function main()
--[[
Главная функция
]]--
    while  not work_time() do                   -- ожидаем открытия сессии
	    sleep(1000)
	end
	
	checking_file()                             -- проверяем наличие файла
	first_orders()                              -- получаем начальные значения переменных для заявок
    while is_run do                             -- пока не стопнули
	    if  work_time() then                    -- рабочее время
			if  isConnected() then              -- рабочее соединение с сервером
				if delta_server_time(11) then   --  максимальное отставание времени сервера
					if  session() then          -- сессия
						sleep(100)
						trading_logic()         -- торговая логика
					else
						sleep(1000)
					end                         -- сессия
				else
					sleep(1000)
				end                             --  if delta_server_time()
			else
				sleep(1000)
			end                                 -- рабочее соединение
		else
			sleep(1000)
			if vrema() > finish_work_time then
				is_run = false
			end

		end                                     -- рабочее время
	end                                         -- while is_run
end                                             -- function main

function trading_logic()
--[[
Торговая логика
если цена актива поднялась выше нашей заявки на продажу(произошла продажа)
	то смещаем заявки вверх
если цена актива упала ниже нашей заявки на покупку(произошла покупка)
	то смещаем заявки вниз
]]--
	if is_price_up() == true then
		move_up() 
	end
	if is_price_down() == true then
		move_down()
	end
end

function first_orders()
--[[
Определение уровней для заявок в начале работы бота
]]--
	local x = get_file_info()                                           -- считываем цену из файла
	price = math.abs(x)
	if is_target_growth then                                            -- если хотим приращивать цель 
		if today_month_day() ~= saved_date() then                       -- если запись в файле отличается от сегодняшнего числа
			price = price + price / 100 * target                        -- сдвигаам цену вверх на размер цели
			save_date()                                                 -- сохраняем сегодняшнее число
		end
	end
	if x > 0 then
		sled_zaavka_long = correct_price(price)
		sled_zaavka_short = correct_price(price + price / 100 * spred)
	end
	
	if x < 0 then
		sled_zaavka_short = correct_price(price)
		sled_zaavka_long = correct_price(price - price / 100 * spred)
	end
end

function correct_price(p) 
--[[
Корректировка расчетной (p) цены к виду, принимаемому системой
]]--
	res = math.floor(p / step) * step
	return math.abs(tonumber(res))
end

function position()
--[[
Определение числа лотов в позиции
Шортовая позиция со знаком минус
]]--
	otkrito_lotov=0
	for i = 0,getNumberOf("depo_limits") - 1 do                            -- проход по "Таблице лимитов по бумагам"
		if getItem("depo_limits",i).sec_code == Sec_Code then              -- ЕСЛИ строка по нужному инструменту ТО
			if getItem("depo_limits",i).currentbal > 0 then                -- ЕСЛИ текущая позиция > 0, ТО открыта длинная позиция (BUY)
				BuyVol = getItem("depo_limits",i).currentbal	           -- Количество лотов в позиции BUY
				otkrito_lotov=BuyVol
			else                                                           -- ИНАЧЕ открыта короткая позиция (SELL)
				SellVol = math.abs(getItem("depo_limits",i).currentbal)    -- Количество лотов в позиции SELL
				otkrito_lotov=SellVol
			end
		end
	end
	return otkrito_lotov
end

function move_up() 
--[[
Смещение заявок вверх
Удаляем прежние заявки
записываем цену по которой должны были продать (со знаком минус)
и выставляем вовые
]]--
	if get_timer() == false then                                                        --  если таймер отработал
		trader.DeleteOrder(agent,Class_Code,Sec_Code)                                   --  снимаем заявки
		set_file_info(sled_zaavka_short * -1)		                                    --  записываем цену в файл со знаком минус
		sleep(100)
		sled_zaavka_long = correct_price(sled_zaavka_short - sled_zaavka_short / 100 * spred)	
		sled_zaavka_short = correct_price(sled_zaavka_short + sled_zaavka_short / 100 * otstup)
		
		trader.kupit_po_cene(agent,Class_Code,Sec_Code,g_lots,sled_zaavka_long)         --  лимитная покупка
		if position() > reserve then                                                          --  продаем только если есть что продавать
			trader.prodat_po_cene(agent,Class_Code,Sec_Code,g_lots,sled_zaavka_short)   --  лимитная продажа
		end
		set_timer(pause_size)                                                                    --  активируем таймер
	end
end

function move_down() 
--[[
Смещение заявок вниз
Удаляем прежние заявки
записываем цену по которой должны были купить
и выставляем вовые
]]--
	if get_timer() == false then                                                        --  если таймер отработал
		trader.DeleteOrder(agent,Class_Code,Sec_Code)                                   --  снимаем заявки
		set_file_info(sled_zaavka_long)		                                            --  записываем цену в файл
		sleep(100)
		sled_zaavka_short = correct_price(sled_zaavka_long + sled_zaavka_long / 100 * spred)	
		sled_zaavka_long = correct_price(sled_zaavka_long - sled_zaavka_long / 100 * otstup)
		
		trader.kupit_po_cene(agent,Class_Code,Sec_Code,g_lots,sled_zaavka_long)         --  лимитная покупка
		if position() > reserve then                                                          --  продаем только если есть что продавать
			trader.prodat_po_cene(agent,Class_Code,Sec_Code,g_lots,sled_zaavka_short)   --  лимитная продажа
		end
		set_timer(pause_size)                                                                    --  активируем таймер
	end
end

function is_price_up()  --  bool
--[[
Находится ли цена выше текущего уровня продажи 
]]--
	res = false
	last_pric = tonumber(last_price())
	if last_pric > sled_zaavka_short then
		res = true
	end
	return res
end

function is_price_down()  --  bool
--[[
Находится ли цена ниже текущего уровня покупки 
]]--
	res = false
	last_pric = tonumber(last_price())
	if last_pric < sled_zaavka_long then
		res = true
	end
	return res
end
