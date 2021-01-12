local path = (SL.Global.GameMode == "DDR" and "./assets/aa-minus.png") or "./assets/s.png"

return LoadActor(path)..{ OnCommand=function(self) self:zoom(0.85) end }
