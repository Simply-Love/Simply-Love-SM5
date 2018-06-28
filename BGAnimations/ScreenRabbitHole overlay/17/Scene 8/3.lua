local sleep_time = ...

return Def.ActorFrame{
	InitCommand=function(self) self:diffuse(0,0,0,1):visible(false) end,
	StartSceneCommand=function(self) self:sleep(sleep_time):queuecommand("Show") end,
	ShowCommand=function(self) self:visible(true):smooth(1.666):diffuse(1,1,1,1):sleep(0.8):smooth(2):diffuse(0,0,0,1):queuecommand("Hide") end,
	HideCommand=function(self) self:visible(false) end,

	LoadActor("./2.png")..{
		InitCommand=function(self) self:zoom(2/3):Center() end,
	},

	LoadActor("./2b.png")..{
		InitCommand=function(self) self:zoom(2/3):Center():diffusealpha(0) end,
		StartSceneCommand=function(self) self:sleep(sleep_time):smooth(1):diffusealpha(1):smooth(0.666):diffusealpha(0) end
	}
}