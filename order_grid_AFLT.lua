--    ��� ������������ ��� ������� � ������� ����� �� �������� ����� �������, 
--    �� ���������� �� ������ ������ � ������ �������. 
--    ������ ������ ���������� � ���� �� ������ ����� ������� ��������� ����� ���������.
--    ���������� ���������� ������ ��� �������� ������� ���������� ������ ��� ����������������.
--    

require("m_trader")                    --  ������ ����� � �����������


-- ������������� ���������� ��������� ������� �������� ��������� ���������
Class_Code = "TQBR"                    -- ����� ���������� �����������
Sec_Code = "AFLT"                      -- ��� ���������� �����������
agent = "order_grid_"..Sec_Code        -- ��� ����
g_lots = 1                             -- ���������� ��������� ���
target = 1                             -- ����
commission = 0.2                       -- ��������
spred = target + commission 		   -- ����� ����� ����� �������� � ���������
otstup = 0.2						   -- ������ �� ���������� ������ � ���������
reserve = 0                                  -- ����� ����� ������� ������ ���������
is_target_growth = true                      -- ������������ ����
price_file_name = agent.."_"..g_lots..".txt" -- ��� ����� ��� ���������� ���������� ����������� ������ 
date_file_name = agent.."_".."date"..".txt"  -- ��� ����� ��� ���������� ����

start_work_time = 100000
finish_work_time = 234800

price = 0
is_run = true                                -- ���������� ��� ������������ �����
pause_size = 3

finish_timer = 0                             -- ���������� ��� �������
start_timer = 0

sled_zaavka_short = getParamEx(Class_Code, Sec_Code, "last").param_value      -- ������� ��������� ������� (�������������)
sled_zaavka_long = sled_zaavka_short                                          -- ������� ��������� ������� (�������������)
poslednaa_operacia=""
step=tonumber(getParamEx(Class_Code, Sec_Code, "SEC_PRICE_STEP").param_value) -- ����������� ��� ����


function OnStop()
--[[
������ �������, ���������� ��� ������� ������ "����������"
]]--
    is_run = false                                      -- ���������� ��� ������������ �����
end

function get_file_info()
--[[
��������� �������� �� �����
]]--
	res = ""
	f = io.open(getScriptPath().."\\"..price_file_name,"r+")	-- ��������� ���� � ������ "������"
	for line in f:lines() do res = line end
	return tonumber(res)
end

function set_file_info(text)
--[[
������ �������� � ����.
������������ ���� �� ������� ������ ���� ��������� ������.
������� ������������ �� ������ �����
]]--
	f = io.open(getScriptPath().."\\"..price_file_name,"w")	-- ��������� ���� � ������ "������"
	f:write(text)                                        	-- ������ � ����
	f:flush()	                                            -- ��������� ��������� � �����
	f:close()                                           	-- ��������� ����
end

function checking_file()
--[[
������ �������� �����
�������� ������������� ������ ���� ������
]]--
	price = getParamEx(Class_Code, Sec_Code, "BID").param_value -- ������ ���� ������
	f = io.open(getScriptPath().."\\"..price_file_name,"r+")    -- �������� ������� ���� � ������ "������/������"
	if f == nil then                                            -- ���� ���� �� ����������
		f = io.open(getScriptPath().."\\"..price_file_name,"w")       -- ������� ���� � ������ "������"
		f:write(price)                                          -- ������ � ���� 
		f:flush()                                               -- ��������� ��������� � �����
	end
	f:close()                                                   -- ��������� ����
	sleep(1000)
end

function today_month_day() -- int
--[[
������� ����� ������ � ��������� �������
]]--
	return tonumber(os.date("%d")) 
end

function saved_date() -- int
--[[
 ���������� ����������� � ����� ����� ������
]]--
	res = nil
	f = io.open(getScriptPath().."\\"..date_file_name,"r+")     -- �������� ������� ���� � ������ "������/������"
	if f == nil then                                            -- ���� ���� �� ����������
		local today = today_month_day()                         -- ����������� ����� ������
		f = io.open(getScriptPath().."\\"..date_file_name,"w")  -- ������� ���� � ������ "������"
		f:write(today)                                          -- ������ � ���� 
		f:flush()                                               -- ��������� ��������� � �����
		res = today
	else
		for line in f:lines() do res = line end
	end
	f:close()                                                   -- ��������� ����
	return tonumber(res)
end

function save_date()
--[[
������ ����� ������ � ����.
]]--
	f = io.open(getScriptPath().."\\"..date_file_name,"w")	-- ��������� ���� � ������ "������"
	f:write(today_month_day())                            	-- ������ � ����
	f:flush()	                                            -- ��������� ��������� � �����
	f:close()                                           	-- ��������� ����

end

function vrema() -- int
--[[
��������� ���������� ������� � ���� ����� � ������� ������
]]--
	if os.sysdate().min<10 then minuta=tostring("0"..os.sysdate().min) else minuta=tostring(os.sysdate().min)  end
	if os.sysdate().sec<10 then sekunda=tostring("0"..os.sysdate().sec) else sekunda=tostring(os.sysdate().sec)  end
	return tonumber(tostring(os.sysdate().hour)..minuta..sekunda)
end

function server_time()  --  int
--[[
��������� ���������� ������� � ���� ����� � ������� ������
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
�������� ��������� � ����� �������� �������
]]--
    res = false
	if vrema() >= start_work_time and vrema() < finish_work_time then
	    res = true
	end
	return res
end

function delta_server_time(n)  --  bool
--[[
�������� ���������� ���������� ������� �� ����������.
n - ����������� ��������� ����������
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
�������� �� ������
]]--
	res = false
	if vrema() < finish_timer then res = true end
	return res
