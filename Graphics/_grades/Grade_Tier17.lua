local path = (SL.Global.GameMode == "DDR" and "./assets/f.png") or "./assets/d.png"

return LoadActor(path)..{ 	OnCommand=function(self) self:zoom(0.85) end }