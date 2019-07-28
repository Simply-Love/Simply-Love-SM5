-- suppress toasties by overriding _fallback
return Def.Actor{ InitCommand=function(self) self:visible(false) end }