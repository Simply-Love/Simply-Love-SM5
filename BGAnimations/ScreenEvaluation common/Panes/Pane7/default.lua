-- Pane7 displays QR codes for uploading scores to groovestats.com

local player, _, ComputedData = unpack(...)

local checks, allChecksPassed = ValidForGrooveStats(player)

local url, text = nil, ""
local X_HasBeenBlinked = false

-- GrooveStatsURL.lua returns a formatted URL with some parameters in the query string
if allChecksPassed then

	-- don't generate the GrooveStats URL twice if only one player is joined
	-- and we've already generated it for a previous controller's pane
	-- it involves expensive hash computations
	if ComputedData and ComputedData.GrooveStatsURL then
		url = ComputedData.GrooveStatsURL
	else
		url = LoadActor("./GrooveStatsURL.lua", player)
		if ComputedData then ComputedData.GrooveStatsURL = url end
	end

	text = ScreenString("QRInstructions")

else
	-- hbdi
	url = "https://www.youtube.com/watch?v=FMABVVk4Ge4"

	for i, passed_check in ipairs(checks) do
		if passed_check == false then
			-- the 4th check is GameMode (ITG, FA+, Casual, etc.)
			if i==4 then
				-- that string has a %s token so we can pass in the current SL GameMode
				text = text .. ScreenString("QRInvalidScore"..i):format(SL.Global.GameMode) .. "\n"
			else
				-- other strings can be used as-is
				text = text .. ScreenString("QRInvalidScore"..i) .. "\n"
			end
		end
	end
end

local qrcode_size = 168

-- ------------------------------------------

local pane = Def.ActorFrame{
	InitCommand=function(self) self:xy(-140, 222) end,
	PaneSwitchCommand=function(self)
		if self:GetVisible() and not allChecksPassed and not X_HasBeenBlinked then
			self:queuecommand("BlinkX")
		end
	end
}

local qr_amv
-- don't generate the QR code twice if only one player is joined
-- and we've already generated it for a previous controller's pane
if ComputedData and ComputedData.QRCode then
	qr_amv = ComputedData.QRCode
else
	local qr_module_path = THEME:GetPathB("", "_modules/QR Code/SL-QRCode.lua")
	qr_amv = LoadActor( qr_module_path , {url, qrcode_size} )..{
		Name="QRCode",
		InitCommand=function(self) self:xy(116, -32):align(0,0.5) end,
		HideCommand=function(self) self:GetChild("QRCodeData"):queuecommand("Hide") end
	}
	if ComputedData then ComputedData.QRCode = qr_amv end
end

pane[#pane+1] = qr_amv

-- red X to visually cover the QR code if the score was invalid
if not allChecksPassed then
	pane[#pane+1] = LoadActor("x.png")..{
		InitCommand=function(self)
			self:zoom(1):xy(120,-28):align(0,0)
		end,
		-- blink the red X once when the player first toggles into the QR pane
		BlinkXCommand=function(self)
			X_HasBeenBlinked = true
			self:finishtweening():sleep(0.25):linear(0.3):diffusealpha(0):sleep(0.175):linear(0.3):diffusealpha(1)
		end
	}
end

pane[#pane+1] = LoadActor("../Pane3/Percentage.lua", player)..{
	OnCommand=function(self) self:xy(25, -22) end
}

pane[#pane+1] = LoadFont("Common Normal")..{
	Text="GrooveStats QR",
	InitCommand=function(self) self:align(0,0) end
}

pane[#pane+1] = Def.Quad{
	InitCommand=function(self) self:y(23):zoomto(96,1):align(0,0):diffuse(1,1,1,0.33) end
}

-- if there are multiple reasons the score was invalid for GrooveStats ranking
-- the help text might spill outside the vertical bounds of the pane
-- hide any such spillover with a mask
if not allChecksPassed then
	pane[#pane+1] = Def.Quad{
		InitCommand=function(self) self:xy(-10, 142):zoomto(121,140):align(0,0):MaskSource() end
	}
end

-- localized help text, either "use your phone to scan" or "here's why your score was invalid"
pane[#pane+1] = LoadFont("Common Normal")..{
	Text=text,
	Name="HelpText",
	InitCommand=function(self)
		self:align(0,0):vertspacing(-3):MaskDest()

		local z = allChecksPassed and 0.8 or 0.675
		self:zoom(z)
		self:y( scale(35, 0,0.8,   0,z) )
		self:x( scale(-4, 0,0.675, 0,z) )
		self:wrapwidthpixels( scale(98, 0,0.675, 0,z)/z)

		-- FIXME: Oof.
		if THEME:GetCurLanguage() == "ja" then self:_wrapwidthpixels( scale(96, 0,0.8, 0,z)/z ) end
	end,
}


return pane
