-- Connection: Chapter 4

local scenes = {}
local scene = 1
local duration = { 10, 58, 75, 30, 9.5, 115, 65 }

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

local title = {
	chapter=4,
	img={
		LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/17/Scene 8/monarch 2x1.png"))..{
			InitCommand=function(self) self:zoom(1/3):xy(_screen.cx+126, _screen.cy-42):diffuse(0,0,0,1):SetAllStateDelays(0.145) end,
			OnCommand=function(self)
				self:animate(false)
					:sleep(2):smooth(3):diffuse(0.8,0.8,0.8,1):queuecommand("Wings1")
			end,
			Wings1Command=function(self) self:animate(true):sleep(0.3):queuecommand("Wings2") end,
			Wings2Command=function(self) self:animate(false):sleep(4.5):queuecommand("Wings3") end,
			Wings3Command=function(self) self:animate(true):sleep(0.3):queuecommand("Wings1") end,
		},
	}
}


-- scene 1: Chapter Title
af[#af+1] = LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/14/title.lua"), title)..{
	InitCommand=function(self) scenes[1] = self end,
	OnCommand=function(self) self:queuecommand("StartScene") end
}

-- scene 2: It's funny all the things I never thought I'd be able to do.
-- scene 3: love letters
-- scene 4: smitten
-- scene 5: I miss you, Ben.
-- scene 6: the speed of life
-- scene 7: right now
-- scene 8: epilogue

for i=2, #duration do
	af[#af+1] = LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/17/Scene ".. i .."/default.lua") )..{
		InitCommand=function(self)
			scenes[i] = self
			self:visible(false):diffuse(0,0,0,1)
		end,
	}
end

af[#af+1] = LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/Connection/Proceed.lua"))

return af