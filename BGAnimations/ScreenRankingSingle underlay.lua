-- this file is used for for ScreenRankingSingle and ScreenRankingDouble

local af = Def.ActorFrame{}

-- fade in the entire ActorFrame for RankingSingle's OnCommand
af.OnCommand=function(self)
	if SCREENMAN:GetTopScreen():GetName() == "ScreenRankingSingle" then
		self:diffusealpha(0):linear(0.5):diffusealpha(1)
	end
end

-- fade out the entire ActorFrame for RankingDouble's OffCommand
af.OffCommand=function(self)
	if SCREENMAN:GetTopScreen():GetName() == "ScreenRankingDouble" then
		self:linear(0.4):diffusealpha(0)
	end
end

-- the vertical colored bands
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:stretchto(415,78,515,402):diffuse(PlayerColor(PLAYER_1,true)) end
}

af[#af+1] = Def.Quad{
	InitCommand=function(self) self:stretchto(515,78,615,402):diffuse(PlayerColor(PLAYER_2,true)) end
}

--masking quads
-- top mask
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:stretchto(0, _screen.cy-162, _screen.w, 0):MaskSource() end
}

-- bottom mask
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:stretchto(0, _screen.cy+162, _screen.w, _screen.h):MaskSource() end
}

-- gray bars
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:diffuse(0.6,0.6,0.6,1):zoomto(_screen.w, 2):xy(_screen.cx, _screen.cy-163) end,
}
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:diffuse(0.6,0.6,0.6,1):zoomto(_screen.w, 2):xy(_screen.cx, _screen.cy+163) end,
}

return af