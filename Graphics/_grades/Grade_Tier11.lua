local path = (SL.Global.GameMode == "DDR" and "./assets/b.png") or "./assets/b-plus.png"

return LoadActor(path)..{ OnCommand=function(self) self:zoom(0.85) end }
