if SL.Global.GameMode ~= "Casual" then
	local player = ...
	local lifemeter
	
	if SL.Global.GameMode == "StomperZ" then
		lifemeter = LoadActor("StomperZ.lua", player)
	else
		lifemeter = LoadActor("Competitive.lua", player)
	end
	
	return lifemeter
end