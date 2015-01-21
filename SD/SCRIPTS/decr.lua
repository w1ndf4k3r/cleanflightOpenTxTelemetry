local t_next = 0 
local function run_IncSelect()
	local t = getTime()
	if setts and t > t_next then
		t_next = t + 33
		navigate(-1)
	end
end
return {run=run_IncSelect}