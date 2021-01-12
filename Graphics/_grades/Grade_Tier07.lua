local path = (SL.Global.GameMode == "DDR" and "./assets/a-plus.png") or "./assets/s-minus.png"

return LoadActor(path)..{ OnCommand=function(self) self:zoom(0.85) end }
