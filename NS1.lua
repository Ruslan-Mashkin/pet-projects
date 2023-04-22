--[[
��������
    NS1

��������
    ������ ������ ������������ �� ���� ��������� ������ �� ��������� QUIK,
	���������� �� ������ ��������� ������ � ���� ������ � ����������� ������.
	��������� ����������� ����� � �������� � ������� ������������ ��������� ���������.
	��������� � ��������, ���������� ������ ������, �������� ��������������. 
	
	
������
    1.0

���������
    ������ ������ (https://t.me/ruslan_mashkin )

���� ��������
    16.04.2023
]]--



------------------------------------------------- �������������� ���������� ���������� --------------------------
account = ""                  -- �������� ����
client_code = ""              -- ��� �������
script_name = "NS1"           -- �������� �������
is_running = true             -- ����, ����������� �������� �� ������
is_stopped = false            -- ����, ����������� ���������� �� ������
row_new_instrument = 0        -- ����� ������ � �������, ��� ����� ����������
clicked_row = 0               -- ����� ������ � ������� �������, ��� ��� ����
clicked_another_row = 0       -- ����� ������ � ������ ��������, ��� ��� ����
additional_window_height = 0  -- ������ �������������� ����
main_window_height = 0        -- ������ �������� ����
main_window_width = 0         -- ������ �������� ����
main_window_x_coord = 0       -- X-���������� �������� ����
main_window_y_coord = 0       -- Y-���������� �������� ����
rows_in_main_window = 0       -- ���������� ����� �������� ����
current_row_number = 0        -- ������� ����� ������ � �������
current_column_number = 0     -- ������� ����� ������� � �������
user_input = ""               -- ������ ����� ������������
native_folder_path = ""       -- ���� � �����
default_value_1 = 1           -- ��������� �������� ��� ������ �������
default_value_2 = 10          -- ��������� �������� ��� ������ �������
current_second = 0            -- ��� ����������� ������� � ��������� �������
Class_Code = "TQBR"           -- ����� ���������� �����������
Sec_Code = "SBERP"            -- ��� ���������� �����������
g_lots = 1                    -- ���������� ��������� ���


x_variable = 0                -- �������� �������
y_variable = 0                -- ������� �������
A_variable = 0                -- ������� ����� ��������� high � �������� �������
B_variable = 0                -- ������� ����� ������� � �������� ��������
-----------------------------------------------------------------------------------------------------------------

------------------------------------------------- �������������� ������� ������� --------------------------------

-- ������� �������� �������
QTable = {}
QTable.__index = QTable

-- ������� ������� �������
Class_Table = {}
Class_Table.__index = Class_Table

-- ������� ������� ������������
Sec_Table = {}
Sec_Table.__index = Sec_Table

-- ������� ������� ����������
Inf_Table = {}
Inf_Table.__index = Inf_Table

-- ������� ������� ��������
Task_Table = {}
Task_Table.__index = Task_Table

-- ������� ������� ��������� �����
Account_Table = {}
Account_Table.__index = Account_Table

-- ������� ������� ���� �������
CLIENT_CODE_Table = {}
CLIENT_CODE_Table.__index = CLIENT_CODE_Table
-----------------------------------------------------------------------------------------------------------------

------------------------------------------------- ������� ������� -----------------------------------------------

function OnStop()
--[[
��������
    ���������� ������� OnStop()

��������
    ������ ���������� ���������� ��� ��������� ��������� ������ �� ��������� QUIK.
	� ������� ���������� �������� ���� ��������� ������ � ��������� ����� is_stopped � true.

���������
    ��� ����������.

������������ ��������
    ��� ������������ ��������.
]]--
    -- ������������� ���� ��������� �������
    is_stopped = true
    
    -- ������������� ���� ������ ������� ��� false
    is_running = false
    
    -- ������� ��������� �������
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
��������: OnInit

��������:
    ������ ������� ���������� ��� ������ ������� ��������� ������ �� ��������� QUIK.

���������:
    p_ - ������. ���� � �����, � ������� �������� ������.

������������ ��������:
    ��� ������������ ��������.
]]--

	native_folder_path = tostring(p_)
end

function main()
--[[
��������
    ������� ������� ������� - main()

��������
    ������ ������� ��������� ������� ���� � ��������.
    ����� ������� �������� ��������� �������� ��� �������, ������� ����������� � ����������� �����. 
    ���� ���� is_stopped ���������� � true, �� ������� ��������� ������, ��� ���������������.
    ����� ������� �������� ������� Table_UpDate(), ������� ��������� ������ � ������� � ��������� ����������� ��������.

���������
    ��� ����������.

������������ ��������
    ��� ������������ ��������
]]--
	InitTable()                      -- ��������� ���� � ��������
	sleep(1000) 
	local sr=SetSelectedRow(t_id, 1) -- ��������� ����� �� ������ ������
	while is_running do              -- ����������� ����
		if is_stopped then           -- ���� ���� ��������� ����������, �� ������� �� �����
			return
		end
		sleep(100)                   -- ��������
		Table_UpDate()               -- ��������� ������ � �������
	end  --while
end  --function

function To_integer(n)
--[[
��������
    ������� �������������� ������ ����� � ����� ����� - To_integer()

��������
    ������ ������� �������� �� ���� ����� ����� � ����������� ��� � ����� �����. 
    ���� �������������� �� �������, �� ������� ���������� �������� nil.

���������
    ��������� �������:
    * n - ����� ����� , ������� ����� ������������� � ����� �����.

������������ ��������
    ������������ ��������:
    * ����� �����, ���� �������������� �������, ��� nil, ���� �� �������.
]]--
	return math.tointeger(tonumber(n))
end

function UpdateWindowTitle()
--[[
��������
    ������� ���������� ��������� ���� - UpdateWindowTitle()

��������
    ������ ������� ��������� ��������� �������� ����, �������� � ���� ������� ����� � ������� ����:������:�������.
	��� ����� � ��� ����� ��� ��������� ������ ������� 
���������
    ��� ����������.

������������ ��������
    ��� ������������ ��������.
]]--
	if current_second ~= tonumber(os.date("%S")) then                           -- ���������, ���������� �� ������� �������
		current_second = tonumber(os.date("%S"))                                -- ���� ����������, �� ��������� �������� ����������
		SetWindowCaption(tt, script_name.."         "..tostring(os.date("%X"))) -- ��������� ��������� ����
	end
end


