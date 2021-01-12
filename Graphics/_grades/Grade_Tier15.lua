local path = (SL.Global.GameMode == "DDR" and "./assets/c-minus.png") or "./assets/c.png"

return LoadActor(path)..{ OnCommand=function(self) self:zoom(0.85) end }