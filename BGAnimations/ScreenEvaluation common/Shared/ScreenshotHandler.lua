-- if we're in Casual mode, don't let players save screenshots at all
if SL.Global.GameMode == "Casual" then return end
-- -----------------------------------------------------------------------

local player = nil

local spr = Def.Sprite{ InitCommand=function(self) self:draworder(200) end }

-- -----------------------------------------------------------------------
-- two distinct (but related) features are handled here in this file

-- first, listen for CodeMessage to be broadcast by the engine to save a png to disk
-- this CodeMessage is defined in metrics.ini under [ScreenEvaluation]
-- (Using a lua-based InputCallback would also have worked here, but this is fewer lines of code.)

spr.CodeMessageCommand=function(self, params)
	if params.Name == "Screenshot" then

		-- format a localized month string like "06-June" or "12-Diciembre"
		local month = ("%02d-%s"):format(MonthOfYear()+1, THEME:GetString("Months", "Month"..MonthOfYear()+1))

		-- get the FullTitle of the song or course that was just played
		local title = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse():GetDisplayFullTitle() or GAMESTATE:GetCurrentSong():GetDisplayFullTitle()

		-- song titles can be very long, and the engine's SaveScreenshot() function
		-- is already hardcoded to make the filename long via DateTime::GetNowDateTime()
		-- so, let's use only the first 25 characters of the title in the screenshot filename
		title = title:utf8sub(1,25)

		-- some song titles have slashes in them, which is interpreted as a folder in the path as
		-- screenshot is saved. we'll substitute those slashes with underscores to prevent this.
		title = title:gsub("%W", "_")

		-- organize screenshots Love into directories, like...
		--      ./Screenshots/Simply_Love/2020/04-April/DVNO-2020-04-22_175951.png
		-- note that the engine's SaveScreenshot() function will convert whitespace
		-- characters to underscores, so we might as well just use underscores here
		local prefix = "Simply_Love/" .. Year() .. "/" .. month .. "/"
		local suffix = "_" .. title

		-- attempt to write a screenshot to disk
		-- arg1 is playernumber that requsted the screenshot; if they are using a profile, the screenshot will be saved there
		-- arg2 is a boolean for whether to use lossy compression on the screenshot before writing to disk
		-- arg3 is a boolean for whther to have CRYPTMAN use the machine's private key to sign the screenshot
		--      (there is currently no online system in place that I know that would benefit from that^)
		-- arg4 is an optional string to prefix the filename with
		-- arg5 is an optional string to append to the end of the filename
		--
		-- first return value is boolean indicating success/failure to write to disk
		-- second return value is
		--     (directory + filename) if write to disk was successful
		--     (filename)             if write to disk failed
		local success, path = SaveScreenshot(params.PlayerNumber, false, false , prefix, suffix)

		if success then
			player = params.PlayerNumber
			MESSAGEMAN:Broadcast("ScreenshotCurrentScreen")
		end
	end
end

-- -----------------------------------------------------------------------
-- second, animate a texture (that looks like a screenshot) to visually signify to the player that the screenshot was saved
--
-- the code here is only half of what's needed for this screen's ScreenShot animation.
--
-- The texture that is loaded into this Sprite actor is created via an
-- ActorFrameTexture in ./BGAnimations/ScreenEvaluationStage background.lua
-- (From on my non-exhaustive testing, having the ActorFrameTexture here in
-- this file would crash StepMania, but it's been a while since I've checked.)
--
-- The AFT there contains an ActorProxy of the entire Screen object, which listens
-- for "ScreenshotCurrentScreen" to be broadcast via MESSAGEMAN.  When that message is
-- broadcast from this file, the ActorProxy there queues a command causing the AFT
-- to become visible for a moment, render, and then go back to being not-drawn.
--
-- Even though the AFT is no longer drawing to the screen, its rendered texture is still
-- in memory.  We put a reference to that texture in the global SL table, so that we can
-- then retrieve it here, assign it to this Sprite, and tween it to the bottom of the screen.


spr.AnimateScreenshotCommand=function(self)
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

return spr