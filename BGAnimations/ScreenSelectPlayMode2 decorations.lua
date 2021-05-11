local nsj = GAMESTATE:GetNumSidesJoined()
SetGameModePreferences()
local function GetLastStyle()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LastStyle')
	else
		value = DDStats.GetStat(PLAYER_2, 'LastStyle')
	end

	if value == nil then
		value = "Single"
	end

	return value
end

if nsj ~= 2 then
	local yo = GetLastStyle()
	GAMESTATE:SetCurrentStyle(yo)
end

return Def.ActorFrame{}