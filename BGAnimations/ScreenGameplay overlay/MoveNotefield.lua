-- This file moves the notefield according to player options.

local player = ...
local pn = ToEnumShortString(player)

return Def.Actor{
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():GetChild("Player"..pn):GetChild("NoteField"):addy(SL[pn].ActiveModifiers.NotefieldShift)
	end,
}
