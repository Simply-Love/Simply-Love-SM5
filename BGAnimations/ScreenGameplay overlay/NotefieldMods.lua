-- This file moves the notefield according to player options.

local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

return Def.Actor{
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():GetChild("Player"..pn):GetChild("NoteField"):addy(mods.NotefieldShift)
		if mods.BeatBars == "None" then
			SL.Metrics["ShowBeatBars"] = false
		elseif mods.BeatBars == "Measures" then
			SL.Metrics["ShowBeatBars"] = true
			SL.Metrics["BarMeasureAlpha"] = 0.5
			SL.Metrics["Bar4thAlpha"] = 0
		elseif mods.BeatBars == "Beats" then
			SL.Metrics["ShowBeatBars"] = true
			SL.Metrics["BarMeasureAlpha"] = 0.5
			SL.Metrics["Bar4thAlpha"] = 0.25
		end
		THEME:ReloadMetrics()
	end,
}
