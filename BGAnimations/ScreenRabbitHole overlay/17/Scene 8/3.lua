local sleep_time = ...

return Def.ActorFrame{
	InitCommand=function(self) self:diffuse(0,0,0,1):visible(false) end,
	StartSceneCommand=function(self) self:sleep(sleep_time):queuecommand("Show") end,
	ShowCommand=function(self) self:visible(true):smooth(1.666):diffuse(1,1,1,1):sleep(1.133):smooth(1.666):diffuse(0,0,0,1):queuecommand("Hide") end,
	HideCommand=function(self) self:visible(false) end,


	Def.ActorFrame{
		InitCommand=function(self) self:zoom(1.05) end,
		ShowCommand=function(self) self:smooth(4.133):addy(-8) end,

		LoadActor("./2.png")..{
			InitCommand=function(self) self:zoom(2/3):Center() end,
		},

		LoadActor("./2b.png")..{
			InitCommand=function(self) self:zoom(2/3):Center():diffusealpha(0) end,
			StartSceneCommand=function(self) self:sleep(sleep_time):smooth(1):diffusealpha(1):smooth(0.666):diffusealpha(0) end
		}
	}
}