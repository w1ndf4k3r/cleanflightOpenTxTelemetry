
--[[ findd BEGIN DEFS and configure everything to your liking ]]--

---- IMPORTS --
local helpPopoup = dofile('/SCRIPTS/UTILS/helpPopup.lua')
local stickCommands = dofile('/SCRIPTS/UTILS/stickCommands.lua')
local gui = dofile('/SCRIPTS/UTILS/guiutils.lua')
local basicUtils = dofile('/SCRIPTS/UTILS/basicUtils.lua')
------END OF IMPORTS


-- LOCAL VARS --- nothing to do configure here but they must be defined here
local curParamPos = 1
local paramsEdited = false;
local curProfile = 0
-- END OF LOCAL VARS --

--local cfsettings = dofile('/SCRIPTS/CF_SETTINGS.lua') --still viable
-------------- BEGIN DEFS -----------------------
--voice not implemented yet
--value is what will the gvar9 value be for selecting a specific mode from -100 to 100 
setts = {
	{ name = "None", voice="", value=-92},
	{ name = "RC Rate", voice="", value=-75},
	{ name = "RC Expo", voice="", value=-59},
	{ name = "Throttle Expo", voice="", value=-43},
	{ name = "Pitch/Roll R", voice="", value=-26},
	{ name = "Yaw Rate", voice="", value=-10},
	{ name = "Pitch/Roll P", voice="", value=7},
	{ name = "Pitch/Roll I", voice="", value=23},
	{ name = "Pitch/Roll D", voice="", value=40},
	{ name = "Yaw P", voice="", value=56},
	{ name = "Yaw I", voice="", value=73},
	{ name = "Yaw D", voice="", value=90}
}
--sitch to use for config mode (0=none, 1=select, 2= adjust)
local confModeSwitch = 'input32'

--number of modes NEEDS to match the number of switch positions (can be a pot or channel), the modes will be distributed evenly trought the range
--limit yourself to 4 chars for name
flightmodes = {
	{ name = "Rate"},
	{ name = "Hrz"}
}
--switch to for mode selection, if more than two modes are needed select a 3pot (or more). It will evenly spread trough the defined input (channels and mixers can be used)
local flightmodesSwitch = 'sf'

-- profile names limit your self to 4 chars for name
local fprofiles = {
	{ name = "prf1"},
	{ name = "prf2"},
	{ name = "prf3"}
}
--unused atm
--local fprofileSwitch = 'gvar8'

--arm switch (hi = armed). only two state switches are valid (of course locgical switches are 2 state... so use them)
local armmSwitch = 'ls1'
-- beep switch (hi = beeping) only twostate switches are valid
local beepSwitch = 'ls4'

--STICK DEFINES:
local minCommand = -682 --minimum stick value to be counted as a command
local maxCommand = 682 -- maximum stick value to be counted as command
local commandDelay = 50 -- delay (in 10ms) before command activates

