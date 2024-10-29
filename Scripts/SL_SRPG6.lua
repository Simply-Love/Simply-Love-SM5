SL.SRPG8 = {
	Colors = {
		            ----------+--------------
		"#666000",  -- Unaff. | Yellow     --
		"#3d6526",  --        | Green      --
		"#36855b",  --        | Green-Blue --
		            ----------+--------------
		"#36a392",  -- DPRT   | Teal       --
		"#51c0c8",  --        | Cyan       --
		"#009bcf",  --        | Light Blue --
		            ----------+--------------
		"#006ecb",  -- FE     | Blue       --
		"#5131a4",  --        | Violet     --
		"#9c0082",  --        | Purple     --
		            ----------+--------------
		"#bf0052",  -- SN     | Pink       --
		"#c32020",  --        | Red        --
		"#954f00",  --        | Orange     --
		            ----------+--------------
	},
	TextColor = "#ffffff",

	-- internal flag
	firstRun = false,

	GetLogo = function()
		return "logo_main (doubleres).png"
	end,
	GetFactionName = function(idx)
		-- Assuming that idx is 1-indexed and
		-- follows the order of the colours above
		if idx <= 3 then
			return "Unaffiliated"
		elseif idx <= 6 then
			return "Democratic People's Republic of Timing"
		elseif idx <= 9 then
			return "Footspeed Empire"
		else
			return "Stamina Nation"
		end
	end,
	ActivateVisualStyle = function(self)
		ThemePrefs.Set("VisualStyle", "SRPG8")
		ThemePrefs.Set("RainbowMode", false)
		ThemePrefs.Set("LastActiveEvent", "SRPG8")
		ThemePrefs.Save()

		MESSAGEMAN:Broadcast("VisualStyleSelected")

		self.firstRun = true

		local screen = SCREENMAN:GetTopScreen()
		if screen ~= nil and screen:GetName() == "ScreenTitleMenu" then
			self:MaybeRandomizeColor()
		end
	end,
	MaybeRandomizeColor = function(self)
		if self.firstRun then
			SL.Global.ActiveColorIndex = 2	-- green/unaffiliated/main logo
			ThemePrefs.Set("SimplyLoveColor", 2)
			MESSAGEMAN:Broadcast("ColorSelected")
			self.firstRun = false
		elseif not ThemePrefs.Get("AllowScreenSelectColor") then
			SL.Global.ActiveColorIndex = MersenneTwister.Random(#self.Colors)
			ThemePrefs.Set("SimplyLoveColor", SL.Global.ActiveColorIndex)
			MESSAGEMAN:Broadcast("ColorSelected")
		end
	end,
}
