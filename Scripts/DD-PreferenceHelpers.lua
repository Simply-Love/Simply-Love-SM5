-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--------------------------------PROFILE PREFENCES TO LOAD----------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

----- MAIN SORT PROFILE PREFERNCE ----- 
function GetMainSortPreference()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'MainSortPreference')
	else
		value = DDStats.GetStat(PLAYER_2, 'MainSortPreference')
	end

	if value == nil then
		value = 1
	end
	
	MainSortIndex = tonumber(value)

	return tonumber(value)
end

----- SUB SORT PROFILE PREFERNCE -----
function GetSubSortPreference()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'SubSortPreference')
	else
		value = DDStats.GetStat(PLAYER_2, 'SubSortPreference')
	end

	if value == nil then
		value = 2
	end
	
	SubSortIndex = tonumber(value)

	return tonumber(value)
end

----- Lower Difficulty Filter profile settings ----- 
function GetLowerDifficultyFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LowerDifficultyFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'LowerDifficultyFilter')
	end

	if value == nil then
		value = 0
	end

	return tonumber(value)
end

----- Upper Difficulty Filter profile settings ----- 
function GetUpperDifficultyFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'UpperDifficultyFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'UpperDifficultyFilter')
	end

	if value == nil then
		value = 0
	end

	return tonumber(value)
end

----- Lower BPM Filter profile settings ----- 
function GetLowerBPMFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LowerBPMFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'LowerBPMFilter')
	end

	if value == nil then
		value = 49
	end

	return tonumber(value)
end


----- Upper BPM Filter profile settings ----- 
function GetUpperBPMFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'UpperBPMFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'UpperBPMFilter')
	end

	if value == nil then
		value = 49
	end

	return tonumber(value)
end


----- Lower Length Filter profile settings ----- 
function GetLowerLengthFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LowerLengthFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'LowerLengthFilter')
	end

	if value == nil then
		value = 0
	end

	return tonumber(value)
end

----- Upper Length Filter profile settings ----- 
function GetUpperLengthFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'UpperLengthFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'UpperLengthFilter')
	end
	
	if value == nil then
		value = 0
	end
	
	return tonumber(value)
end

---- Groovestats profile preference
function GetGroovestatsFilter()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'GroovestatsFilter')
	else
		value = DDStats.GetStat(PLAYER_2, 'GroovestatsFilter')
	end

	if value == nil then
		value = 'No'
	end

	return value
end