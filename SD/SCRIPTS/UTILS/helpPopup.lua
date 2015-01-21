
local commands = {}
local stickTable = {}


local switches = {}
local switchTable = {}


local function getPictureForStick(command,stick)

	--stick 0 is right
	local stickPicName = 0
	if(stick == 0) then
		stickPicName = command%16
	else --stick 1 is left
		--right shift 4
		stickPicName = math.floor(command / 2 ^ 4) 
	end	
	return "/SCRIPTS/BMP/StickIcons/"..stickPicName..".bmp"

end


local function drawCell(drawPosition,idx)
		lcd.drawPixmap(drawPosition[1], drawPosition[2], getPictureForStick(commands[idx].cmd,0))
		lcd.drawPixmap(drawPosition[1]+15, drawPosition[2], getPictureForStick(commands[idx].cmd,1))
		lcd.drawText(drawPosition[1]+33, drawPosition[2]+4,commands[idx].name,0)
end




local function drawSwitch(drawPos,idx)
	lcd.drawText(drawPos[1], drawPos[2],switches[idx].name..":",0)
	lcd.drawText(drawPos[1]+20, drawPos[2],switches[idx].states,0)
end



local viewStickHelp = false
local viewSwitchHelp = false
local selectHelpPopup = false
local helpPopupIdx = 0


local function init(swt,cmd)
	switches=swt
	commands=cmd
	
	stickTable = dofile('/SCRIPTS/UTILS/drawTable.lua')
	stickTable.tableConfig1.cellCallback = drawCell
	stickTable.tableConfig1.title = "Stick controls"
	stickTable.tableConfig1.aligmentVertical = true
	stickTable.tableConfig1.columns = 3
	stickTable.tableConfig1.items = rawlen(commands)
	
	switchTable = dofile('/SCRIPTS/UTILS/drawTable.lua')
	switchTable.tableConfig1.cellCallback = drawSwitch
	switchTable.tableConfig1.items = rawlen(switches)
	switchTable.tableConfig1.title = "Switch help"
	switchTable.tableConfig1.y = 9
	switchTable.tableConfig1.pageSize = 6
	switchTable.tableConfig1.rowSize=9
	switchTable.tableConfig1.aligmentVertical = false
	switchTable.tableConfig1.columns = 1	
	
end

local function runPopup(event)
	
	if event == 64 and not viewStickHelp then
			selectHelpPopup = true		
	end


	if selectHelpPopup then
		lcd.lock()
		lcd.drawCombobox(65, 10, 95, {"Stick commands","Switches"}, helpPopupIdx, 1)
		
		if event == EVT_EXIT_BREAK then
			selectHelpPopup = false
			helpPopupIdx = 0
		elseif event== EVT_MINUS_BREAK and helpPopupIdx < 1 then
			helpPopupIdx = helpPopupIdx +1
		elseif  event == EVT_PLUS_BREAK and helpPopupIdx > 0 then
			helpPopupIdx = helpPopupIdx -1
		elseif  event == EVT_ENTER_BREAK then
			
			if helpPopupIdx == 0 then			
				viewStickHelp = true
			elseif helpPopupIdx == 1 then			
				viewSwitchHelp = true		
			end
			
			selectHelpPopup = false		
			lcd.clear()
			helpPopupIdx = 0
			
		end
		
	end
		
	if viewStickHelp then
		lcd.clear()
		if not stickTable.draw(event) then
			viewStickHelp = false		
		end
	end
	if viewSwitchHelp then
		lcd.clear()
		if not switchTable.draw(event) then
			viewSwitchHelp = false		
		end
	end

	return selectHelpPopup or viewSwitchHelp or viewStickHelp
end

local function epicFail()
	lcd.drawText(10,10,"ASDASDA",0)
end

--this was the only way of OOP that my newbie knowledge of lua was able to produce
--expose public fields
return {runPopup=runPopup, init=init, epicFail=epicFail}