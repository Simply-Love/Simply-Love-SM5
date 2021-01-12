local path = (SL.Global.GameMode == "DDR" and "./assets/a-minus.png") or "./assets/a.png"

return LoadActor(path)..{ OnCommand=function(self) self:zoom(0.85) end }
