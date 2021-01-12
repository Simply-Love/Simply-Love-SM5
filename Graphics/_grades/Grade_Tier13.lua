local path = (SL.Global.GameMode == "DDR" and "./assets/c-plus.png") or "./assets/b-minus.png"

return LoadActor(path)..{ OnCommand=function(self) self:zoom(0.85) end }