end

function set_timer(t)
--[[
��������� ������  �� t ������
]]--
	start_timer = vrema()
	finish_timer = start_timer + t
end

function session()  --  bool
--[[
��������� �������� ������
]]--
	return getParamEx(Class_Code, Sec_Code, "TRADINGSTATUS").param_value
end

function last_price()
--[[
������� ����
���� ���� ������������, �� ����� ������ ���� �� �������
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
������� �������
]]--
    while  not work_time() do                   -- ������� �������� ������
	    sleep(1000)
	end
	
	checking_file()                             -- ��������� ������� �����
	first_orders()                              -- �������� ��������� �������� ���������� ��� ������
    while is_run do                             -- ���� �� ��������
	    if  work_time() then                    -- ������� �����
			if  isConnected() then              -- ������� ���������� � ��������
				if delta_server_time(11) then   --  ������������ ���������� ������� �������
					if  session() then          -- ������
						sleep(100)
						trading_logic()         -- �������� ������
					else
						sleep(1000)
					end                         -- ������
				else
					sleep(1000)
				end                             --  if delta_server_time()
			else
				sleep(1000)
			end                                 -- ������� ����������
		else
			sleep(1000)
			if vrema() > finish_work_time then
				is_run = false
			end

		end                                     -- ������� �����
	end                                         -- while is_run
end                                             -- function main

function trading_logic()
--[[
�������� ������
���� ���� ������ ��������� ���� ����� ������ �� �������(��������� �������)
	�� ������� ������ �����
���� ���� ������ ����� ���� ����� ������ �� �������(��������� �������)
	�� ������� ������ ����
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
����������� ������� ��� ������ � ������ ������ ����
]]--
	local x = get_file_info()                                           -- ��������� ���� �� �����
	price = math.abs(x)
	if is_target_growth then                                            -- ���� ����� ����������� ���� 
		if today_month_day() ~= saved_date() then                       -- ���� ������ � ����� ���������� �� ������������ �����
			price = price + price / 100 * target                        -- �������� ���� ����� �� ������ ����
			save_date()                                                 -- ��������� ����������� �����
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
������������� ��������� (p) ���� � ����, ������������ ��������
]]--
	res = math.floor(p / step) * step
	return math.abs(tonumber(res))
end

function position()
--[[
����������� ����� ����� � �������
�������� ������� �� ������ �����
]]--
	otkrito_lotov=0
	for i = 0,getNumberOf("depo_limits") - 1 do                            -- ������ �� "������� ������� �� �������"
		if getItem("depo_limits",i).sec_code == Sec_Code then              -- ���� ������ �� ������� ����������� ��
			if getItem("depo_limits",i).currentbal > 0 then                -- ���� ������� ������� > 0, �� ������� ������� ������� (BUY)
				BuyVol = getItem("depo_limits",i).currentbal	           -- ���������� ����� � ������� BUY
				otkrito_lotov=BuyVol
			else                                                           -- ����� ������� �������� ������� (SELL)
				SellVol = math.abs(getItem("depo_limits",i).currentbal)    -- ���������� ����� � ������� SELL
				otkrito_lotov=SellVol
			end
		end
	end
	return otkrito_lotov
end

function move_up() 
--[[
�������� ������ �����
������� ������� ������
���������� ���� �� ������� ������ ���� ������� (�� ������ �����)
� ���������� �����
]]--
	if get_timer() == false then                                                        --  ���� ������ ���������
		trader.DeleteOrder(agent,Class_Code,Sec_Code)                                   --  ������� ������
		set_file_info(sled_zaavka_short * -1)		                                    --  ���������� ���� � ���� �� ������ �����
		sleep(100)
		sled_zaavka_long = correct_price(sled_zaavka_short - sled_zaavka_short / 100 * spred)	
		sled_zaavka_short = correct_price(sled_zaavka_short + sled_zaavka_short / 100 * otstup)
		
		trader.kupit_po_cene(agent,Class_Code,Sec_Code,g_lots,sled_zaavka_long)         --  �������� �������
		if position() > reserve then                                                          --  ������� ������ ���� ���� ��� ���������
			trader.prodat_po_cene(agent,Class_Code,Sec_Code,g_lots,sled_zaavka_short)   --  �������� �������
		end
		set_timer(pause_size)                                                                    --  ���������� ������
	end
end

function move_down() 
--[[
�������� ������ ����
������� ������� ������
���������� ���� �� ������� ������ ���� ������
� ���������� �����
]]--
	if get_timer() == false then                                                        --  ���� ������ ���������
		trader.DeleteOrder(agent,Class_Code,Sec_Code)                                   --  ������� ������
		set_file_info(sled_zaavka_long)		                                            --  ���������� ���� � ����
		sleep(100)
		sled_zaavka_short = correct_price(sled_zaavka_long + sled_zaavka_long / 100 * spred)	
		sled_zaavka_long = correct_price(sled_zaavka_long - sled_zaavka_long / 100 * otstup)
		
		trader.kupit_po_cene(agent,Class_Code,Sec_Code,g_lots,sled_zaavka_long)         --  �������� �������
		if position() > reserve then                                                          --  ������� ������ ���� ���� ��� ���������
			trader.prodat_po_cene(agent,Class_Code,Sec_Code,g_lots,sled_zaavka_short)   --  �������� �������
		end
		set_timer(pause_size)                                                                    --  ���������� ������
	end
end

function is_price_up()  --  bool
--[[
��������� �� ���� ���� �������� ������ ������� 
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
��������� �� ���� ���� �������� ������ ������� 
]]--
	res = false
	last_pric = tonumber(last_price())
	if last_pric < sled_zaavka_long then
		res = true
	end
	return res
end
