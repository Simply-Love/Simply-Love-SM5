local sleep_time = ...

return Def.ActorFrame{
	InitCommand=function(self) self:diffuse(0,0,0,1):visible(false) end,
	StartSceneCommand=function(self) self:sleep(sleep_time):queuecommand("Show") end,
	ShowCommand=function(self) self:visible(true):smooth(2):diffuse(1,1,1,1):sleep(1):smooth(1.333):diffuse(0,0,0,1):queuecommand("Hide") end,
	HideCommand=function(self) self:visible(false) end,

	LoadActor("./6.png")..{
		InitCommand=function(self) self:zoom(2/3):Center() end,
	},
	LoadActor("./6b.png")..{
		InitCommand=function(self) self:zoom(2/3):Center():diffusealpha(0) end,
		ShowCommand=function(self)
			self:sleep(2.35):diffusealpha(1):sleep(0.15):diffusealpha(0)
				:sleep(1):diffusealpha(1):sleep(0.15):diffusealpha(0)
				:sleep(0.15):diffusealpha(1):sleep(0.15):diffusealpha(0)
		end
	}
}