-- defined stick commands, care abou the order of commands
local commands =  {
	
	--save
	{
		name = "Save",
		cmd = THR_LO+YAW_LO+ELE_LO+AIL_HI,
		func = function()  		
			paramsEdited = false
			playFile('/SOUNDS/en/svd.wav')
		end 
	},

	--profile selectors
	{
		name = "Profile 1",
		cmd = THR_LO+YAW_LO+AIL_LO,
		func = function()  		
			curProfile = 0
			playFile('/SOUNDS/en/prf1.wav')
		end 
	},
	{
		name = "Profile 2",
		cmd = THR_LO+YAW_LO+ELE_HI,		
		func = function()  		
			curProfile = 1
			playFile('/SOUNDS/en/prf2.wav')
		end 
	},
	{
		name = "Profile 3",
		cmd = THR_LO+YAW_LO+AIL_HI,		
		func = function()  		
			curProfile = 2
			playFile('/SOUNDS/en/prf3.wav')
		end 
	},
	{
		name = "Cal. Gyro",
		cmd = THR_LO+YAW_LO+ELE_LO,		
		func = function()  		
			playFile('/SOUNDS/en/gyrcal.wav')
		end 
	},
	{
		name = "Cal. Accel.",
		cmd = THR_HI+YAW_LO+ELE_LO,		
		func = function()  		
			playFile('/SOUNDS/en/accal.wav')
		end 
	},
	{
		name = "Cal. Mag",
		cmd = THR_HI+YAW_HI+ELE_LO,		
		func = function()  		
			playFile('/SOUNDS/en/magcal.wav')
		end 
	},
	{
		name = "Inflight cal.",
		cmd = THR_LO+YAW_LO+ELE_HI+AIL_HI,
		func = function()  		
			playFile('/SOUNDS/en/infcal.wav')
		end 
	},	
	{
		name = "Trm Acc Left",
		cmd = THR_HI+AIL_LO,		
		func = function()  		
			playTone(3200,50,0,PLAY_NOW,0)
		end 
	},
	{
		name = "Trm Acc Right",
		cmd = THR_HI+AIL_HI,
		func = function()  		
			playTone(3200,50,0,PLAY_NOW,0)
		end 
	},
	{
		name = "Trm Acc Fwd",
		cmd = THR_HI+ELE_HI,		
		func = function()  		
			playTone(3200,50,0,PLAY_NOW,0)
		end 
	},
	{
		name = "Trm Acc Back",
		cmd = THR_HI+ELE_LO,		
		func = function()  		
			playTone(3200,50,0,PLAY_NOW,0)
		end 
	}
}
-- SWITCH HELP, configure your your switch help screen
local switches = {
	{name="SF", states= "rate/hrz mode"},
	{name="SG", states= "Arm/Disarm/Beeper"},
	{name="SC", states= "Select/change param"},
	{name="SH", states= "Cell voltage readout"}
}

--------------- END OF DEFS ------------


-- GLOBAL FUNCTIONS (can be called from other scripts if this screen is on)

--config mode navigation function, must be global it is used by decr.lua and incr.lua
-- It also detects if parameter was edited
function navigate(direction)
	local confMode = basicUtils.switchRange(confModeSwitch,3)
		
	-- 1 for adjustment mode select 
	if confMode == 1 then
		if direction > 0 then
			if curParamPos == rawlen(setts) then curParamPos = 1
			else 
				curParamPos = curParamPos+1 
			end		
		elseif direction == -1 then
			if curParamPos == 1 then 
				curParamPos = 12
			else 
				curParamPos = curParamPos-1 
			end
		end
		--outputs the selected value using gvar8 flightmode 0
		model.setGlobalVariable(8, 0, setts[curParamPos].value)
	elseif (confMode == 2 and curParamPos ~= 1)  then
	--detecting if param was edited, could be done with LS (but at least 3 logical switches would be used)
	--the disatvantage is that the same trim is used for both selecting and changing the params and this cannot be changed unless this part is removed.
		paramsEdited = true
	end
end
---- END OF GLOBAL FUNCTIONS ----



