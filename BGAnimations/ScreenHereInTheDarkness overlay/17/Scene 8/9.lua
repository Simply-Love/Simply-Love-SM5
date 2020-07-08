local sleep_time = ...

return Def.ActorFrame{
	InitCommand=function(self) self:diffuse(0,0,0,1):visible(false) end,
	StartSceneCommand=function(self) self:sleep(sleep_time):queuecommand("Show") end,
	ShowCommand=function(self) self:visible(true):smooth(1.5):diffuse(1,1,1,1):sleep(3.35):smooth(1):diffuse(0,0,0,1):queuecommand("Hide") end,
	HideCommand=function(self) self:visible(false) end,

	LoadActor("./7.png")..{
		InitCommand=function(self) self:zoom(2/3):Center() end,
	},

	LoadActor("./8.png")..{
		InitCommand=function(self) self:zoom(2/3):Center():diffuse(1,1,1,0) end,
		StartSceneCommand=function(self) self:sleep(61):smooth(1):diffuse(1,1,1,1) end
	}
}