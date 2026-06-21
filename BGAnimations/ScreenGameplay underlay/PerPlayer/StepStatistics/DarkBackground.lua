local player, header_height, width = unpack(...)

local style = GAMESTATE:GetCurrentStyle():GetName()

local FilterAlpha = BackgroundFilterValues()
local alpha = clamp(FilterAlpha[SL[ToEnumShortString(player)].ActiveModifiers.BackgroundFilter]/100 or 0, 0.25, 0.9)
if style ~= "double" then
	return Def.Quad{
		InitCommand=function(self)
			self:diffuse(0, 0, 0, alpha):setsize(width, _screen.h):y(-header_height)
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