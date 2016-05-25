if SL.Global.GameMode ~= "Casual" then

	local player_that_screenshot_is_for = nil
	local HasSavedScreenShot = { P1=false, P2=false }

	return Def.Sprite{
		InitCommand=cmd(draworder, 200),

		CodeMessageCommand=function(self, params)
			if params.Name == "Screenshot" and not HasSavedScreenShot[ToEnumShortString(params.PlayerNumber)] then
				-- organize Screenshots take using Simply Love into directories, like...
				-- ./Screenshots/Simply_Love/2015/06-June/2015-06-05_121708.png
				local prefix = "Simply_Love/" .. Year() .. "/"
				prefix = prefix .. string.format("%02d", tostring(MonthOfYear()+1)) .. "-" .. THEME:GetString("Months", "Month"..MonthOfYear()+1) .. "/"

				local success, path = SaveScreenshot(params.PlayerNumber, false, true, prefix)
				if success then
					-- only allow each player to save a screenshot once!
					HasSavedScreenShot[ToEnumShortString(params.PlayerNumber)] = true
					player_that_screenshot_is_for = params.PlayerNumber

					MESSAGEMAN:Broadcast("ScreenshotCurrentScreen")
				end
			end
		end,


		AnimateScreenshotCommand=function(self)
			-- (re)set these upon attempting to take a screenshot since we can potentially
			-- reuse this same sprite for two screenshot animations (one for each player)
			self:Center():zoomto(_screen.w, _screen.h)
			self:SetTexture(SL.Global.ScreenshotTexture)

			-- shrink it
			self:zoom(0.2)

			-- make it blink to to draw attention to it
			self:glowshift():effectperiod(0.5)
			self:effectcolor1(1,1,1,0)
			self:effectcolor2(1,1,1,0.2)

			-- sleep with it blinking in the center of the screen for 2 seconds
			self:sleep(2)

			if PROFILEMAN:IsPersistentProfile(player_that_screenshot_is_for) then
				SM("Screenshot saved to " .. ToEnumShortString(player_that_screenshot_is_for) .. "'s Profile.")

				-- tween to the player's bottom corner
				local x_target = player_that_screenshot_is_for == PLAYER_1 and 20 or _screen.w-20
				self:ease(2, 300):xy(x_target, _screen.h+10):zoom(0)
			else
				SM("Screenshot saved to Machine Profile.")
				-- tween directly down
				self:sleep(0.25)
				self:ease(2, 300):y(_screen.h+10):zoom(0)
			end

			player_that_screenshot_is_for = nil
		end
	}
end