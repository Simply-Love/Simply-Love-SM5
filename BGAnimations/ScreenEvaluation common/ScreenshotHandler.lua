local HasSavedScreenShot = { P1=false, P2=false }

return Def.Sprite{
	Name="ScreenshotSprite",
	InitCommand=cmd(draworder, 200),
	CodeMessageCommand=function(self, params)
		if params.Name == "Screenshot" and not HasSavedScreenShot[ToEnumShortString(params.PlayerNumber)] then

			-- (re)set these upon attempting to take a screenshot since we can potentially
			-- reuse this same sprite for two screenshot animations (one for each player)
			self:Center()
			self:zoomto(_screen.w, _screen.h)

			-- organize Screenshots take using Simply Love into directories, like...
			-- ./Screenshots/Simply_Love/2015/06-June/2015-06-05_121708.png
			local prefix = "Simply_Love/" .. Year() .. "/"
			prefix = prefix .. string.format("%02d", tostring(MonthOfYear()+1)) .. "-" .. THEME:GetString("Months", "Month"..MonthOfYear()+1) .. "/"

			local success, path = SaveScreenshot(params.PlayerNumber, false, true, prefix)
			if success and path then

				-- only allow each player to save a screenshot once!
				HasSavedScreenShot[ToEnumShortString(params.PlayerNumber)] = true
				self:Load(path)

				-- shrink it
				self:accelerate(0.33):zoom(0.2)

				-- make it blink to to draw attention to it
				self:glowshift():effectperiod(0.5)
				self:effectcolor1(1,1,1,0)
				self:effectcolor2(1,1,1,0.2)

				-- sleep with it blinking in the center of the screen for 2 seconds
				self:sleep(2)

				if PROFILEMAN:IsPersistentProfile(params.PlayerNumber) then
					SM("Screenshot saved to " .. ToEnumShortString(params.PlayerNumber) .. "'s Profile.")

					-- tween to the player's bottom corner
					local x_target = params.PlayerNumber == PLAYER_1 and 20 or _screen.w-20
					self:ease(2, 300):xy(x_target, _screen.h+10):zoom(0)
				else
					SM("Screenshot saved to Machine Profile.")
					-- tween directly down
					self:sleep(0.25)
					self:ease(2, 300):y(_screen.h+10):zoom(0)
				end
			end
		end
	end
}