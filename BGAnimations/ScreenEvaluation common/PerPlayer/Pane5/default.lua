local player = ...

-- GrooveStats only supports dance for now.  Don't show the QR code if we're in pump, techno, etc.
if GAMESTATE:GetCurrentGame():GetName() ~= "dance" then return end

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
	local url = ("http://www.groovestats.com/qr.php?h=%s&s=%s&f=%s&r=%s"):format(hash, score, failed, rate)

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