function CalculateX(class, sec, period)
--[[
��������
    ������� ���������� �������� X - CalculateX()

��������
    ������ ������� ��������� �������� X ��� ����������� �� �������� ����������.

���������
    ��������� �������:
    * class - ����� �����������.
    * sec - ��� �����������.
    * period - ������ ���������� ������� ��� ���������� �������� X.

������������ ��������
    ������������ ��������:
    * �������� X ��� ��������� ����������� � ������� ���������� �������.
]]
	--���������� ������
	ds, Error = CreateDataSource(class, sec, tonumber(1440))
	-- ����, ���� ������ ����� �������� � ������� (�� ������, ���� ����� ������ �� ������)
	while (Error == "" or Error == nil) and ds:Size() == 0 do sleep(1) end
	if Error ~= "" and Error ~= nil then message("������ ����������� � �������: "..Error) end

	Size = ds:Size()                  -- ���������� ������� ������ (���������� ������ � ��������� ������)
	local sum = 0
	for i=1, period do
		sum = sum + ds:C(Size - i)    -- ����������� ����� �������� ������
	end
	ds:Close()                        -- ������� �������� ������, ������������ �� ��������� ������

	return sum / period               -- �������� � ���������� �������

end

function CalculateY(class, sec, period)
--[[
��������
    ������� ���������� �������� Y - CalculateY()

��������
    ������ ������� ��������� �������� Y ��� ����������� �� �������� ����������.

���������
    ��������� �������:
    * class - ����� �����������.
    * sec - ��� �����������.
    * period - ������ ���������� ������� ��� ���������� �������� Y.

������������ ��������
    ������������ ��������:
    * �������� Y ��� ��������� ����������� � ������� ���������� �������.
]]	
	--���������� ������
	ds, Error = CreateDataSource(class, sec, tonumber(1440))
	-- ����, ���� ������ ����� �������� � ������� (�� ������, ���� ����� ������ �� ������)
	while (Error == "" or Error == nil) and ds:Size() == 0 do sleep(1) end
	if Error ~= "" and Error ~= nil then message("������ ����������� � �������: "..Error) end

	Size = ds:Size()                -- ���������� ������� ������ (���������� ������ � ��������� ������)
	local sum = 0
	for i=1, period do
		sum = sum + ds:C(Size - i)  -- ����������� ����� �������� ������
	end
	ds:Close()                      -- ������� �������� ������, ������������ �� ��������� ������

	return sum / period             -- �������� � ���������� �������

end

function isValidPositiveNumber(n)
--[[
��������
    ������� �������� ������������ �������� ���������� - isValidPositiveNumber()
	
��������
    ������ ������� ��������� ������������ ����������� �������� ����������.
	
���������
    ��������� �������:
    * n - ����������� �������� ����������.

������������ ��������
    * ���������� true, ���� ���������� �������� ��������� (����� ������ 0), ����� - false.
]]  
	res = false                                                 -- ������������� �������� ���������� � ����
	if n == nil or type(n) == "string" or n == "" or n <=0 then -- ��������� �������� �� nil, ��� "string", ������ ������ � �������������/������� �����
		res = false                                             -- ���� �������� �� ������������� �����������, �� ������������� ��������� � ����
	else
		res = true                                              -- ����� ������������� ��������� � ������
	end
	return res                                                  -- ���������� ��������� ���������� �������
end

function YesterdayHigh(class, sec)
--[[
��������
    ������� ��������� ������������� �������� �� ��������� ���� - YesterdayHigh()

��������
    ������ ������� �������� ������������ �������� �� ��������� ���� ��� ��������� �����������.

���������
    ��������� �������:
    * classcod - ����� �����������.
    * seccod - ��� �����������.

������������ ��������
    * ������������ �������� �� ��������� ���� ��� ��������� �����������.
]]  
	ds, Error = CreateDataSource(class, sec, tonumber(1440))
	-- ����, ���� ������ ����� �������� � ������� (�� ������, ���� ����� ������ �� ������)
	while (Error == "" or Error == nil) and ds:Size() == 0 do sleep(1) end
	if Error ~= "" and Error ~= nil then message("������ ����������� � �������: "..Error) end

	Size = ds:Size()     -- ���������� ������� ������ (���������� ������ � ��������� ������)
	res = ds:H(Size - 1) -- �������� ��������� high
	ds:Close()           -- ������� �������� ������, ������������ �� ��������� ������
	
	return res

end

function Position(sec)
--[[
��������
    Position - ������� ����������� ����� ����� � �������.

��������
    ������ ������� ���������� ���������� ����� � ������� ������� �� ��������� �����������. 
    ������������� �������� ��������� �� �������� ������� ������� (BUY), ������������� � �� �������� �������� ������� (SELL).

���������
    sec (string) - ��� �����������.

������������ ��������
    ����� �����, ���������� ����� � �������.
]]

	position_size = 0
	for i = 0,getNumberOf("depo_limits") - 1 do                 -- ������ �� "������� ������� �� �������"
		if getItem("depo_limits",i).sec_code == sec then        -- ���� ������ �� ������� ����������� ��
			if getItem("depo_limits",i).currentbal > 0 then     -- ���� ������� ������� > 0, �� ������� ������� ������� (BUY)
				BuyVol = getItem("depo_limits",i).currentbal	-- ���������� ����� � ������� BUY
				position_size=BuyVol
			else                                                -- ����� ������� �������� ������� (SELL)
				SellVol = getItem("depo_limits",i).currentbal   -- ���������� ����� � ������� SELL
				position_size=SellVol
			end
		end
	end
	return position_size
end

function Last_price(class, sec)
--[[
��������
    Last_price - ������� ��������� ������� ���� ��������� �����������.

��������
    ������ ������� ���������� ������� ���� ��������� �����������.

���������
    class (string) - ��� ������ �����������.
    sec (string) - ��� �����������.

������������ ��������
    �����, ������� ���� ��������� �����������.
]]
	return tonumber(getParamEx(class, sec, "LAST").param_value)
end

function Lot_size(class, sec)
--[[
��������
    Lot_size - ������� ��������� ���������� ����� � ���� �����������.

��������
    ������ ������� ���������� ���������� ����� � ���� ��������� �����������.

���������
    class (string) - ��� ������ �����������.
    sec (string) - ��� �����������.

������������ ��������
    ����� �����, ���������� ����� � ���� ��������� �����������.
]]
    return tonumber(getParamEx(class, sec, "LOTSIZE").param_value)
end


