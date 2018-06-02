local transitioning_out = false

local Update = function(self, dt)
	if not transitioning_out then
		SL.Global.MenuTimer.ScreenSelectMusic = SCREENMAN:GetTopScreen():GetChild("Timer"):GetSeconds()
	end
end

return Def.ActorFrame{
	InitCommand=function(self)
		self:draworder(200)
		-- if the MenuTimer is being used, save the current number of seconds remaining
		-- before transitioning to the next screen.  In this manner, we can reinstate this
		-- value if the player opts to return to ScreenSelectMusic from ScreenPlayerOptions.
		if PREFSMAN:GetPreference("MenuTimer") then
			self:SetUpdateFunction(Update)
		end
	end,
	ShowPressStartForOptionsCommand=function(self)
		transitioning_out = true
	end
}