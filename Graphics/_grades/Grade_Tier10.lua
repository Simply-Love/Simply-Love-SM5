local path = (SL.Global.GameMode == "DDR" and "./assets/b-plus.png") or "./assets/a-minus.png"

return LoadActor(path)..{ OnCommand=function(self) self:zoom(0.85) end }