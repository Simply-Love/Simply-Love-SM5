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

		-- see Player combo.lua for more details
		local fullComboType

		for i=1,tonumber(string.sub(GetComboThreshold('Maintain'), -1)) do
			if (StageStats:FullComboOfScore('TapNoteScore_W' .. i)) then
				fullComboType = i
				break
			end
		end

		if not fullComboType then return end

		self:accelerate(0.25):diffuse( SL.JudgmentColors[SL.Global.GameMode][fullComboType] )
			:decelerate(0.75):diffusealpha( 0 )
	end
}

return filter
