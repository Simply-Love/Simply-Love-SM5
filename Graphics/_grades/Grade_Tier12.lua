local path = (SL.Global.GameMode == "DDR" and "./assets/b-minus.png") or "./assets/b.png"

return LoadActor(path)..{ OnCommand=function(self) self:zoom(0.85) end }
