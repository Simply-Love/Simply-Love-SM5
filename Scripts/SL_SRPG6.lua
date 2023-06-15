SL.SRPG7 = {
	Colors = {
		"#666000",
		"#3d6526",	-- green (main)
		"#36855b",
		"#36a392",
		"#51c0c8",	-- teal (DPRT)
		"#009bcf",
		"#006ecb",
		"#5131a4",	-- blue (Footspeed Empire)
		"#9c0082",
		"#bf0052",
		"#c32020",	-- red (Stamina Nation)
		"#954f00",
	},
	TextColor = "#ffffff",

	-- internal flag
	firstRun = false,

	GetLogo = function()
		return "logo_main (doubleres).png"
	end,
	GetFactionName = function(idx)
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
		ThemePrefs.Set("VisualStyle", "SRPG7")
		ThemePrefs.Set("RainbowMode", false)
		ThemePrefs.Set("LastActiveEvent", "SRPG7")
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
