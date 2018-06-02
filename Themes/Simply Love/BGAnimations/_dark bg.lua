local t = Def.ActorFrame {}

t[#t+1] = LoadActor( THEME:GetPathB("ScreenWithMenuElements","background") )
t[#t+1] = Def.Quad{ InitCommand=cmd(FullScreen;diffuse,color("0,0,0,0.65")) }

return t