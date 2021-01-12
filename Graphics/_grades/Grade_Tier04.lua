local pss = ...

if SL.Global.GameMode == "DDR" then
    return LoadActor("./assets/aa-plus.png")..{ OnCommand=function(self) self:zoom(0.85) end }
end

return LoadActor("star.lua", pss)..{
	OnCommand=function(self) self:zoom(0.8):pulse():effectmagnitude(1,0.9,0) end
}