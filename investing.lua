
function main()
	-- Creating table
	tableId = createTable("New table")

	-- Get HTML code from finance calendar investing.com
	local request = getRequestFromSite("http://ru.investing.com/economic-calendar/")

	-- Finding block with events data
	local startBlock = string.find(request, "<tbody pageStartAt >")
	local endBlock =string.find(request, "</tbody>", startBlock)
	local data = string.sub (request, startBlock ,endBlock)

	-- Parsing data and filling table
	getInvestingData(data,1)
end


-- Create table with parameter for events
-- Parametrs: 	
-- @name Name caption foe table 
-- Return: Identificator created table 
function createTable(name)
	local tableId = AllocTable()
	message (tableId)
	AddColumn(tableId, 1, "Number",     true, QTABLE_INT_TYPE, 10)
	AddColumn(tableId, 2, "Time",       true, QTABLE_CACHED_STRING_TYPE, 10)
	AddColumn(tableId, 3, "country",    true, QTABLE_CACHED_STRING_TYPE, 20)
	AddColumn(tableId, 4, "valatility", true, QTABLE_CACHED_STRING_TYPE, 10)
	AddColumn(tableId, 5, "event",      true, QTABLE_CACHED_STRING_TYPE, 70)
	AddColumn(tableId, 6, "fact",       true, QTABLE_CACHED_STRING_TYPE, 10)
	AddColumn(tableId, 7, "fore",       true, QTABLE_CACHED_STRING_TYPE, 10)
	AddColumn(tableId, 8, "prev",       true, QTABLE_CACHED_STRING_TYPE, 10)
	
	CreateWindow(tableId)
	SetWindowCaption(tableId, name)
	return tableId
end

-- Add messages to table
-- Parametrs:
-- @data table with columns TIME, COUNTRY, VALATILITY, EVENT, FACT, FORE, PREV
function addRowToTable(data)
	if tableId == nil then
		return
	end

	local row = InsertRow(tableId, -1)
	SetCell( tableId, row, 1, "1")
	SetCell( tableId, row, 2, data['TIME'])
	SetCell( tableId, row, 3, data['COUNTRY'])
	SetCell( tableId, row, 4, data['VALATILITY'])
	SetCell( tableId, row, 5, data['EVENT'])
	SetCell( tableId, row, 6, data['FACT'])
	SetCell( tableId, row, 7, data['FORE'])
	SetCell( tableId, row, 8, data['PREV'])
end

-- Get html code 
-- Parametrs:
-- @site url of site
-- Return: Plain html text
function getRequestFromSite(site)
	local http = require("socket.http");
	return http.request(site)
end

-- Save data to file 
-- Parametrs:
-- @fileName file name
-- @data data for save to file
function saveToFile(fileName, data)
	message(fileName)
	local f = io.open(getScriptPath().."\\"..fileName,"w")
	f:write(data)
	f:flush()
	f:close()
end

-- Parsing data and filling table
-- @data data for parsing
function getInvestingData(data)

	-- Initial variables
	local endBlock = 1
	local startBlock = 1

	while 1 do
		
		-- Get event time 
		startBlock = string.find(data,">",string.find(data, "first left time"))+1
		endBlock = string.find(data, "</td>", startBlock)-1
		time = string.sub (data, startBlock ,endBlock)

		-- Get event country
		startBlock = string.find(data,"title=",string.find(data, "<td class=\"left flagCur noWrap\"><span title=",endBlock))
		if startBlock==nil then
			return
		end
		endBlock = string.find(data, "\"", startBlock)-1
		country = string.sub (data, startBlock +7,endBlock)

		-- Get event valatility
		startBlock = string.find(data,"title=",string.find(data, "<td class=\"left textNum sentiment noWrap\" title=",endBlock))+7
		endBlock = string.find(data, "\"", startBlock)-1
		valatility = string.sub (data, startBlock ,endBlock)

		-- Get event discription 
		startBlock = string.find(data,">",string.find(data, "<a href=",endBlock))+1
		endBlock = string.find(data, "</a>", startBlock)-1
		event = string.sub (data, startBlock ,endBlock)

		-- Get event fact value 
		startBlock = string.find(data,">",string.find(data, "<td class=\"bold",endBlock))+1
		endBlock = string.find(data, "</td>", startBlock)-1
		fact = string.sub (data, startBlock ,endBlock)

		-- Get event fore value
		startBlock = string.find(data,">",string.find(data, "<td class=\"fore",endBlock))+1
		endBlock = string.find(data, "</td>", startBlock)-1
		fore = string.sub (data, startBlock ,endBlock)

		-- Get event prev value
		startBlock = string.find(data,"<span title=\"\">",string.find(data, "<td class=\"prev",endBlock))+15
		endBlock = string.find(data, "</span>", startBlock)-1
		prev = string.sub (data, startBlock ,endBlock)

		-- Cut parsed block from data
		data = string.sub (data, endBlock-1)
		
		-- Create table
		local row = {
			['TIME']     	= time,
			['COUNTRY']     = country,
			['VALATILITY']  = valatility,
			['EVENT']       = event,
			['FACT']        = fact,
			['FORE']        = fore,
			['PREV']        = prev
		}

		-- Add row to table
		addRowToTable(row)
	end
end