function Avg_position_price(class, sec)
--[[
��������
    Avg_position_price - ������� ��������� ������� ���� �������� ������� �� ��������� �����������.

��������
    ������ ������� ���������� ������� ���� ������������ �������� ������� �� ��������� �����������.

���������
    class (string) - ��� ������ �����������.
    sec (string) - ��� �����������.

������������ ��������
    �����, ������� ���� ������������ �������� ������� ��������� �����������.
]]

  local avg_price = 0
  for i = 0, getNumberOf("depo_limits") - 1 do                  -- ������ �� "������� ������� �� �������"
    if getItem("depo_limits", i).sec_code == sec then           -- ���� ������ �� ������� ����������� ��
      avg_price = getItem("depo_limits", i).awg_position_price  -- ������� ���� ������������ �������� �������
    end
  end
  return tonumber(avg_price)
end

function Min_price_step(class, sec)
--[[
��������
    Min_price_step - ������� ��������� ������������ ���� ���� ��� ���������� �����������.

���������
    class (string) - ��� ������ �����������.
    sec (string) - ��� �����������.

������������ ��������
    �����, ����������� ��� ���� ��� ����������� �����������.
]]
	step=tonumber(getParamEx(Class_Code, Sec_Code, "SEC_PRICE_STEP").param_value) -- ����������� ��� ����
	return step
end

function CorrectPrice(class, sec, p) 
--[[
��������
    CorrectPrice - ������� ������������� ��������� ���� � ����, ������������ ��������.

���������
    class (string) - ��� ������ �����������.
    sec (string) - ��� �����������.
    p (number) - ��������� ����.

������������ ��������
    �����, ����������������� ���� � ����, ������������ ��������.
]]
	local step = Min_price_step(class, sec)       -- �������� ����������� ��� ����
	res = math.floor(p / step) * step             -- �������� ���������� ����
	if step == 1 orstep == 10 or step == 100 then -- ���� ��� ���� ����� ����� 
		res = To_integer(res)                     -- �� ���� ������������� � �������������� �������� 
	end
	return math.abs(tonumber(res))
end


function CalcIndentPrice(class, sec, price, percent)
--[[
��������
    CalcIndentPrice - ������� ������� ���� ������� �� ���������� ����.

��������
    ������ ������� ������������ ���� ������� �� ���������� ���� � ����������� �� ��������� ��������.

���������
    class (string) - ��� ������ �����������.
    sec (string) - ��� �����������.
    price (number) - ���������� ����.
    percent (number) - �������, �� ������� ���������� �������� ����.

������������ ��������
    �����, ���� ������� ��� ���������� ���� � ������ ��������� ��������.
]]
    local indent_price = price - price / 100 * percent  --������������ ���� �� �������� ������� �� ���������� ����
    return CorrectPrice(class, sec, indent_price)
end

function CheckAllCellsFilled(i)
--[[
��������
    CheckAllCellsFilled - ������� �������� ���������� ���� ����� � ������ �������.

��������
    ������ ������� ��������� ���������� ���� ����� � ���������� ������ �������.

���������
    i (number) - ����� ������ � �������.

������������ ��������
    true, ���� ��� ������ ��������� ���������, ����� - false.
]]
	-- ������������� ���������� ��� �������� ���������� ��������.
	res = false

	-- ��������� �������� �� ����� ������� � �������������� � �������� ������.
	local a = tonumber(GetCell(tt, i, 108)["image"])     
	local b = tonumber(GetCell(tt, i, 109)["image"])            
	local c = tonumber(GetCell(tt, i, 114)["image"])
	local d = tonumber(GetCell(tt, i, 115)["image"]) 
	local e = tonumber(GetCell(tt, i, 116)["image"])

	-- �������� ������������ ���������� �����, ����� ������� isValidPositiveNumber ��� ������ �� ���.
	if isValidPositiveNumber(a) and isValidPositiveNumber(b) and isValidPositiveNumber(c) and isValidPositiveNumber(d) and isValidPositiveNumber(e) then

		-- ���� ��� ������ ��������� ���������, �� ���������� �������� ������������� �������� true.
		res = true
	end
  
	-- ������� �������� ���������� ��������.
	return res
end

function MarketBuy(class, sec, number_lots)
--[[
��������
    MarketBuy - ������� �������� ������� ����� �������� �������.

��������
    ������ ������� ������������ �������� ������� ����� �������� ������� �����������.

���������
    class (string) - ��� ������ �����������
    sec (string) - ��� �����������
    number_lots (number) - ���������� �����

������������ ��������
    true, ���� ���������� ������� ����������, ����� false.
]]
	local trans_params =
	{
		CLIENT_CODE = client_code,
		CLASSCODE = class,                      -- ��� ������
		SECCODE = sec,      		            -- ��� �����������	
		ACCOUNT = account,   			        -- ��� �����
		TYPE = "M",        		                -- ��� ('L' - ��������������, 'M' - ��������)
		TRANS_ID = tostring(os.time()),         -- ����� ����������
		OPERATION = "B",         			    -- �������� ('B' - buy, ��� 'S' - sell)	
		QUANTITY = tostring(number_lots),       -- ����������
		PRICE = "0",                            -- ����
		ACTION = "NEW_ORDER"                    -- ��� ���������� ('NEW_ORDER' - ����� ������)
	}
	local res = sendTransaction(trans_params)   -- �������� ����������
	if is_running and string.len(res) ~= 0 then -- ���� ���������� �� ���������
		message(tostring(getSecurityInfo(class,sec).short_name).."   ���������� �� ������  ".. tostring(res)) -- ����� ��������� �� ������
		return false
	else -- ����� �� ��������� ���������
		return true
	end 
end

function MarketSell(class, sec, number_lots)
--[[
��������
    MarketSell - ������� �������� ������� ����� �������� �������.

��������
    ������ ������� ������������ �������� ������� ����� �������� ������� �����������.

���������
    class (string) - ��� ������ �����������
    sec (string) - ��� �����������
    number_lots (number) - ���������� �����

������������ ��������
    true, ���� ���������� ������� ����������, ����� false.
]]
	local trans_params =
	{
		CLIENT_CODE = client_code,
		CLASSCODE = class,                      -- ��� ������
		SECCODE = sec,      		            -- ��� �����������	
		ACCOUNT = account,   			        -- ��� �����
		TYPE = "M",        		                -- ��� ('L' - ��������������, 'M' - ��������)
		TRANS_ID = tostring(os.time()),         -- ����� ����������
		OPERATION = "S",         			    -- �������� ('B' - buy, ��� 'S' - sell)	
		QUANTITY = tostring(number_lots),       -- ����������
		PRICE = "0",                            -- ����
		ACTION = "NEW_ORDER"                    -- ��� ���������� ('NEW_ORDER' - ����� ������)
	}
	local res = sendTransaction(trans_params)   -- �������� ����������
	if is_running and string.len(res) ~= 0 then -- ���� ���������� �� ���������
		message(tostring(getSecurityInfo(class,sec).short_name).."   ���������� �� ������  ".. tostring(res)) -- ����� ��������� �� ������
		return false
	else -- ����� �� ��������� ���������
		return true
	end 

