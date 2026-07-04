return Def.Quad{
	InitCommand=function(self) self:Center():FullScreen():diffuse(0,0,0,0) end,
	OnCommand=function(self) self:finishtweening():accelerate(0.3):diffusealpha(0.9) end,
	OffCommand=function(self) self:diffusealpha(0) end
}