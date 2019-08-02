local pss = ...

return LoadActor("star.lua", pss)..{
	OnCommand=function(self) self:zoom(0.8):pulse():effectmagnitude(1,0.9,0) end
}