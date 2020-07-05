local args = ...
local duration = args.duration
local scenes = args.scenes
local scene = 1

return Def.ActorFrame{
	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
			self:queuecommand("TransitionScene")
		end
	end,
	OnCommand=function(self)
		self:GetChild("Proceed"):sleep( duration[1] ):queuecommand("Show")
	end,
	TransitionSceneCommand=function(self)
		self:GetChild("Proceed"):stoptweening():queuecommand("Hide")
		scenes[scene]:queuecommand("FadeOutAudio"):smooth(1):diffuse( Color.Black )
		self:sleep(1):queuecommand("SwitchScene")
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