end

function OpenPosition(class, sec, number_lots)
--[[
��������
    OpenPosition - ������� �������� �������.

��������
    ������ ������� ������������ �������� ������� ����� �������� ������� �����������.

���������
    class (string) - ��� ������ �����������
    sec (string) - ��� �����������
    number_lots (number) - ���������� �����

������������ ��������
    ���


]]
	MarketBuy(class, sec, number_lots)  -- ����� ������� MarketBuy ��� �������� �������
end

function Delayed_Order(class, sec, number_lots, price)
--[[
��������
    Delayed_Order - ������� ����������� ����������� ������ ���� ����-������.

��������
    ������ ������� ������������ ����������� ����������� ������ ���� ����-������ ����� �������� ���������� �� �����.

���������
    class (string) - ��� ������ �����������
    sec (string) - ��� �����������
    number_lots (number) - ���������� �����
    price (number) - ���� ����-�������

������������ ��������
    true, ���� ���������� ������� ����������, ����� false.


]]
	local trans_params =
		{
		["ACTION"]              = "NEW_STOP_ORDER",         -- ��� ������
		["TRANS_ID"]            = tostring(os.time()),      -- ����� ����������
		["CLASSCODE"]           = class,
		["SECCODE"]             = sec,
		["ACCOUNT"]             = account,
		["OPERATION"]           = "B",                      -- �������� ("B" - �������(BUY), "S" - �������(SELL))
		["QUANTITY"]            = tostring(number_lots),    -- ���������� � �����
		["PRICE"]               = tostring(0),              -- ����, �� ������� ���������� ������ ��� ������������ ����-����� (��� �������� ������ �� ������ ������ ���� 0)
		["STOPPRICE"]           = tostring(price),          -- ���� ����-�������
		["STOP_ORDER_KIND"]     = "TAKE_PROFIT_STOP_ORDER", -- ��� ����-������
		["EXPIRY_DATE"]         = "TODAY",                  -- ���� �������� ����-������ ("GTC" � �� ������,"TODAY" - �� ��������� ������� �������� ������, ���� � ������� "������")
		["OFFSET"]              = tostring(0),
		["OFFSET_UNITS"]        = "PERCENTS",               -- ������� ��������� ������� ("PRICE_UNITS" - ��� ����, ��� "PERCENTS" - ��������)
		["SPREAD"]              = tostring(0),
		["SPREAD_UNITS"]        = "PERCENTS",               -- ������� ��������� ��������� ������ ("PRICE_UNITS" - ��� ����, ��� "PERCENTS" - ��������)
      -- "MARKET_TAKE_PROFIT" = ("YES", ��� "NO") ������ �� ���������� ������ �� �������� ���� ��� ������������ ����-�������.
      -- ��� ����� FORTS �������� ������, ��� �������, ���������,
      -- ��� �������������� ������ �� FORTS ����� ��������� �������� ������ ����, ����� ��� ��������� ����� ��, ��� ��������
	    --["MARKET_TAKE_PROFIT"]  = "YES",
		["STOPPRICE2"]          = tostring(0),              -- ���� ����-����� 
		["IS_ACTIVE_IN_TIME"]   = "NO",
		["CLIENT_CODE"]         = tostring(client_code)
		}
	local res = sendTransaction(trans_params)
	if is_running and string.len(res) ~= 0 then           -- ���� ���������� �� ���������
		message(tostring(getSecurityInfo(class,sec).short_name).."   ���������� �� ������  ".. tostring(res)) -- ����� ��������� �� ������
		return false
	else -- ����� �� ��������� ���������
		return true
	end 
end

function ClosePosition(class, sec, number_lots)
--[[
��������
    ClosePosition - ������� �������� �������.

��������
    ������ ������� ������������ �������� ������� ����� �������� ������� �����������.

���������
    class (string) - ��� ������ �����������
    sec (string) - ��� �����������
    number_lots (number) - ���������� �����

������������ ��������
    ���
]]
	MarketSell(class, sec, number_lots)  -- ����� ������� MarketSell ��� �������� �������
 end

function Delete_Delayed_Order(class, sec)
--[[

��������
    Delete_Delayed_Order - ������� �������� ���������� ������.

��������
    ������ ������� ������������ �������� ���������� ������ �� ������.

���������
    class (string) - ��� ������ �����������
    sec (string) - ��� �����������

������������ ��������
    true - ���� ���������� ���� ���������
    false - ���� ���������� �� ���� ���������

]]
	for i = 0,getNumberOf("stop_orders") - 1 do                     -- ������������ ��� ���������� ������ �� ������, ������� ��������� � ������� "stop_orders"
		if getItem("stop_orders",i).sec_code == sec then            -- ���� ������ �� ������� ����������� �� ����� ����
			order=getItem("stop_orders",i).flags
			if bit.band(order,1)>0 then                             -- ���� ���������� ������ - ��� ����-������ ���� "����-������" (������� ����� � ������� 1)
				order_num = getItem("stop_orders",i).order_num      -- ��������� ������ ������
				local trans_params =                                -- �������� ������� ���������� ����������
					{
					["ACTION"] = "KILL_STOP_ORDER",                 -- �������� - �������� ���������� ������
					["TRANS_ID"] = tostring(os.time()),             -- ���������� ������������� ����������
					["CLASSCODE"] = class,                          -- ��� ������ �����������
					["SECCODE"] = sec,                              -- ��� �����������
					["ACCOUNT"] = account,                          -- ����� �����
					["STOP_ORDER_KIND"] = "TAKE_PROFIT_STOP_ORDER", -- ��� ����-������ (����-������)
					["CLIENT_CODE"] = tostring(client_code),        -- ��� �������
					['STOP_ORDER_KEY'] = tostring(order_num)        -- ����� ��������� ������
					}
				local res = sendTransaction(trans_params)           -- ����������� ���������� �� �������� ���������� ������
				if is_running and string.len(res) ~= 0 then         -- ���� ���������� �� ���������
					message(tostring(getSecurityInfo(class,sec).short_name).."   ���������� �� ������  ".. tostring(res)) -- ����� ��������� �� ������
					return false -- ������������ false
				else -- �����
					return true -- ������������ true
				end 
			end
		end
	end  
