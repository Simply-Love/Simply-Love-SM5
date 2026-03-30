local player, header_height, width = unpack(...)
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)

local style = GAMESTATE:GetCurrentStyle():GetName()

local alpha = SL[ToEnumShortString(player)].ActiveModifiers.BackgroundFilter/100
if style ~= "double" then
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
else
	local af = Def.ActorFrame{}
	local xadjust = 0;
	
	-- left side
	af[#af+1] = Def.Quad{
		InitCommand=function(self)
			self:diffuse(0, 0, 0, alpha):setsize(200, _screen.h):x(-GetNotefieldWidth()/2):y(-header_height):halign(1);
		end
	}
	
	-- right side
	af[#af+1] = Def.Quad{
		InitCommand=function(self)
			self:diffuse(0, 0, 0, alpha):setsize(200, _screen.h):x(0 + GetNotefieldWidth()/2):y(-header_height):halign(0);
		end
	}
	
	return af
end
