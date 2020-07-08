local start_time = ...
local reveal_time = { 52.487, 53.51, 54.443, 55.356 }
local leadin = 0.25
local end_time = 58.352

return Def.ActorFrame{
	InitCommand=function(self) self:visible(false) end,
	StartSceneCommand=function(self) self:sleep(start_time):queuecommand("Show") end,
	ShowCommand=function(self) self:visible(true):sleep(end_time-start_time):queuecommand("Hide") end,
	HideCommand=function(self) self:visible(false) end,

	Def.ActorFrame{
		InitCommand=function(self) self:diffuse(0,0,0,0) end,
		StartSceneCommand=function(self) self:sleep(reveal_time[1]-leadin):smooth(0.15):diffuse(1,1,1,1):sleep(reveal_time[2]-reveal_time[1]):smooth(0.5):diffuse(0,0,0,0) end,

		Def.BitmapText{
			File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/verdana/_verdana 20px.ini"),
			Text="Keep writing or I will jump on you!",
			InitCommand=function(self) self:xy(_screen.cx-WideScale(250,350), 200):halign(0):diffuse(0.8, 0.666, 0.666, 1) end,
		},
	},

	Def.ActorFrame{
		InitCommand=function(self) self:diffuse(0,0,0,0) end,
		StartSceneCommand=function(self) self:sleep(reveal_time[2]-leadin):smooth(0.15):diffuse(1,1,1,1):sleep(reveal_time[3]-reveal_time[2]):smooth(0.5):diffuse(0,0,0,0) end,

		Def.BitmapText{
			File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/monaco/_monaco 20px.ini"),
			Text="I think I might be lonely.",
			InitCommand=function(self) self:xy(_screen.cx+WideScale(0,50), 350):halign(0):diffuse(0.666, 0.666, 0.8, 1) end,
		},
	},

	Def.ActorFrame{
		InitCommand=function(self) self:diffuse(0,0,0,0) end,
		StartSceneCommand=function(self) self:sleep(reveal_time[3]-leadin):smooth(0.15):diffuse(1,1,1,1):sleep(reveal_time[4]-reveal_time[3]):smooth(0.5):diffuse(0,0,0,0) end,

		Def.BitmapText{
			File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
			Text="I've never thought of you that way.",
			InitCommand=function(self) self:xy(_screen.cx-WideScale(300,400), 100):halign(0):diffuse(0.8, 0.666, 0.666, 1) end,
		},
	},


	Def.ActorFrame{
		InitCommand=function(self) self:diffuse(0,0,0,0) end,
		StartSceneCommand=function(self) self:sleep(reveal_time[4]-leadin):smooth(0.15):diffuse(1,1,1,1):sleep(1):smooth(2):diffuse(0,0,0,0) end,

		Def.BitmapText{
			File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/monaco/_monaco 20px.ini"),
			Text="Even after all these years,\nI still love you.",
			InitCommand=function(self) self:xy(_screen.cx-160, 200):halign(0):diffuse(0.666, 0.666, 0.8, 1) end,
		},
	},
}