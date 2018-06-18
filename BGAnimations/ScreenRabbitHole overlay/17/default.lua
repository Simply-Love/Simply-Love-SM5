-- Connection: Chapter 4

local scenes = {}
local scene = 1
local duration = { 10, 58, 75, 30, 9.5, 108.5, 65 }

local af = Def.ActorFrame{
	InputEventCommand=function(self, event)
		if not event.PlayerNumber or not event.button then return false end
		if scene == 3 then
			scenes[3]:playcommand("Ch4Sc3InputEvent", event)
		else
			if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
				self:queuecommand("TransitionScene")
			end
		end
	end,
	OnCommand=function(self)
		self:GetChild("Proceed"):sleep( duration[1] ):queuecommand("Show")
	end,
	TransitionSceneCommand=function(self)
		self:GetChild("Proceed"):stoptweening():queuecommand("Hide")

		if scene == 7 then
			scenes[7]:queuecommand("FadeOutAudio")
			self:sleep(2):queuecommand("SwitchScene")
		else
			scenes[scene]:queuecommand("FadeOutAudio"):smooth(1):diffuse( Color.Black )
			self:sleep(1):queuecommand("SwitchScene")
		end
	end,
	SwitchSceneCommand=function(self)
		scenes[scene]:hibernate(math.huge)

		if scenes[scene+1] then
			scene = scene + 1
			self:GetChild("Proceed"):sleep( duration[scene] ):queuecommand("Show")
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
af[#af+1] = LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/17/newer-email.lua") )..{
	InitCommand=function(self)
		scenes[2] = self
		self:visible(false):diffuse(0,0,0,1)
	end,
}

-- scene 3: love letters
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/love-letters.lua") )..{
	InitCommand=function(self)
		scenes[3] = self
		self:visible(false):diffuse(0,0,0,1)
	end,
}

-- scene 4: smitten
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/social-media.lua") )..{
	InitCommand=function(self)
		scenes[4] = self
		self:visible(false):diffuse(0,0,0,1)
	end,
}

-- scene 5: I miss you, Ben.
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/new-text-message.lua") )..{
	InitCommand=function(self)
		scenes[5] = self
		self:visible(false):diffuse(0,0,0,1)
	end,
}

-- scene 6: the speed of life
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/sms.lua") )..{
	InitCommand=function(self)
		scenes[6] = self
		self:visible(false):diffuse(0,0,0,1)
	end,
}

-- scene 7: Right NOW
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/right-now.lua") )..{
	InitCommand=function(self)
		scenes[7] = self
		self:visible(false):diffuse(0,0,0,1)
	end,
}

-- scene 8: epilogue


af[#af+1] = LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/Connection/Proceed.lua"))

return af