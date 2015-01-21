					------- STICK COMMAND HANDLING -----------
-----------------------------------------------------------------------------------
--|                                                                             |--
--|ONLY CALL processStickCommands() ONCE PER SCRIPT, IT WILL NOT WORK OTHERWISE |--
--|															                    |--
-----------------------------------------------------------------------------------

--do not touch this, flags...
THR_LO = 1
THR_HI = 2
YAW_LO = 4
YAW_HI = 8
ELE_LO = 16
ELE_HI = 32
AIL_LO = 64
AIL_HI = 128

--uncomment for mode 2
-- ELE_LO = 1
-- ELE_HI = 2
-- YAW_LO = 4
-- YAW_HI = 8
-- THR_LO = 16
-- THR_HI = 32
-- AIL_LO = 64
-- AIL_HI = 128

local commands = {}
local minCommand = -1000
local maxCommand = 1000
local commandDelay = 50


local stickCmd = 0
local commandTime = 0
--do not touch this, flags...
--will process stick commands, commands will only be called once each time they are detected, see warning above
local function processStickCommands() 
	local tmpCmd = 0

	--get stick values
	local thrStick = getValue('thr') -- throttle input
	local eleStick = getValue('ele') -- elevator input
	local ailStick = getValue('ail') -- aileron input
	local yawStick = getValue('rud') -- rudder input
	
	-- because of lack of native bitwise operators code sucks
	if(thrStick > maxCommand) then
		tmpCmd =  tmpCmd + THR_HI
	elseif  thrStick < minCommand then
		tmpCmd = tmpCmd +THR_LO
	end

	if(eleStick > maxCommand) then
		tmpCmd =  tmpCmd + ELE_HI
	elseif  eleStick < minCommand then
		tmpCmd =  tmpCmd + ELE_LO
	end

	if(ailStick > maxCommand) then
		tmpCmd =  tmpCmd + AIL_HI
	elseif  ailStick < minCommand then
		tmpCmd =  tmpCmd + AIL_LO
	end

	if(yawStick > maxCommand) then
		tmpCmd =  tmpCmd + YAW_HI
	elseif  yawStick < minCommand then
		tmpCmd =  tmpCmd + YAW_LO
	end

	-- reset time if the stick cmd change
	if (tmpCmd == stickCmd) then
		if (commandTime < 250) then
			commandTime = commandTime +1
		end
	else
		commandTime = 0
	end
	stickCmd = tmpCmd;

		
	--command exectues only once! (this prevents the function to be called multiple times, this is ok, we do not want to execute multiple commands with a single stick command)
	if(commandTime ~= commandDelay) then
		return
	end
	
	--process commands (will call the defined function in commands
	for k,v in pairs(commands) do 	
		if(v.cmd == stickCmd) then 		
			v.func()
			--calling multiple commands is prevented (only one will execute) so care for order in command spec
			return
		end
	end
	return
end

local function init(commandsP,minCommandP,maxCommandP,commandDelayP)
	commands= commandsP
	minCommand = minCommandP
	maxCommand=maxCommandP
	commandDelay=commandDelayP
end
return {process=processStickCommands,init=init}