end
 
function Table_UpDate()
--[[
��������
    Table_UpDate - ������� ���������� ������ � ������� �������.

��������
    ������ ������� ��������� ������ (����, ���������� ����� � ����, ��������� ����, �������� X � Y ����������, 
    ������������ �������� �� ��������� ���� � �������� A ����������) � ������� �������.

���������
    ��� ����������.

������������ ��������
    ��� ������������ ��������.
]]  
  UpdateWindowTitle()                    -- ��������� ��������� �������� ����
  
	for i = 1, rows_in_main_window do    -- ������� ����� ������� �������
		lot_size = 0                     -- ���������� ����� � ����
		lot_price = 0                    -- ��������� ����
		last_price = 0                   -- ��������� ����
		
		-- ���� ������ � ������������
		if is_running and tostring(GetCell(tt,i,3)["image"])~="" then
		  
			local classcod = tostring(GetCell(tt,i,2)["image"])          -- ����� ����������� �� �������
			local seccod = tostring(GetCell(tt,i,3)["image"])            -- ��� ����������� �� �������

			last_price =  tonumber(Last_price(classcod, seccod))         -- �������� ��������� ���� �����������
			SetCell(tt, i, 5, tostring(last_price))                      -- ���������� ���� � �������

			lot_size =  To_integer(tonumber(Lot_size(classcod, seccod))) -- �������� ���������� ����� � ����
			SetCell(tt, i, 6, tostring(lot_size))                        -- ���������� ����� ����� � ���� � �������

			lot_price = last_price * lot_size                            -- ��������� ��������� ����
			SetCell(tt, i, 7, tostring(lot_price))                       -- ���������� ��������� ���� � �������

			x_period = tonumber(GetCell(tt,i,108)["image"])              -- �������� �������� ������� ��� ������� �-������� �� �������
			y_period = tonumber(GetCell(tt,i,109)["image"])              -- �������� �������� ������� ��� ������� Y-������� �� �������
			number_lots1 = tonumber(GetCell(tt,i,114)["image"])          -- �������� ����� ����� ��� �������� ������� �� �������
			number_lots2 = tonumber(GetCell(tt,i,115)["image"])          -- �������� ����� ����� ��� ���������� �� �������
			indent_percent = tonumber(GetCell(tt,i,116)["image"])        -- �������� ������� ������� �� �������
			
			yesterday_high = YesterdayHigh(classcod, seccod)             -- �������� ������������ �������� �� ��������� ���� ��� ��������� �����������
			SetCell(tt, i, 12, tostring(yesterday_high))                 -- ���������� ������������ �������� �� ��������� ���� � �������

			if isValidPositiveNumber(x_period) and isValidPositiveNumber(y_period) then              -- ���� �������� ��� �������� ��������� (������ 0)
				x_variable = CalculateX(classcod, seccod, x_period)      -- ��������� �������� � ����������
				SetCell(tt, i, 10, tostring(x_variable))                 -- ���������� �������� � ���������� � �������

				y_variable = CalculateY(classcod, seccod, y_period)      -- ��������� �������� Y ����������
				SetCell(tt, i, 11, tostring(y_variable))                 -- ���������� �������� Y ���������� � �������

				A_variable = yesterday_high - x_variable                 -- ��������� �������� A ����������
				SetCell(tt, i, 13, tostring(A_variable))                 -- ���������� �������� A ���������� � �������

				B_variable = y_variable - x_variable                     -- ��������� �������� B ����������
				SetCell(tt, i, 14, tostring(B_variable))                 -- ���������� �������� B ���������� � �������
			end
			pos = To_integer(tonumber(Position(seccod)))
			SetCell(tt, i, 16, tostring(pos))                            -- ���������� ������ ������� � �������
			avg_pos_price = tonumber(Avg_position_price(classcod, seccod))
			SetCell(tt, i, 15, tostring(avg_pos_price))                  -- ���������� �������� ������� ���� ������� � �������

			--    ���� �������� ������� � ���� ������� ��������� (������ 0), �� ������������ ������ ���� ������� 
			if indent_percent ~= nil and avg_pos_price ~= nil and indent_percent >0 and avg_pos_price > 0 then
				indent_price = CalcIndentPrice(classcod, seccod, avg_pos_price, indent_percent)
				SetCell(tt, i, 17, tostring(indent_price))               -- ���������� �������� ���� ������� � �������
			end
			----------------------------------------  �������� ������  --------------------------------------------------
			if CheckAllCellsFilled(i) then                               -- ���� ��� ������������� ��������� ���������
				if is_running and tostring(GetCell(tt,i,1)["image"])== "���������" then 
					if pos == 0 then  -- ���� ������� �����������
						if A_variable > 0 then
							OpenPosition(classcod, seccod, number_lots1)                                    -- ��������� �������
							sleep(3000)
							avg_pos_price = tonumber(Avg_position_price(classcod, seccod))                  -- �������� �������� ������� ���� �������
							indent_price = CalcIndentPrice(classcod, seccod, avg_pos_price, indent_percent) -- ��������� ���� ������� 
							Delayed_Order(classcod, seccod, number_lots2, indent_price)                     -- ������� ���������� �����
						end	
					end
					
					if pos > 0 then -- ���� ������� ����������
						if A_variable < 0 then
							ClosePosition(classcod, seccod, pos)         -- ��������� �������
							Delete_Delayed_Order(classcod, seccod)       -- ������� ���������� �����
							sleep(3000)
						end
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------

