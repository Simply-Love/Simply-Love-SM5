-- Connection: Chapter 4

local scenes = {}
local scene = 1

local scene1 = {
	delay=0.0535,
	width=400,
	song="17/wings.ogg",
	header="FROM:  Zoe\nTO:  Ben\nDATE:  Jul-10-2010\nSUBJECT:  It's been a while.\n---------------------------------------------------------",
	body="I've been thinking a lot about you and the US recently. I hope everything is wonderful for you right now.\n\nI am exceedingly cheerful and motivated at uni and just in general. It's funny all the things I never thought I'd be able to do. I'm more than a sixth of the way to getting a degree, which amazes me.\n\nI'm studying logic, which made me think of you. Logic in words is so much harder than I thought it would be, but you might be a natural with your programming finesse.\n\nOtherwise, I'm pretty good.  I see a lot more people here and have made a few good friends.\n\nOne guy I think you would really like is an astronomy PhD, but also legally blind, which he thinks nothing of, but I find fascinating.  He is a little nerdy but completely sweet and joyous, which I like.  He makes me think of you sometimes.\n\nAnyway, write back when you get a chance and feel free to rant on about whatever you'd like. I hope you are happy and safe and warm where you are.\n\nLove,\nZ",
}



local af = Def.ActorFrame{
	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
			self:queuecommand("TransitionScene")
		end
	end,
	TransitionSceneCommand=function(self)
		scenes[scene]:queuecommand("FadeOutAudio"):smooth(1):diffuse( Color.Black )
		self:sleep(1):queuecommand("SwitchScene")
	end,
	SwitchSceneCommand=function(self)
		scenes[scene]:hibernate(math.huge)

		if scenes[scene+1] then
			scene = scene + 1
			scenes[scene]:queuecommand("StartScene")
		else
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
}

-- scene 1: Chapter Title
af[#af+1] = LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/14/title.lua"), 4)..{
	InitCommand=function(self) scenes[1] = self end,
	OnCommand=function(self) self:queuecommand("StartScene") end
}

-- scene 2: It's funny all the things I never thought I'd be able to do.
af[#af+1] = LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/14/email.lua"), scene1)..{
	InitCommand=function(self)
		scenes[2] = self
		self:visible(false)
	end,
}


-- scene 3: the speed of life


-- scene 4: I've known her now, what, the last four or five years?
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/stargazing.lua") )..{
	InitCommand=function(self)
		scenes[3] = self
		self:visible(false)
	end,

}


-- scene 5: epilogue



return af