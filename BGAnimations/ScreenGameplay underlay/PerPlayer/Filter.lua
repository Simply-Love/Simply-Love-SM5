-- filter code rewrite
local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

-- if no BackgroundFilter is necessary, it's safe to bail now
if mods.BackgroundFilter == "Off" then
	return Def.Actor{}
end


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
		local StageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
		if StageStats:FullCombo() then
			local comboColor
			if StageStats:FullComboOfScore('TapNoteScore_W1') then
				comboColor = color("#6BF0FF")
			elseif StageStats:FullComboOfScore('TapNoteScore_W2') then
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