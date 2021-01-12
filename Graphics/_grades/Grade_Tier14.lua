local path = (SL.Global.GameMode == "DDR" and "./assets/c.png") or "./assets/c-plus.png"

return LoadActor(path)..{ OnCommand=function(self) self:zoom(0.85) end }
