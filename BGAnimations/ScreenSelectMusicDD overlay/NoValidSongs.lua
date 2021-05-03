local DDStats = LoadActor('./DDStats.lua')
local HasResetFilterPreferences = false
local HelpText

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

local function SetLowerDifficultyFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'LowerDifficultyFilter', value)
		DDStats.Save(playerNum)
	end
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

local function SetUpperDifficultyFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'UpperDifficultyFilter', value)
		DDStats.Save(playerNum)
	end
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

local function SetLowerBPMFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'LowerBPMFilter', value)
		DDStats.Save(playerNum)
	end
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

local function SetUpperBPMFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'UpperBPMFilter', value)
		DDStats.Save(playerNum)
	end
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

local function SetLowerLengthFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'LowerLengthFilter', value)
		DDStats.Save(playerNum)
	end
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

local function SetUpperLengthFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'UpperLengthFilter', value)
		DDStats.Save(playerNum)
	end
end

----- Groovestats filter profile setting -----
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

local function SetGroovestatsFilter(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'GroovestatsFilter', value)
		DDStats.Save(playerNum)
	end
end


----- Default preference values
local DefaultLowerDifficulty = 0
local DefaultUpperDifficulty = 0
local DefaultLowerBPM = 49
local DefaultUpperBPM = 49
local DefaultLowerLength = 0
local DefaultUpperLength = 0
local DefaultGroovestats = 'No'

if 
GetLowerDifficultyFilter() ~= DefaultLowerDifficulty or
GetUpperDifficultyFilter() ~= DefaultUpperDifficulty or
GetLowerBPMFilter() ~= DefaultLowerBPM or
GetUpperBPMFilter() ~= DefaultUpperBPM or
GetLowerLengthFilter() ~= DefaultLowerLength or
GetUpperLengthFilter() ~= DefaultUpperLength or
GetGroovestatsFilter() ~= DefaultGroovestats then
	SetLowerDifficultyFilter(DefaultLowerDifficulty)
	SetUpperDifficultyFilter(DefaultUpperDifficulty)
	SetLowerBPMFilter(DefaultLowerBPM)
	SetUpperBPMFilter(DefaultUpperBPM)
	SetLowerLengthFilter(DefaultLowerLength)
	SetUpperLengthFilter(DefaultUpperLength)
	SetGroovestatsFilter(DefaultGroovestats)
	HasResetFilterPreferences = true
end

local Input = function(event)
	-- if any of these, don't attempt to handle input
	if not event or not event.button then return false end

	if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" then
		local topscreen = SCREENMAN:GetTopScreen()
		if HasResetFilterPreferences == true then
			topscreen:SetNextScreenName("ScreenReloadSSMDD")
			topscreen:StartTransitioningScreen("SM_GoToNextScreen")
		else
			topscreen:SetNextScreenName("ScreenGameOver")
			topscreen:StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
end

--- Show text letting the player know if they have no songs or if they messed things up with their filters.
if HasResetFilterPreferences == false then
	HelpText = ScreenString("NoValidSongs")
else
	HelpText = ScreenString("NoValidFilters")
end

local af = Def.ActorFrame{
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( Input ) end,

	LoadActor(THEME:GetPathB("ScreenSelectMusicDD", "overlay/Header.lua"), {h=60} ),

	Def.Quad{
		InitCommand=function(self) self:FullScreen():Center():diffuse(0,0,0,0.6) end
	},

	Def.BitmapText{
		Font="Common Normal",
		Text=HelpText,
		InitCommand=function(self) self:Center():zoom(1.1):_wrapwidthpixels(320) end
	},
}

return af