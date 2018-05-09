-- rainy day

local af = Def.ActorFrame{}
af.InputEventCommand=function(self, event)
	if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
end
-- af.InitCommand=function(self) self:diffusealpha(0) end
-- af.OnCommand=function(self)
-- 	self:sleep(2):linear(1):diffusealpha(1)
-- end
--
-- af[#af+1] = Def.Sound{
-- 	File=THEME:GetPathB("ScreenRabbitHole", "overlay/8/rainy.ogg"),
-- 	OnCommand=function(self) self:play() end
-- }
--
-- af[#af+1] = Def.Sprite{
-- 	Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/8/rainy.mp4"),
-- 	InitCommand=function(self)
-- 		self:Center():loop(true)
-- 		if IsUsingWideScreen() then
-- 			self:FullScreen()
-- 		end
-- 	end
-- }

return af