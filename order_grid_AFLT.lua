--    ��� ������������ ��� ������� � ������� ����� �� �������� ����� �������, 
--    �� ���������� �� ������ ������ � ������ �������. 
--    ������ ������ ���������� � ���� �� ������ ����� ������� ��������� ����� ���������.
--    ���������� ���������� ������ ��� �������� ������� ���������� ������ ��� ����������������.
--    

require("m_trader")                    --  ������ ����� � �����������


-- ������������� ���������� ��������� ������� �������� ��������� ���������
Account = "L01-00000F00"               -- �������� ����
Class_Code = "TQBR"                    -- ����� ���������� �����������
Sec_Code = "AFLT"                      -- ��� ���������� �����������
firm_id = "MC0002500000"
agent = "order_grid_"..Sec_Code
g_lots = 1                             -- ���������� ��������� ���
is_run = true
in_lot = 1                             -- ����� � ����
spred = 1.2 						   -- ����� ����� ����� �������� � ���������
otstup = 0.2						   -- ������ �� ���������� ������ � ���������
price = 0

sled_zaavka_short = getParamEx(Class_Code, Sec_Code, "last").param_value
sled_zaavka_long = sled_zaavka_short
poslednaa_operacia=""
step=tonumber(getParamEx(Class_Code, Sec_Code, "SEC_PRICE_STEP").param_value)

file_name = agent.."_"..g_lots..".txt"
finish_timer = 0
start_timer = 0

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
	f = io.open(getScriptPath().."\\"..file_name,"r+")	-- ��������� ���� � ������ "������"
	for line in f:lines() do res = line end
	return tonumber(res)
end

function set_file_info(text)
--[[
������ �������� � ����.
������������ ���� �� ������� ������ ���� ��������� ������.
������� ������������ �� ������ �����
]]--
	f = io.open(getScriptPath().."\\"..file_name,"w")	-- ��������� ���� � ������ "������"
	f:write(text)                                    	-- ������ � ����
	f:flush()	                                        -- ��������� ��������� � �����
	f:close()                                       	-- ��������� ����
end

function checking_file()
--[[
������ �������� �����
�������� ������������� ������ ���� ������
]]--
	price = getParamEx(Class_Code, Sec_Code, "BID").param_value -- ������ ���� ������
	f = io.open(getScriptPath().."\\"..file_name,"r+")          -- �������� ������� ���� � ������ "������/������"
	if f == nil then                                            -- ���� ���� �� ����������
		f = io.open(getScriptPath().."\\"..file_name,"w")       -- ������� ���� � ������ "������"
		f:write(price)                                          -- ������ � ���� 
		f:flush()                                               -- ��������� ��������� � �����
	end
	f:close()                                                   -- ��������� ����
	sleep(1000)
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
	if vrema() >= 100000 and vrema() < 234800 then
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
]]--
	return tonumber(getParamEx(Class_Code, Sec_Code, "last").param_value)
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
	if is_price_up() then
		move_up() 
	end
	
	if is_price_down() then
		move_down()
	end
end

function first_orders()
--[[
����������� ������� ��� ������ � ������ ������ ����
]]--
	price = get_file_info() -- ��������� ���� �� �����
	if price > 0 then
		sled_zaavka_long = price
		sled_zaavka_short = correct_price(price + price / 100 * spred)
	end
	
	if get_file_info() < 0 then
		price = price * -1
		sled_zaavka_short = price
		sled_zaavka_long = correct_price(price - price / 100 * spred)
	end
end

function correct_price(p) 
--[[
������������� ��������� (p) ���� � ����, ������������ ��������
]]--
	res = math.floor(p / step) * step
	return tonumber(res)
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
		set_file_info(sled_zaavka_short * -1)		                                    --  ���������� ���� � ����
		sleep(100)
		
		sled_zaavka_long = correct_price(sled_zaavka_short - sled_zaavka_short / 100 * spred)
		sled_zaavka_short = correct_price(sled_zaavka_short + sled_zaavka_short / 100 * otstup)
		
		trader.kupit_po_cene(agent,Class_Code,Sec_Code,g_lots,sled_zaavka_long)         --  �������� �������
		if position() > 0 then                                                          --  ������� ������ ���� ���� ��� ���������
			trader.prodat_po_cene(agent,Class_Code,Sec_Code,g_lots,sled_zaavka_short)   --  �������� �������
		end
		set_timer(3)                                                                    --  ���������� ������
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
		if position() > 0 then                                                          --  ������� ������ ���� ���� ��� ���������
			trader.prodat_po_cene(agent,Class_Code,Sec_Code,g_lots,sled_zaavka_short)   --  �������� �������
		end
		set_timer(3)                                                                    --  ���������� ������
	end
end

function is_price_up()  --  bool
--[[
��������� �� ���� ���� �������� ������ ������� 
]]--
	res = false
	if last_price() > sled_zaavka_short then
		res = true
	end
	return res
end

function is_price_down()  --  bool
--[[
��������� �� ���� ���� �������� ������ ������� 
]]--
	res = false
	if last_price() < sled_zaavka_long then
		res = true
	end
	return res
end
