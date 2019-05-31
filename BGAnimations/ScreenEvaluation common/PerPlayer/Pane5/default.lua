local player = ...

-- GrooveStats only supports dance for now.  Don't show the QR code if we're in pump, techno, etc.
if GAMESTATE:GetCurrentGame():GetName() ~= "dance" then return end

-- TimingWindowScale and LifeDifficultyScale are a little confusing.
-- Players can change these under Advanced Options in the operator menu on scales from 1 to Justice and 1 to 7, respectively.
-- 4 is considered standard for ITG.  GrooveStats expects players to have these set to 4.
-- These are both saved and handled internally on a 0 to 1 scale (which makes a lot more sense!).
-- Don't show the QR code if either one isn't set appropriately.
if PREFSMAN:GetPreference("TimingWindowScale") ~= 1 then return end
if PREFSMAN:GetPreference("LifeDifficultyScale") ~= 1 then return end

-- get playeroptions so we can check mods the player used
local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

-- don't show the QR code if player removed notes
if po:Little() or po:NoStretch()
or po:NoHands() or po:NoHolds() or po:NoJumps()
or po:NoLifts() or po:NoQuads() or po:NoRolls()

-- don't show the QR code if player added notes
or po:Wide() or po:Big() or po:Quick() or po:Skippy()
or po:Echo() or po:Stomp() or po:BMRize()

-- only show the QR code for FailTypes "Immediate" and "ImmediateContinue"
or (po:FailSetting() ~= "FailType_Immediate" and po:FailSetting() ~= "FailType_ImmediateContinue")
then
	return
end


-- QR Code should only be active in normal gameplay for individual songs.
-- Only allow Competitive and ECFA because Casual and Stomperz have different settings.
if not GAMESTATE:IsCourseMode() and (SL.Global.GameMode == "Competitive" or
									 SL.Global.GameMode == "ECFA") then
	local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
	local PercentDP = stats:GetPercentDancePoints()

	local score = FormatPercentScore(PercentDP)
	score = tostring(tonumber(score:gsub("%%", "") * 100)):gsub("%.", "")
	local failed = stats:GetFailed() and "1" or "0"
	local rate = tostring(SL.Global.ActiveModifiers.MusicRate * 100):gsub("%.", "")

	local currentSteps = GAMESTATE:GetCurrentSteps(player)
	local difficulty = ""
	if currentSteps then
		difficulty = currentSteps:GetDifficulty();
		-- GetDifficulty() returns a value from the Difficulty Enum
		-- "Difficulty_Hard" for example.
		-- Strip the characters up to and including the underscore.
		difficulty = ToEnumShortString(difficulty)
	end

	-- will need to update this to not be hardcoded to dance if GrooveStats supports other games in the future
	local style = ""
	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
		style = "dance-double"
	else
		style = "dance-single"
	end
	local hash = GenerateHash(style, difficulty):sub(1, 12)

	local qrcode_size = 168

	-- ************* CURRENT QR VERSION *************
	-- * Update whenever we change relevant QR code *
	-- *  and when the backend GrooveStats is also  *
	-- *   updated to properly consume this value.  *
	-- **********************************************
	local qr_version = 2

	local url = ("http://www.groovestats.com/qr.php?h=%s&s=%s&f=%s&r=%s&v=%d"):format(hash, score, failed, rate, qr_version)

	-- ------------------------------------------

	local pane = Def.ActorFrame{
		Name="Pane5",
		InitCommand=function(self)
			self:visible(false)
		end
	}

	pane[#pane+1] = qrcode_amv( url, qrcode_size )..{
		OnCommand=function(self)
			self:xy(-23,190)
		end
	}

	pane[#pane+1] = LoadActor("../Pane2/Percentage.lua", player)

	pane[#pane+1] = LoadFont("_miso")..{
		Text="GrooveStats QR",
		InitCommand=function(self) self:xy(-140, 222):align(0,0) end
	}

	pane[#pane+1] = Def.Quad{
		InitCommand=function(self) self:xy(-140, 245):zoomto(96,1):align(0,0):diffuse(1,1,1,0.33) end
	}

	pane[#pane+1] = LoadFont("_miso")..{
		Text=ScreenString("QRInstructions"),
		InitCommand=function(self) self:zoom(0.8):xy(-140,255):wrapwidthpixels(96/0.8):align(0,0):vertspacing(-4) end
	}

	return pane
end
