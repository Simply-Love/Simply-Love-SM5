local path = (SL.Global.GameMode == "DDR" and "./assets/d.png") or "./assets/c-minus.png"

return LoadActor(path)..{ OnCommand=function(self) self:zoom(0.85) end }
