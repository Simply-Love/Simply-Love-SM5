-- filter code rewrite
local Player = ...

local IsUsingSoloSingles = PREFSMAN:GetPreference('Center1Player')
local NumPlayers = GAMESTATE:GetNumPlayersEnabled()
local NumSides = GAMESTATE:GetNumSidesJoined()
local IsPlayingDanceSolo = GAMESTATE:GetCurrentStyle():GetStepsType() == "StepsType_Dance_Solo" and true or false

local pName, filterColor
local fallbackColor = color("0,0,0,0.75")

local function InitFilter()
	pName = pname(Player)

	local darkness = SL[pName].ActiveModifiers.ScreenFilter
	if darkness == "Dark" then
		filterColor = color("#00000099")
	elseif darkness == "Darker" then
		filterColor = color("#000000BB")
	elseif darkness == "Darkest" then
		filterColor = color("#000000EE")
	else
		filterColor = color("#00000000")
	end

end

local function FilterPosition()
	if IsUsingSoloSingles and NumPlayers == 1 and NumSides == 1 then return _screen.cx end
	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then return _screen.cx end

	local strPlayer = (NumPlayers == 1) and "OnePlayer" or "TwoPlayers"
	local strSide = (NumSides == 1) and "OneSide" or "TwoSides"
	return THEME:GetMetric("ScreenGameplay","Player".. pName .. strPlayer .. strSide .."X")
end


local function FilterWidth()

	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
		return _screen.w*1.058/GetScreenAspectRatio()
	elseif IsPlayingDanceSolo then
		return _screen.w*0.8/GetScreenAspectRatio()
	else
		return _screen.w*0.529/GetScreenAspectRatio()
	end
end

InitFilter()

local filter = Def.Quad{
	InitCommand=cmd(diffuse,filterColor; xy,FilterPosition(),_screen.cy; zoomto,FilterWidth(),_screen.h),
	OffCommand=function(self)
		local pStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(Player)
		if pStats:FullCombo() then
			local comboColor
			if pStats:FullComboOfScore('TapNoteScore_W1') then
				comboColor = color("#6BF0FF")
			elseif pStats:FullComboOfScore('TapNoteScore_W2') then
				comboColor = color("#FDDB85")
			else
				comboColor = color("#94FEC1")
			end
			self:accelerate(0.25)
			self:diffuse( comboColor )
			self:decelerate(0.75)
			self:diffusealpha( 0 )
		end
	end
}

return filter