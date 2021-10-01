local HasResetFilterPreferences = false
local HelpText

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
		if HasResetFilterPreferences == true or SongSearchSSMDD == true then
			SongSearchSSMDD = false
			SongSearchAnswer = nil
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

if SongSearchSSMDD then
	HelpText = ScreenString("NoValidFilters")
end

local af = Def.ActorFrame{
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( Input ) end,

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