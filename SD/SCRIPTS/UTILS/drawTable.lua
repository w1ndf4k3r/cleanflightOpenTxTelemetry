local page = 1
local tableConfig = {
		x=1,
		y=12,	
		rowSize=16,
		columnSize=106,
		pageSize = 6,
		items = 12,
		title = "",
		aligmentVertical = false,
		columns=2,
		cellCallback = function(drawPosition,idx) lcd.drawText(0,10,"no draw callback",0) end,
		
	}
local function drawFullScreenTable(event)
--lcd.drawText(0,10,type(tableConfig.cellCallback),0)

	local totalPages = math.floor((tableConfig.items-1)/tableConfig.pageSize)+1
	if(event == EVT_PLUS_BREAK) then
		if page < totalPages then
			page = page+1		
		else
			page = 1
		end
		lcd.clear()
	elseif event == EVT_MINUS_BREAK and page > 1 then
		page = page -1
		lcd.clear()
	end

	lcd.drawScreenTitle(tableConfig.title,page,totalPages)

	for i=0,tableConfig.pageSize-1 do
		
		local curItem = (page-1) * tableConfig.pageSize + i + 1
						
		local drawPosition = {}
		--vertical sort
		if tableConfig.aligmentVertical then
			--drawPosition = {tableConfig.x+(tableConfig.columnSize*math.floor(i/3)), tableConfig.y+(tableConfig.rowSize*(i%3))}
			drawPosition = {tableConfig.x+(tableConfig.columnSize*math.floor(i/tableConfig.columns)), tableConfig.y+(tableConfig.rowSize*(i%tableConfig.columns))}
		else --horisontal sort
			--drawPosition = {tableConfig.x+(tableConfig.columnSize*(i%2)), tableConfig.y+(tableConfig.rowSize*math.floor(i/2))}
			drawPosition = {tableConfig.x+(tableConfig.columnSize*(i%tableConfig.columns)), tableConfig.y+(tableConfig.rowSize*math.floor(i/tableConfig.columns))}
		end
		tableConfig.cellCallback(drawPosition,curItem)

		if(curItem >= tableConfig.items) then
			break
		end
	end
	
	--improve or move away!!
	if(event ~= EVT_EXIT_BREAK) then
		lcd.lock()
		return true
	else
		page = 1
		lcd.clear()
		return false
	end
end

--this was the only way of OOP that my newbie knowledge of lua was able to produce
--expose public fields
return {draw=drawFullScreenTable,tableConfig1=tableConfig}