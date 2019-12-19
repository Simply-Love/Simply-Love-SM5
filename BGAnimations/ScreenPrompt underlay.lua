local af = Def.ActorFrame{}

-- darken the entire screen a little
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0) end,
	OnCommand=function(self) self:accelerate(0.5):diffusealpha(0.5) end,
	OffCommand=function(self) self:accelerate(0.5):diffusealpha(0) end
}

-- the BG for the prompt itself
af[#af+1] = Def.Quad {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy-56):zoomto(_screen.w*0.75, _screen.h*0.25):diffuse(GetCurrentColor()) end
}
-- white border around prompt
af[#af+1] = Border(_screen.w*0.75, _screen.h*0.25, 2)..{
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy-56) end
}

-- the BG for the choices presented to the player
af[#af+1] = Def.Quad {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+120):zoomto(_screen.w*0.75, _screen.h*0.125) end,
	OnCommand=function(self) self:diffuse(0,0,0,1) end
}
-- white border for choices
af[#af+1] = Border(_screen.w*0.75, _screen.cy*0.25, 2)..{
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+120) end
}

return af