--==========================================================���� ������� QTable=====================================================================================
-- ������� ������������� �������
function QTable.new()
--[[
��������
    QTable.new - ������� ������������� �������.

��������
    ������ ������� ������� ����� ������� ��� ������ ���������� �� �������� QUIK. 

���������
    ���

������������ ��������
    ���������� ������-������� ��� nil, ���� �������� ������� �� �������.

�����������
    ������� ���������� ������� AllocTable() ��� �������� ������� � ���������� ������-������� ��� ������������ �������������. 

    ��� �������� ����� ������� ���������������� ��������� ���������:
        - t_id (number) - ������������� �������
        - caption (string) - ��������� �������
        - created (boolean) - ����, �����������, ���� �� ������� ������� �������
        - curr_col (number) - ������ ������� �������
        - columns (table) - ������� � ��������� ���������� ��������

]]
    t_id = AllocTable()          -- �������� ����� �������
    if t_id ~= nil then          -- �������� ���������� �������� �������
        q_table = {}
        setmetatable(q_table, QTable)
        q_table.t_id=t_id        -- ������������ �������������� �������
        q_table.caption = ""     -- ������������ ��������� �������
        q_table.created = false  -- ����, �����������, ��� ������� ��� �� ���� �������
        q_table.curr_col=0       -- ��������� �������� ������� �������
        -- ������� � ��������� ���������� ��������
        q_table.columns={}       -- ������������� ������ ��������
        return q_table           -- ����������� ������-�������
    else
        return nil  -- ����������� nil, ���� �������� ������� �� �������
    end
end
--������� � �������������� ��������� ������� QTable
test_table = QTable:new()
-- ������� ������������� �������


function InitTable()
    tt = test_table.t_id
		AddColumn(tt, 1, "", true,QTABLE_STRING_TYPE,25)
		AddColumn(tt, 2, " ��� ������", true,QTABLE_STRING_TYPE,14)
		AddColumn(tt, 3, " ��� ������", true,QTABLE_STRING_TYPE,14)
		AddColumn(tt, 4, " ������", true,QTABLE_STRING_TYPE,16)
		AddColumn(tt, 5, " ���� ������", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 6, " ����� � ����", true,QTABLE_INT_TYPE,16)
		AddColumn(tt, 7, " ��������� ����", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 10, " x ������� ��������", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 11, " y ������� ��������", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 12, " High ��������� ", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 13, " A ����������", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 14, " B ����������", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 15, " ���� �������", true,QTABLE_STRING_TYPE,15)
		
		AddColumn(tt, 16, " ������ �������", true,QTABLE_INT_TYPE,15)
		AddColumn(tt, 17, " ���� �������", true,QTABLE_STRING_TYPE,15)
		AddColumn(tt, 18, " ", true,QTABLE_STRING_TYPE,15)
		
		AddColumn(tt, 108, " x ������ (������������� ��������)", true,QTABLE_INT_TYPE,15)
		AddColumn(tt, 109, " y ������ (������������� ��������)", true,QTABLE_INT_TYPE,15)
		AddColumn(tt, 114, " ����� ����� ��� �������� ������� (������������� ��������)", true,QTABLE_INT_TYPE,15)
		AddColumn(tt, 115, " ����� ����� ��� ���������� (������������� ��������)", true,QTABLE_INT_TYPE,15)
		AddColumn(tt, 116, " ������� ������� (������������� ��������)", true,QTABLE_INT_TYPE,15)

    CreateWindow(tt)
    -- ����������� ���� ���������
    SetWindowCaption(tt, script_name)
    -- ������ ������� ����
	main_window_x_coord=0
	main_window_y_coord=0
	main_window_height=40+15+15+16
	main_window_width=1300
    SetWindowPos(tt, main_window_x_coord, main_window_y_coord, main_window_width, main_window_height)
	--������
	row = InsertRow(tt, -1)
	SetCell(tt, 1, 1, "�������� ����������")
	rows_in_main_window = rows_in_main_window + 1
	
	-- ��������� ��������� ������� ������
	local color_back = RGB(230,230,255)
	for i=2,99,2 do
		SetColor(tt, QTABLE_NO_INDEX, i, color_back, RGB(0,0,0), color_back, RGB(0,0,0))
	end
	-- ���� ������������� ����������
	local color_back = RGB(111,255,111)
		for i=100, 116 do
		SetColor(tt, QTABLE_NO_INDEX, i, color_back, RGB(0,0,0), color_back, RGB(0,0,0))
	end

    -- ������������� �� �������
    SetTableNotificationCallback(tt, OnTableEvent)
end