-- main loop --
local function run(event)
	stickCommands.process()	
	--run help popup code, does its own navigation does some flickering
	--has to skip everything because there is some wierd flickering......
	if(helpPopoup.runPopup(event)) then return end

	local settings = getGeneralSettings()

	--draw central grid
	lcd.drawLine(48, -1, 48, 64, SOLID, GREY_DEFAULT)
	lcd.drawLine(106, -1, 106, 64, SOLID, GREY_DEFAULT)
	lcd.drawLine(163, -1, 163, 64, SOLID, GREY_DEFAULT)
	lcd.drawLine(48, 0, 105, 0, SOLID, GREY_DEFAULT)
	lcd.drawLine(48, 21, 105, 21, SOLID, GREY_DEFAULT)
	lcd.drawLine(48, 42, 105, 42, SOLID, GREY_DEFAULT)
	lcd.drawLine(48, 63, 105, 63, SOLID, GREY_DEFAULT)
	lcd.drawLine(106, 0, 162, 0, SOLID, GREY_DEFAULT)
	lcd.drawLine(106, 21, 162, 21, SOLID, GREY_DEFAULT)
	lcd.drawLine(106, 42, 162, 42, SOLID, GREY_DEFAULT)
	lcd.drawLine(106, 63, 162, 63, SOLID, GREY_DEFAULT)

	-- draw main battery level
	local minCell = getValue(214)
	if minCell > 4.2 then
	lcd.drawPixmap(7, 1, "/SCRIPTS/BMP/bat11.bmp")
	else
	if minCell > 4.1 then
	lcd.drawPixmap(7, 1, "/SCRIPTS/BMP/bat10.bmp")
	else
	if minCell > 3.97 then
	 lcd.drawPixmap(7, 1, "/SCRIPTS/BMP/bat09.bmp")
	else
	 if minCell > 3.92 then
	  lcd.drawPixmap(7, 1, "/SCRIPTS/BMP/bat08.bmp")
	 else
	  if minCell > 3.87 then
	   lcd.drawPixmap(7, 1, "/SCRIPTS/BMP/bat07.bmp")
	  else
	   if minCell > 3.83 then
		lcd.drawPixmap(7, 1, "/SCRIPTS/BMP/bat06.bmp")
	   else
		if minCell > 3.79 then
		 lcd.drawPixmap(7, 1, "/SCRIPTS/BMP/bat05.bmp")
		else
		 if minCell > 3.75 then
		  lcd.drawPixmap(7, 1, "/SCRIPTS/BMP/bat04.bmp")
		 else
		  if minCell > 3.7 then
		   lcd.drawPixmap(7, 1, "/SCRIPTS/BMP/bat03.bmp")
		  else
		   if minCell > 3.6 then
			lcd.drawPixmap(7, 1, "/SCRIPTS/BMP/bat02.bmp")
		   else
			lcd.drawPixmap(7, 1, "/SCRIPTS/BMP/bat01.bmp")
		   end
		  end
		 end
		end
	   end
	  end
	 end
	end
	end
	end
	--cell voltage at bottom 'cell-min'
	lcd.drawChannel(11, 55, 214, LEFT)

	--armed/disarmed icon
	if getValue(armmSwitch) > 0 then 
		lcd.drawPixmap(52, 3, "/SCRIPTS/BMP/armed.bmp")		
	else
			lcd.drawPixmap(52, 3, "/SCRIPTS/BMP/disarmed.bmp")
	end

	--blink sound if beeping switch flipped
	if getValue(beepSwitch) > 0 then
			if (gui.blinkShow()) then
				lcd.drawPixmap(52, 3, "/SCRIPTS/BMP/sound.bmp")
			end
	end
	--flight mode text
	lcd.drawText(72, 5,flightmodes[basicUtils.switchRange(flightmodesSwitch,rawlen(flightmodes))+1].name,MIDSIZE);
	  

	--draw TX battery level	  
	local percent = (getValue("tx-voltage")-settings.battMin) * 100 / (settings.battMax-settings.battMin)
	lcd.drawRectangle(52, 28, 15, 8)
	lcd.drawFilledRectangle(53, 29, 13, 6, GREY_DEFAULT)
	lcd.drawLine(67, 29, 67, 33, SOLID, 0)
	if(percent > 14) then lcd.drawLine(54, 29, 54, 33, SOLID, 0) end
	if(percent > 29) then lcd.drawLine(56, 29, 56, 33, SOLID, 0) end
	if(percent > 43) then lcd.drawLine(58, 29, 58, 33, SOLID, 0) end
	if(percent > 57) then lcd.drawLine(60, 29, 60, 33, SOLID, 0) end
	if(percent > 71) then lcd.drawLine(62, 29, 62, 33, SOLID, 0) end
	if(percent > 86) then lcd.drawLine(64, 29, 64, 33, SOLID, 0) end
	lcd.drawChannel(75, 26, "tx-voltage", LEFT+MIDSIZE)

	--bec voltage
	lcd.drawPixmap(52, 46, "/SCRIPTS/BMP/bec.bmp")
	lcd.drawChannel(75, 47, 202, LEFT+MIDSIZE)

	--draw selected profile
	lcd.drawPixmap(110, 3, "/SCRIPTS/BMP/p.bmp")
	--local angle = (getValue(83)+1024)*90/2048
	lcd.drawText(130, 5, fprofiles[curProfile+1].name, MIDSIZE)
	--lcd.drawText(130, 5, fprofiles[basicUtils.switchRange(fprofileSwitch,rawlen(fprofiles))+1].name, MIDSIZE)	
	--lcd.drawText(130, 5, basicUtils.switchRange(fprofileSwitch,rawlen(fprofiles)), MIDSIZE)


	--draw timer 1
	lcd.drawPixmap(110, 24, "/SCRIPTS/BMP/timer.bmp")
	lcd.drawTimer(130, 26, getValue(196), LEFT+MIDSIZE)

	--draw clock
	lcd.drawPixmap(110, 46, "/SCRIPTS/BMP/clock.bmp")
	lcd.drawTimer(130, 47, getValue(190), LEFT+MIDSIZE)

  
	--draw RSSI
	if getValue(200) > 38 then
	percent = ((math.log(getValue(200)-28, 10)-1)/(math.log(72, 10)-1))*100
	else
	percent = 0
	end
	if percent > 90 then
	lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI11.bmp")
	else
	if percent > 80 then
	lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI10.bmp")
	else
	if percent > 70 then
	 lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI09.bmp")
	else
	 if percent > 60 then
	  lcd.drawPixmap(164, 1,  "/SCRIPTS/BMP/RSSI08.bmp")
	 else
	  if percent > 50 then
	   lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI07.bmp")
	  else
	   if percent > 40 then
		lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI06.bmp")
	   else
		if percent > 30 then
		 lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI05.bmp")
		else
		 if percent > 20 then
		  lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI04.bmp")
		 else
		  if percent > 10 then
		   lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI03.bmp")
		  else
		   if percent > 0 then
			lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI02.bmp")
		   else
			lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI01.bmp")
		   end
		  end
		 end
		end
	   end
	  end
	 end
	end
	end
	end
	lcd.drawChannel(178, 55, 200, LEFT)
	lcd.drawText(lcd.getLastPos(), 56, "dB", SMLSIZE)
  
  -- mark parameters edited
	if (paramsEdited) then
		lcd.drawPixmap(201, 53, "/SCRIPTS/BMP/edit.bmp")
	end


 --handling of lost connection
 --else
  --lcd.drawText(15, 25, "No connection ....", BLINK+DBLSIZE)
 --end
 
	--212 x 64
	--popup for adjustments
	local confMode =  basicUtils.switchRange(confModeSwitch,3)
	if confMode > 0 then
		gui.popup(118,40)
		local adjTextStyle = 0
		if confMode == 1 then 
			--lcd.drawText(62, 15,'[' .. setts[curParamPos].name .. ']', INVERS+BLINK)
			lcd.drawText(57, 15,"Select:", 0)
			
			lcd.drawText(51, 25,'[' .. setts[curParamPos].name .. ']', INVERS+BLINK+MIDSIZE)
		else
			  
			--position 1 is no setting
			if(curParamPos == 1) then
				lcd.drawText(57, 25,"Cannot adjust " .. setts[curParamPos].name, 0)	  
			else
				--lcd.drawText(65, 15,setts[curParamPos].name, 0)	
				lcd.drawText(57, 15,"Adjusting:", BLINK)	
				lcd.drawText(57, 25,setts[curParamPos].name, MIDSIZE)	  
			end
		end
			
	end
	
	

end



local function init_func(event)
	lastEvent =0	
	model.setGlobalVariable(8, 0, setts[curParamPos].value)
	helpPopoup.init(switches,commands)
	stickCommands.init(commands,minCommand,maxCommand,commandDelay)
end

return {run=run,init=init_func }