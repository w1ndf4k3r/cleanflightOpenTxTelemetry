--enumerates channel/switch/input position
--valueName: the name of the input
--position_number: number of possible positions (willd devide the input in equal parts)
--return: a number from 0 to position_number-1 (ex: 3-state switch low = 0, mid = 1, high = 2)
local function switchRange(valueName,position_number)
	
	local value = getValue(valueName)
	local pos = math.floor((value+1024)/math.ceil(2049/position_number))
	return pos
end

return {switchRange=switchRange}