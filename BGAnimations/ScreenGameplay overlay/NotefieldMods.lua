-- This file moves the notefield according to player options.

local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

return Def.Actor{
	OnCommand=function(self)
		THEME:ReloadMetrics()
	end,
}
