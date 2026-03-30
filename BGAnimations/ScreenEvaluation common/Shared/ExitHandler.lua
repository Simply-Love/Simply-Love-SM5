local holdingCtrl = false

local RestartHandler = function(event)
	if not event then return end

	if event.type == "InputEventType_FirstPress" then
		if event.DeviceInput.button == "DeviceButton_left ctrl" then
			holdingCtrl = true
		elseif event.DeviceInput.button == "DeviceButton_r" then
			if holdingCtrl then
				SM("Replaying Song")
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenGameplay"):StartTransitioningScreen("SM_GoToNextScreen")
			end
		elseif event.DeviceInput.button == "DeviceButton_p" then
			if holdingCtrl then
				SM("Entering Practice Mode")
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenPractice"):StartTransitioningScreen("SM_GoToNextScreen")
			end
		end
	elseif event.type == "InputEventType_Release" then
		if event.DeviceInput.button == "DeviceButton_left ctrl" then
			holdingCtrl = false
		end
	end
end

local t = Def.ActorFrame{
	OnCommand=function(self)
		if ThemePrefs.Get("KeyboardFeatures") and PREFSMAN:GetPreference("EventMode") and not GAMESTATE:IsCourseMode() then
			SCREENMAN:GetTopScreen():AddInputCallback(RestartHandler)
		end
	end
}

return t