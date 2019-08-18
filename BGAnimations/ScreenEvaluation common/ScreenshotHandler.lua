-- if we're in Casual mode, don't let players save screenshots at all
if SL.Global.GameMode == "Casual" then return end

-- The code here is only half of what's needed for this screen's ScreenShot animation.
--
-- The texture that is loaded into this Sprite actor is created via an
-- ActorFrameTexture in ./BGAnimations/ScreenEvaluationStage background.lua
--
-- The AFT there contains an ActorProxy of the entire Screen object, which listens
-- for "ScreenshotCurrentScreen" to be broadcast via MESSAGEMAN.  When that message is
-- broadcast from this file, the ActorProxy there queues a command causing the AFT
-- to become visible for a moment, render, and then go back to being not-drawn.
--
-- Even though the AFT is no longer drawing to the screen, its rendered texture is still
-- in memory.  We put a reference to that texture in the global SL table, so that we can
-- then retrieve it here, assign it to this Sprite, and tween it to the bottom of the screen.

local player = nil

return Def.Sprite{
	InitCommand=function(self) self:draworder(200) end,

	-- This old-school code is defined in Metrics.ini under [ScreenEvaluation]
	-- (Using a lua-based InputCallback would also have worked here.)
	CodeMessageCommand=function(self, params)

		if params.Name == "Screenshot" then
			-- organize Screenshots take using Simply Love into directories, like...
			-- ./Screenshots/Simply_Love/2015/06-June/2015-06-05_121708.png
			local prefix = "Simply_Love/" .. Year() .. "/"
			prefix = prefix .. string.format("%02d", tostring(MonthOfYear()+1)) .. "-" .. THEME:GetString("Months", "Month"..MonthOfYear()+1) .. "/"

			local success, path = SaveScreenshot(params.PlayerNumber, false, true, prefix)
			if success then
				player = params.PlayerNumber

				MESSAGEMAN:Broadcast("ScreenshotCurrentScreen")
			end
		end
	end,


	AnimateScreenshotCommand=function(self)
		-- (re)set these upon attempting to take a screenshot since we can
		-- reuse this same sprite for multiple screenshot animations
		self:finishtweening()
		self:Center():zoomto(_screen.w, _screen.h)
		self:SetTexture(SL.Global.ScreenshotTexture)

		-- shrink it
		self:zoom(0.2)

		-- make it blink to to draw attention to it
		self:glowshift():effectperiod(0.5)
		self:effectcolor1(1,1,1,0)
		self:effectcolor2(1,1,1,0.2)

		-- sleep with it blinking in the center of the screen for 0.5 seconds
		self:sleep(0.4)

		if player and PROFILEMAN:IsPersistentProfile(player) then
			-- tween to the player's bottom corner
			local x_target = player==PLAYER_1 and 20 or _screen.w-20
			self:smooth(0.75):xy(x_target, _screen.h+10):zoom(0)
		else
			SM(THEME:GetString("ScreenEvaluation", "MachineProfileScreenshot"))
			-- tween directly down
			self:sleep(0.25)
			self:smooth(0.75):y(_screen.h+10):zoom(0)
		end

		player = nil
	end
}
