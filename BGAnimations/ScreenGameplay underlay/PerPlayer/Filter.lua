-- filter code rewrite
local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

local IsUsingSoloSingles = PREFSMAN:GetPreference('Center1Player')
local NumPlayersEnabled = GAMESTATE:GetNumPlayersEnabled()
local NumSidesJoined = GAMESTATE:GetNumSidesJoined()
local IsPlayingDanceSolo = GAMESTATE:GetCurrentStyle():GetStepsType() == "StepsType_Dance_Solo" and true or false

local FilterAlpha = {
	Dark = 0.5,
	Darker = 0.75,
	Darkest = 0.95
}

local filter = Def.Quad{
	InitCommand=function(self)
		self:diffuse(Color.Black)
			:diffusealpha( FilterAlpha[mods.BackgroundFilter] or 0 )
			:xy( GetNotefieldX(player), _screen.cy )
			:zoomto( GetNotefieldWidth(), _screen.h )
	end,
	OffCommand=function(self) self:queuecommand("ComboFlash") end,
	ComboFlashCommand=function(self)
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
			self:accelerate(0.25):diffuse( comboColor )
				:decelerate(0.75):diffusealpha( 0 )
		end
	end
}

return filter
