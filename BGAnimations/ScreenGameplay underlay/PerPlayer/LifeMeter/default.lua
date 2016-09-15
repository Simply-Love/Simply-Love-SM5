if SL.Global.GameMode ~= "Casual" then
	local player = ...
	local lifemeter = LoadActor(SL.Global.GameMode .. ".lua", player)
	return lifemeter
end