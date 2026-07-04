local af = Def.ActorFrame{}

-- darken the entire screen slightly
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0) end,
	OnCommand=function(self) self:accelerate(0.5):diffusealpha(0.5) end,
	OffCommand=function(self) self:accelerate(0.5):diffusealpha(0) end
}

-- Intructions BG
af[#af+1] = Def.Quad {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy-40):zoomto(_screen.w*0.75, _screen.h*0.25):diffuse(GetCurrentColor()) end
}
-- white border
af[#af+1] = Border(_screen.w*0.75, _screen.cy*0.5, 2) .. {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy-40) end
}


-- Text Entry BG
af[#af+1] = Def.Quad {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+16):zoomto(_screen.w*0.75, 40):diffuse(0,0,0,1) end
}
-- white border
af[#af+1] = Border(_screen.w*0.75, 40, 2)..{
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+16) end
}

return af