-- ������� ������������ ������� � �������
function OnTableEvent(t_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		OnStop()
		is_stopped = true
		is_running=false
	end
	if is_running and msg==11 then
		--��������� ������
		Highlight(task_id,par1,par2,000255000,2,500)
		current_row_number = 0
		current_column_number = 0
	end
	if is_running and par2>1 and msg==11 then
		current_row_number = par1
		current_column_number = par2
		user_input = ""
	end

	if is_running and msg==11 then --������� ����� ������ ����
		--��������� ������
		Highlight(t_id,par1,par2,000255000,2,500)	
	end
		--��� ����� �� "�������� ���������� "
	if is_running and par2==1 and msg==11 then
		if tostring(GetCell(tt,par1,1)["image"])=="�������� ����������" then
			row_new_instrument = tonumber(par1)
			InitTable_C() --  ��������� ���� � �������� �������
		end
		-- ���������
		if tostring(GetCell(tt,par1,1)["image"])=="��������" then
			clicked_row = tonumber(par1)
			InitTable_task() --  ��������� ���� � �������� ��������
		end
		if tostring(GetCell(tt,par1,1)["image"])=="���������" then 
			clicked_row = tonumber(par1)
			Class_Code = GetCell(tt,par1,2)["image"]
			Sec_Code = GetCell(tt,par1,3)["image"]
			SetCell(tt, clicked_row, 1, "��������")
		end
	end
	-- ���� �� �������� �����������
	if is_running and (par2==3 or par2==4) and msg==11 and tostring(GetCell(tt,par1,par2)["image"])~="" then
			clicked_row = tonumber(par1)
			InitTable_inf() --  ��������� ���� � ��������
	end
	-- ������� ������ ����������
	if is_running and msg==6 then
		if current_column_number >= 100 
		and current_row_number < rows_in_main_window then

			-- �����
			if par2 >=48 and par2 <=57 then
				user_input = user_input..tostring(par2-48)
			end
			-- �����
			if par2 == 46 then
				user_input = user_input.."."
			end
			if par2 == 45 then
				user_input = user_input.."-"
			end
			-- ��� �����
			if par2 == 8 then
				user_input = ""
			end
			SetCell(tt, current_row_number, current_column_number, user_input)
			-- ����
			if par2 == 13 then
				user_input = ""
				current_column_number = current_column_number + 1
				Highlight(t_id,current_row_number,current_column_number,000255000,2,100)
			end
		end
	end

end
--============================================================����� ���� �������======================================================================================
--==========================================================���� ������� Account_Table=====================================================================================
-- ������� ������������� �������
function Account_Table.new()
    a_id = AllocTable()
    if a_id ~= nil then
        a_table = {}
		setmetatable(a_table, Account_Table)
		a_table.a_id=a_id
		a_table.caption = ""
		a_table.created = false
		a_table.curr_col=0
		-- ������� � ��������� ���������� ��������
		a_table.columns={}
		return a_table
    else
        return nil
    end
end
--������� � �������������� ��������� ������� Account_Table
test_a_table = Account_Table:new()
-- ������� ������������� �������
function InitTable_A()
    att = test_a_table.a_id
	sleep(10)
	AddColumn(att, 1, "�����", true,QTABLE_STRING_TYPE,25)
	AddColumn(att, 2, "��������", true,QTABLE_STRING_TYPE,44)
    CreateWindow(att)
    -- ����������� ���� ���������
    SetWindowCaption(att, "�����")
    -- ������ ������� ����
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
    -- ������������� �� �������
    SetTableNotificationCallback(att, OnTable_Event_a)
end
-- ������� ������������ ������� � �������
function OnTable_Event_a(a_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		--SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--��������� ������
		Highlight(a_id,par1,par2,000255000,2,500)
		-- ��� ������?
		account = tostring(GetCell(a_id,par1,1)["image"])
		--message(Class_Code)
		SetCell(tasktt, clicked_another_row, 7, account)
		DestroyTable(a_id)
		test_a_table = Account_Table:new()
	end
end
--============================================================����� ���� �������======================================================================================
--==========================================================���� ������� CLIENT_CODE_Table=====================================================================================
-- ������� ������������� �������
function CLIENT_CODE_Table.new()
    cc_id = AllocTable()
    if cc_id ~= nil then
       cc_table = {}
		setmetatable(cc_table, CLIENT_CODE_Table)
		cc_table.cc_id=cc_id
		cc_table.caption = ""
		cc_table.created = false
		cc_table.curr_col=0
		-- ������� � ��������� ���������� ��������
		cc_table.columns={}
		return cc_table
    else
        return nil
    end
end
--������� � �������������� ��������� ������� CLIENT_CODE_Table
test_cc_table = CLIENT_CODE_Table:new()
-- ������� ������������� �������
function InitTable_CC()
    cctt = test_cc_table.cc_id
	sleep(10)
	AddColumn(cctt, 1, "���� �������", true,QTABLE_STRING_TYPE,25)
    CreateWindow(cctt)
    -- ����������� ���� ���������
    SetWindowCaption(cctt, "���� �������")
    -- ������ ������� ����
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
    -- ������������� �� �������
    SetTableNotificationCallback(cctt, OnTable_Event_cc)
end
-- ������� ������������ ������� � �������
function OnTable_Event_cc(cc_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		--SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--��������� ������
		Highlight(cc_id,par1,par2,000255000,2,500)
		-- ��� ������?
		client_code = tostring(GetCell(cc_id,par1,1)["image"])
		--message(Class_Code)
		SetCell(tasktt, clicked_another_row, 8, client_code)
		DestroyTable(cc_id)
		test_cc_table = CLIENT_CODE_Table:new()
	end
end

--============================================================����� ���� �������======================================================================================

--==========================================================���� ������� Task_Table=====================================================================================
-- ������� ������������� �������
function Task_Table.new()
    task_id = AllocTable()
    if task_id ~= nil then
        task_table = {}
		setmetatable(task_table, Task_Table)
		task_table.task_id=task_id
		task_table.caption = ""
		task_table.created = false
		task_table.curr_col=0
		-- ������� � ��������� ���������� ��������
		task_table.columns={}
		return task_table
    else
        return nil
    end
end
--������� � �������������� ��������� ������� Task_Table
test_task_table = Task_Table:new()
-- ������� ������������� �������
function InitTable_task()
    tasktt = test_task_table.task_id
		sleep(10)
		AddColumn(tasktt, 1, "��������", true,QTABLE_STRING_TYPE,16)
		AddColumn(tasktt, 7, "�������� ����", true,QTABLE_STRING_TYPE,16)
		AddColumn(tasktt, 8, "��� �������", true,QTABLE_STRING_TYPE,16)
    CreateWindow(tasktt)
    -- ����������� ���� ���������
    SetWindowCaption(tasktt, "�������� ��� "..GetCell(tt,clicked_row,4)["image"])
    -- ������ ������� ����
	ox=0
	oy=0
	additional_window_height=40+16
	window_width=300
	class_list = getClassesList() -- ������ �������
	class_list=string.sub(class_list, 1, -2)
	vo=0
	row = InsertRow(tasktt, -1)
	SetColor(tasktt, 1, 1, RGB(0, 255, 0), RGB(0, 0, 0), RGB(0, 255, 0), RGB(0, 0, 0))
	SetCell(tasktt, 1, 1, "��������")
	SetCell(tasktt, 1, 7, account)
	SetCell(tasktt, 1, 8, client_code)

	SetWindowPos(tasktt, ox, additional_window_height+16, window_width, additional_window_height+vo+15)
    -- ������������� �� �������
    SetTableNotificationCallback(tasktt, OnTable_Event_task)
end

-- ������� ������������ ������� � �������
function OnTable_Event_task(task_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		--is_stopped = true
		--is_running=false
	end
	if is_running and msg==11 then
		--��������� ������
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
		InitTable_A() --  ��������� ���� � �������� ��������
	end
	if is_running and par2==8 and msg==11 then
		clicked_another_row = tonumber(par1)
		InitTable_CC() --  ��������� ���� � �������� ��������
	end
	--���� �� "��������"
	if is_running and par2==1 and msg==11 then
		if tostring(GetCell(tasktt,par1,1)["image"])=="��������" then
			row_on = tonumber(par1)
			if  GetCell(tasktt,row_on,7)["image"]=="" 
			or GetCell(tasktt,row_on,8)["image"]=="" then
				message("�� ��� ���� ���������")
			else
					SetCell(tt, clicked_row, 1, "���������")
					DestroyTable(task_id)
					test_task_table = Task_Table:new()
					return
				
			end
		end
	end
	-- ������� ������ ����������
	if is_running and msg==6 then
		-- �����
		if par2 >=48 and par2 <=57 then
			user_input = user_input..tostring(par2-48)
		end
		-- �����
		if par2 == 46 then
			user_input = user_input.."."
		end
		if par2 == 45 then
			user_input = user_input.."-"
		end
		-- ��� �����
		if par2 == 8 then
			user_input = ""
		end
		SetCell(tasktt, current_row_number, current_column_number, user_input)
		-- ����
		if par2 == 13 then
			user_input = ""
			current_column_number = current_column_number + 1
			Highlight(task_id,current_row_number,current_column_number,000255000,2,100)
		end
	end
end
--============================================================����� ���� �������======================================================================================
--==========================================================���� ������� inf_Table=====================================================================================
-- ������� ������������� �������
function Inf_Table.new()
    inf_id = AllocTable()
    if inf_id ~= nil then
        inf_table = {}
		setmetatable(inf_table, Inf_Table)
		inf_table.inf_id=inf_id
		inf_table.caption = ""
		inf_table.created = false
		inf_table.curr_col=0
		-- ������� � ��������� ���������� ��������
		inf_table.columns={}
		return inf_table
    else
        return nil
    end
end
--������� � �������������� ��������� ������� Inf_Table
test_inf_table = Inf_Table:new()
-- ������� ������������� �������
function InitTable_inf()
    inftt = test_inf_table.inf_id
		sleep(10)
		AddColumn(inftt, 1, "��������", true,QTABLE_STRING_TYPE,25)
		AddColumn(inftt, 2, "��������", true,QTABLE_STRING_TYPE,77)
    CreateWindow(inftt)
    -- ����������� ���� ���������
    SetWindowCaption(inftt, "���������� � �����������")
    -- ������ ������� ����
	ox=0
	oy=0
	additional_window_height=40+15
	window_width=600
	class_list = getClassesList() -- ������ �������
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
    -- ������������� �� �������
    SetTableNotificationCallback(inftt, OnTable_Event_inf)
end
-- ������� ������������ ������� � �������
function OnTable_Event_inf(inf_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		
	end
	if msg==11 then
		--��������� ������
		Highlight(inf_id,par1,par2,000255000,2,500)
		-- ��� ������?
		DestroyTable(inf_id)
		test_inf_table = Inf_Table:new()
	end
end
--============================================================����� ���� �������======================================================================================
--==========================================================���� ������� Class_Table=====================================================================================
-- ������� ������������� �������
function Class_Table.new()
    c_id = AllocTable()
    if c_id ~= nil then
        c_table = {}
		setmetatable(c_table, Class_Table)
		c_table.c_id=c_id
		c_table.caption = ""
		c_table.created = false
		c_table.curr_col=0
		-- ������� � ��������� ���������� ��������
		c_table.columns={}
		return c_table
    else
        return nil
    end
end
--������� � �������������� ��������� ������� Class_Table
test_c_table = Class_Table:new()
-- ������� ������������� �������
function InitTable_C()
    ctt = test_c_table.c_id
	sleep(10)
	AddColumn(ctt, 1, "��� ������", true,QTABLE_STRING_TYPE,25)
	AddColumn(ctt, 2, "�������� ������", true,QTABLE_STRING_TYPE,77)
    CreateWindow(ctt)
    -- ����������� ���� ���������
    SetWindowCaption(ctt, "������� �����")
    -- ������ ������� ����
	ox=0
	oy=0
	additional_window_height=40+15
	window_width=600
	class_list = getClassesList() -- ������ �������
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
    -- ������������� �� �������
    SetTableNotificationCallback(ctt, OnTable_Event_c)
end
-- ������� ������������ ������� � �������
function OnTable_Event_c(c_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--��������� ������
		Highlight(c_id,par1,par2,000255000,2,500)
		-- ��� ������?
		Class_Code = tostring(GetCell(c_id,par1,1)["image"])
		SetCell(tt, row_new_instrument, 2, Class_Code)
		DestroyTable(c_id)
		test_c_table = Class_Table:new()
		InitTable_S()
	end
end
--============================================================����� ���� �������======================================================================================
--==========================================================���� ������� Sec_Table=====================================================================================
-- ������� ������������� �������
function Sec_Table.new()
    s_id = AllocTable()
    if s_id ~= nil then
        s_table = {}
		setmetatable(s_table, Sec_Table)
		s_table.s_id=s_id
		s_table.caption = ""
		s_table.created = false
		s_table.curr_col=0
		-- ������� � ��������� ���������� ��������
		s_table.columns={}
		return s_table
    else
        return nil
    end
end
--������� � �������������� ��������� ������� Sec_Table
test_s_table = Sec_Table:new()
-- ������� ������������� �������
function InitTable_S()
    stt = test_s_table.s_id
	sleep(1)
	AddColumn(stt, 1, "��� �����������", true,QTABLE_STRING_TYPE,25)
	AddColumn(stt, 2, "����������", true,QTABLE_STRING_TYPE,55)
    CreateWindow(stt)
    -- ����������� ���� ���������
    SetWindowCaption(stt, "������� ����������")
    -- ������ ������� ����
	ox=55
	oy=55
	additional_window_height=40+15
	window_width=500
    SetWindowPos(stt, ox, additional_window_height+15, window_width, additional_window_height)
	--������
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
    -- ������������� �� �������
    SetTableNotificationCallback(stt, OnTable_Event)
end
-- ������� ������������ ������� � �������
function OnTable_Event(s_id, msg, par1, par2)
--   ��� �������� ����
	if msg==24 then
		SetCell(tt, row_new_instrument, 2, "")
	end
	if msg==11 then
		--��������� ������
		Highlight(s_id,par1,par2,000255000,2,500)
		-- ��� ������?
		Sec_Code = tostring(GetCell(s_id,par1,1)["image"])
		--message(Class_Code)
		SetCell(tt, row_new_instrument, 3, Sec_Code)
		s_name= getSecurityInfo(Class_Code, Sec_Code).short_name
		SetCell(tt, row_new_instrument, 4, s_name)
		last_price =  tonumber(getParamEx(Class_Code,  Sec_Code, "LAST").param_value)
		SetCell(tt, row_new_instrument, 5, tostring(last_price))
		row = InsertRow(tt, -1)
		rows_in_main_window = rows_in_main_window + 1
		SetCell(tt, row, 1, "�������� ����������")
		SetCell(tt, row-1, 1, "��������")
		main_window_height=main_window_height+15
		SetWindowPos(tt, main_window_x_coord, main_window_y_coord, main_window_width, main_window_height)
		DestroyTable(s_id)
		test_s_table = Sec_Table:new()
	end
end
--============================================================����� ���� �������======================================================================================
