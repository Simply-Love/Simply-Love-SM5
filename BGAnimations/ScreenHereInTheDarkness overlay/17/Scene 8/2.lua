local sleep_time = ...

return Def.ActorFrame{
	InitCommand=function(self) self:diffuse(0,0,0,1):visible(false) end,
	StartSceneCommand=function(self) self:sleep(sleep_time):queuecommand("Show") end,
	ShowCommand=function(self) self:visible(true):smooth(1.666):diffuse(1,1,1,1):sleep(1):smooth(1.666):diffuse(0,0,0,1):queuecommand("Hide") end,
	HideCommand=function(self) self:visible(false) end,


	Def.ActorFrame{
		InitCommand=function(self) self:zoom(1.025) end,
		ShowCommand=function(self) self:smooth(4.333):addx(-5) end,

		LoadActor("./1.png")..{
			InitCommand=function(self) self:zoom(2/3):align(0,0):xy(0,0) end,
		},
	}
}