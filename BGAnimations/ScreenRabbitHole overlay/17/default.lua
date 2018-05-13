-- Connection: Chapter 4

local scenes = {}
local scene = 1

local scene2 = {
	delay=0.0545,
	width=400,
	song="17/Wings.ogg",
	header="FROM:  Zoe\nTO:  Ben\nDATE:  Jul-10-2010\nSUBJECT:  It's been a while.\n---------------------------------------------------------",
	body="I've been thinking a lot about you and the US recently. I hope everything is wonderful for you right now.\n\nI am exceedingly cheerful and motivated at uni and just in general. It's funny all the things I never thought I'd be able to do. I'm more than a sixth of the way to getting a degree, which amazes me.\n\nI'm studying logic, which made me think of you. Logic in words is so much harder than I thought it would be, but you might be a natural with your programming finesse.\n\nOtherwise, I'm pretty good.  I see a lot more people here and have made a few good friends.\n\nOne guy I think you would really like is an astronomy PhD, but also legally blind, which he thinks nothing of, but I find fascinating.  He is a little nerdy but completely sweet and joyous, which I like.  He makes me think of you sometimes.\n\nAnyway, write back when you get a chance and feel free to rant on about whatever you'd like. I hope you are happy and safe and warm where you are.\n\nLove,\nZ",
}

local scene5 = {
	{ author="Zoe", delay=0, words="I am having a tough day today. It's nice to feel you out there." },
	{ author="Zoe", delay=3, words="I'm so glad we've stayed friends all this time. " },
	{ author="Zoe", delay=7, words="It's nice to be reminded I didn't just become worthy of love as I grew up, that I've always been an okay person." },
	{ author="Ben", startTyping=9, send=12, words="You've always been good to me." },
	{ author="Zoe", delay=14, words="I do wonder sometimes." },
	{ author="Ben", startTyping=16, send=21, words="Hmm.  Life is weird.  I work a lot.  Too much, probably." },
	{ author="Ben", startTyping=23, send=27, words="I have a girlfriend now.  She's very kind to me." },
	{ author="Ben", startTyping=28.5, send=30.5, words="I miss you, too." },
	{ author="Ben", startTyping=32.5, send=37, words="I don't even understand how I can miss someone I've never met." },
	{ author="Zoe", delay=40, words="It's maybe because we've known each other for such a long time now." },
	{ author="Zoe", delay=44, words="But I don't feel the same way about lots of other people." },
}


local af = Def.ActorFrame{
	InputEventCommand=function(self, event)
		if scene == 3 then
			self:playcommand("Ch4Sc3Input", event)
		else
			if not event.PlayerNumber or not event.button then return false end
			if  event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
				self:queuecommand("TransitionScene")
			end
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
af[#af+1] = LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/17/newer-email.lua"), scene2)..{
	InitCommand=function(self)
		scenes[2] = self
		self:visible(false)
	end,
}

-- scene 3: I've known her now, what, the last four or five years?
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/doubts.lua") )..{
	InitCommand=function(self)
		scenes[3] = self
		self:visible(false)
	end,
}

-- scene 4: I miss you, Ben.
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/sms.lua") )..{
	InitCommand=function(self)
		scenes[4] = self
		self:visible(false)
	end,
}


-- scene 5: the speed of life
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/stargazing.lua") )..{
	InitCommand=function(self)
		scenes[5] = self
		self:visible(false)
	end,
}


-- scene 6: epilogue



return af