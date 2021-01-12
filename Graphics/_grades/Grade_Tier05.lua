local path = (SL.Global.GameMode == "DDR" and "./assets/aa.png") or "./assets/s-plus.png"

return LoadActor(path)..{ OnCommand=function(self) self:zoom(0.85) end }