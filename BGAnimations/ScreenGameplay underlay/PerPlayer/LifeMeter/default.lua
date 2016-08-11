if SL.Global.GameMode ~= "Casual" then
	local player = ...
	local lifemeter
	
	if SL.Global.GameMode == "StomperZ" or SL.Global.GameMode == "ECFA" then
		lifemeter = LoadActor("StomperZ.lua", player)
	else
		lifemeter = LoadActor("Competitive.lua", player)
	end
	
	return lifemeter
end