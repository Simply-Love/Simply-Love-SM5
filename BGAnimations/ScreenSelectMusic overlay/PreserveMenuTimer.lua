local transitioning_out = false
local menuTimerEnabled = PREFSMAN:GetPreference("MenuTimer")
local Update = function(self, dt)
	if not transitioning_out then
		-- if the MenuTimer is being used, save the current number of seconds remaining
		-- before transitioning to the next screen. In this manner, we can reinstate this
		-- value if the player opts to return to ScreenSelectMusic from ScreenPlayerOptions.
		if menuTimerEnabled then
			SL.Global.MenuTimer.ScreenSelectMusic = SCREENMAN:GetTopScreen():GetChild("Timer"):GetSeconds()
		end
		SL.Global.WheelLocked = SCREENMAN:GetTopScreen():GetMusicWheel():IsLocked()
	end
end

return Def.ActorFrame{
	InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end,
	ShowPressStartForOptionsCommand=function(self)
		transitioning_out = true
	end
}