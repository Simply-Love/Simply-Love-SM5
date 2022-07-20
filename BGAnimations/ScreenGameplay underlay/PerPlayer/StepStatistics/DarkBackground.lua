local player, header_height, width = unpack(...)
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

local FilterAlpha = {
	Dark = 0.5,
	Darker = 0.75,
	Darkest = 0.95
}

return Def.Quad{
	InitCommand=function(self)
		self:diffuse(0, 0, 0, 0):setsize(width+100, _screen.h):y(-header_height):diffusealpha( FilterAlpha[mods.BackgroundFilter] or 0 )
		if player==PLAYER_1 then
			self:fadeleft(0.1)
		else
			self:faderight(0.1)
		end
	end
}