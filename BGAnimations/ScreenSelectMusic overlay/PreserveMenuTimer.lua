local transitioning_out = false
local menuTimerEnabled = PREFSMAN:GetPreference("MenuTimer")

local Update = function(self, dt)
	if transitioning_out then return end

	-- if the MenuTimer is being used, save the current number of seconds remaining
	-- before transitioning to the next screen. In this manner, we can reinstate this
	-- value if the player opts to return to ScreenSelectMusic from ScreenPlayerOptions.

	-- ScreenSelectMusic might not be the top screen if another screen was
	-- pushed on top, for example, the ScreenPrompt exit confirmation. The timer
	-- and music wheel exist only on ScreenSelectMusic so there's nothing to do
	-- in that case.
	local topscreen = SCREENMAN:GetTopScreen()
	if topscreen:GetName() ~= 'ScreenSelectMusic' then return end

	if menuTimerEnabled then
		SL.Global.MenuTimer.ScreenSelectMusic = topscreen:GetChild("Timer"):GetSeconds()
	end
	SL.Global.WheelLocked = topscreen:GetMusicWheel():IsLocked()
end

return Def.ActorFrame{
	InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end,
	ShowPressStartForOptionsCommand=function(self)
		transitioning_out = true
	end
}