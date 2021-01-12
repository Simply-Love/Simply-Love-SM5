local path = (SL.Global.GameMode == "DDR" and "./assets/a.png") or "./assets/a-plus.png"

return LoadActor(path)..{ OnCommand=function(self) self:zoom(0.85) end }
