local player, header_height, width = unpack(...)
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)

local FilterAlpha = {
	Dark = 0.5,
	Darker = 0.75,
	Darkest = 0.95
}

return Def.Quad{
	InitCommand=function(self)
		self:diffuse(0, 0, 0, 0):setsize(width+100, _screen.h):y(-header_height):diffusealpha( mods.BackgroundFilter / 100 )
		if NoteFieldIsCentered then
			self:setsize(width, _screen.h)
		else
			if player==PLAYER_1 then
				self:fadeleft(0.1)
			else
				self:faderight(0.1)
			end
		end
	end
}