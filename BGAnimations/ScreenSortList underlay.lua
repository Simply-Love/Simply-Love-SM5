local t = Def.ActorFrame {}

-- slightly darken the entire screen
t[#t+1] = Def.Quad {
	InitCommand = cmd(FullScreen;diffuse,Color.Black;diffusealpha,0.6),
}

-- BG of the sortlist Screen
t[#t+1] = Def.Quad {
	InitCommand = cmd(Center;zoomto,200,150;diffuse,Color.Black),
}

-- white border
t[#t+1] = Border(200, 150, 2) .. {
	InitCommand = cmd(Center),
}

return t
