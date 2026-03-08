local num_tabs = ...

return function(player, AllSteps)
	local song = GAMESTATE:GetCurrentSong()
	AllSteps = AllSteps or (song and SongUtil.GetPlayableSteps(song)) or {}

	-- if there are fewer playable stepcharts than the UI accommodates, no problem, return them all
	if #AllSteps < num_tabs then
		local t = {}
		local _i = num_tabs-1
		for i=1,num_tabs do
			t[i] = AllSteps[#AllSteps-_i]
			_i = _i - 1
		end
		return t
	end

	-- otherwise,
	player = player or GAMESTATE:GetMasterPlayerNumber()
	if not player then return {} end

	local current_steps = GAMESTATE:GetCurrentSteps(player)
	local i = FindInTable(current_steps, AllSteps)
	if not i then return {} end

	local t = {}
	local _i


	if i <= 5 then
		_i = 1
	elseif i > 5 and i < #AllSteps-5 then
		_i = i-5
	else
		_i=#AllSteps-(num_tabs-1)
	end

	for index=1,num_tabs do
		t[index] = AllSteps[_i]
		_i = _i + 1
	end

	return t
end