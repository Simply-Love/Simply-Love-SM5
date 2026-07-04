local t = Def.ActorFrame {}

t[#t+1] = LoadActor( THEME:GetPathB("ScreenWithMenuElements","background") )
t[#t+1] = Def.Quad{ InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0.65) end }

return t