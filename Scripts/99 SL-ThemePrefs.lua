-- For more information on how ThemePrefs works, read:
-- ./StepMania 5/Docs/ThemerDocs/ThemePrefs.txt
-- ./StepMania 5/Docs/ThemerDocs/ThemePrefsRows.txt

SL_CustomPrefs = {}

-- the ThemePrefs system was removed wholesale from SM5.2
-- If the ThemePrefs system isn't found, provide a simple shim that will keep SL from completely
-- falling apart just long enough for the player to be notified that SM5.2 isn't supported.
if type(ThemePrefs) ~= "table" or type(ThemePrefs.Get) ~= "function" then
	ThemePrefs = {
		Get=function(arg) return SL_CustomPrefs.Get()[arg].Default end,
		Set=function() return end
	}
end

SL_CustomPrefs.Get = function()
	 -- emojis are our lingua franca for the 21st century
	local visualStyleChoices = { "❤", "↖", "🐻", "🦆", "😺", "🎃", "🌈", "⭐", "🤔" }
	local visualStyleValues  = { "Hearts", "Arrows", "Bears", "Ducks", "Cats", "Spooky", "Gay", "Stars", "Thonk" }

	local year = Year()
	local month = MonthOfYear()+1
	local day = DayOfMonth()
	local today = year * 10000 + month * 100 + day

	if today >= 20220617 then
		visualStyleChoices[#visualStyleChoices+1] = "💍"
		visualStyleValues[#visualStyleValues+1] = "SRPG6"
	else
		local prefs = IniFile.ReadFile("/Save/ThemePrefs.ini")
		local theme = PREFSMAN:GetPreference("Theme")
		local lastActiveEvent = nil
		if prefs[theme] and prefs[theme].LastActiveEvent == "SRPG6" then
			visualStyleChoices[#visualStyleChoices+1] = "💍"
			visualStyleValues[#visualStyleValues+1] = "SRPG6"
		end
	end

	return {
		AllowFailingOutOfSet =
		{
			Default = true,
			Choices = { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values  = { true, false }
		},
		NumberOfContinuesAllowed =
		{
			Default = 0,
			Choices = { 0,1,2,3,4,5,6,7,8,9 },
			Values  = { 0,1,2,3,4,5,6,7,8,9 }
		},
		HideStockNoteSkins =
		{
			Default = false,
			Choices = { THEME:GetString("ThemePrefs", "Show"), THEME:GetString("ThemePrefs", "Hide") },
			Values  = { false, true }
		},
		MusicWheelStyle =
		{
			Default = "ITG",
			Choices = { "ITG", "IIDX" }
		},
		MusicWheelGS =
		{
			Default = "Scorebox",
			Choices = { "Scorebox", "Pane", "Off" }
		},
		FolderStats =
		{
			Default = true,
			Choices = { THEME:GetString("ThemePrefs", "Show"), THEME:GetString("ThemePrefs", "Hide") },
			Values  = { true, false }
		},
		AllowDanceSolo =
		{
			Default = false,
			Choices = { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values  = { true, false }
		},
		DefaultGameMode =
		{
			Default = "ITG",
			Choices = {
				THEME:GetString("ScreenSelectPlayMode", "Casual"),
				THEME:GetString("ScreenSelectPlayMode", "ITG"),
				THEME:GetString("ScreenSelectPlayMode", "FA+"),
			},
			Values = { "Casual", "ITG", "FA+" }
		},
		AutoStyle =
		{
			Default = "none",
			Choices = {
				THEME:GetString("ScreenSelectStyle", "None"),
				THEME:GetString("ScreenSelectStyle", "Single"),
				THEME:GetString("ScreenSelectStyle", "Versus"),
				THEME:GetString("ScreenSelectStyle", "Double")
			},
			Values = { "none", "single", "versus", "double" }
		},
		VisualStyle =
		{
			Default = "Hearts",
			Choices = visualStyleChoices,
			Values  = visualStyleValues
		},
		RainbowMode = {
			Default = false,
			Choices = {
				THEME:GetString("ThemePrefs", "On"),
				THEME:GetString("ThemePrefs", "Off")
			},
			Values = { true , false }
		},
		WriteCustomScores = {
			Default = false,
			Choices =  { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values	= { true, false }
		},
		KeyboardFeatures = {
			Default = false,
			Choices =  { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values	= { true, false }
		},
		-- - - - - - - - - - - - - - - - - - - -
		-- SimplyLoveColor saves the theme color for the next time
		-- the StepMania application is started.
		SimplyLoveColor =
		{
			-- a nice pinkish-purple, by default
			Default = 3,
			Choices = { 1,2,3,4,5,6,7,8,9,10,11,12 },
			Values  = { 1,2,3,4,5,6,7,8,9,10,11,12 }
		},
		-- - - - - - - - - - - - - - - - - - - -
		-- Save the last seen song in Edit Mode to disk so that ScreenEditMenu
		-- can load with it already selected, instead of the first song in the
		-- first pack.  See: ./BGAnimations/ScreenEditMenu underlay.lua
		EditModeLastSeenSong =
		{
			Default = "",
		},
		EditModeLastSeenStepsType =
		{
			Default = "",
		},
		EditModeLastSeenStyleType =
		{
			Default = "",
		},
		EditModeLastSeenDifficulty =
		{
			Default = "",
		},
		-- - - - - - - - - - - - - - - - - - - -
		-- MenuTimer values for various screens
		ScreenSelectMusicMenuTimer =
		{
			Default = 300,
			Choices = map(SecondsToMSS, range(60, 450, 15)),
			Values  = range(60, 450, 15),
		},
		ScreenSelectMusicCasualMenuTimer =
		{
			Default = 300,
			Choices = map(SecondsToMSS, range(60, 450, 15)),
			Values  = range(60, 450, 15),
		},
		ScreenPlayerOptionsMenuTimer =
		{
			Default = 90,
			Choices = map(SecondsToMSS, range(30, 450, 15)),
			Values  = range(30, 450, 15),
		},
		ScreenEvaluationMenuTimer =
		{
			Default = 60,
			Choices = map(SecondsToMSS, range(15, 450, 15)),
			Values  = range(15, 450, 15),
		},
		ScreenEvaluationSummaryMenuTimer =
		{
			Default = 60,
			Choices = map(SecondsToMSS, range(30, 450, 15)),
			Values  = range(30, 450, 15),
		},
		ScreenNameEntryMenuTimer =
		{
			Default = 60,
			Choices = map(SecondsToMSS, range(15, 450, 15)),
			Values  = range(15, 450, 15),
		},

		-- - - - - - - - - - - - - - - - - - - -
		-- Enable/Disable Certain Screens
		AllowScreenSelectProfile =
		{
			Default = false,
			Choices = { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values  = { true, false }
		},
		AllowScreenSelectColor =
		{
			Default = true,
			Choices = { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values  = { true, false }
		},
		AllowScreenEvalSummary =
		{
			Default = true,
			Choices = { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values  = { true, false }
		},
		AllowScreenGameOver =
		{
			Default = true,
			Choices = { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values  = { true, false }
		},
		AllowScreenNameEntry =
		{
			Default = true,
			Choices = { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values  = { true, false }
		},
		-- - - - - - - - - - - - - - - - - - - -
		-- Casual GameMode Settings
		CasualMaxMeter = {
			Default = 10,
			Choices = range(5, 15, 1),
			Values  = range(5, 15, 1)
		},
		-- - - - - - - - - - - - - - - - - - - -
		-- SM5.1's ImageCache System (used in CasualMode)
		UseImageCache = {
			Default = false,
			Choices =  { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values  = { true, false }
		},
		-- - - - - - - - - - - - - - - - - - - -
		-- nice meme
		-- 0 is off, 1 is visuals only, 2 is visuals and sound.
		nice = {
			Default = 0,
			Choices = { THEME:GetString("ThemePrefs","Off"), THEME:GetString("ThemePrefs","On"), THEME:GetString("ThemePrefs","OnWithSound") },
			Values  = { 0, 1, 2 }
		},
		-- - - - - - - - - - - - - - - - - - - -
		LastActiveEvent =
		{
			Default = "",
		},

		-- - - - - - - - - - - - - - - - - - - -
		EnableGrooveStats = {
			Default = false,
			Choices =  { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values  = { true, false }
		},

		AutoDownloadUnlocks = {
			Default = false,
			Choices =  { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values  = { true, false }
		},

		SeparateUnlocksByPlayer = {
			Default = false,
			Choices =  { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values  = { true, false }
		},
	}
end

SL_CustomPrefs.Validate = function()
	local file = IniFile.ReadFile("Save/ThemePrefs.ini")
	local sl_prefs = SL_CustomPrefs.Get()

	-- If a section for this theme is found in ./Save/ThemePrefs.ini
	local theme_name = THEME:GetCurThemeName()
	if file[theme_name] then
		-- loop through key/value pairs retrieved and do some basic validation
		for k,v in pairs( file[theme_name] ) do
			if sl_prefs[k] then
				-- if we reach here, the setting exists in both the master definition as well
				-- as the user's ThemePrefs.ini so perform some rudimentary validation; check
				-- for both type mismatch and presence in sl_prefs

				local values = sl_prefs[k].Values or sl_prefs[k].Choices

				if type( v ) ~= type( sl_prefs[k].Default )
				or (values and not FindInTable(v, values))
				then
					-- overwrite the user's erroneous setting with the default value
					ThemePrefs.Set(k, sl_prefs[k].Default)
				end

			-- It's possible a setting exists in the ThemePrefs.ini file, but does not exist
			-- in sl_prefs, which should contain the definitions of each ThemePref for this theme.
			-- If that happens, use the ThemePrefs utility to set that key to a value of nil.
			-- keys with nil values won't be written to disk during Save(), so the problematic
			-- setting will effectively be removed.
			else
				ThemePrefs.Set(k, nil)
			end
		end
	end
end

SL_CustomPrefs.Init = function()
	-- InitAll() is defined in _fallback/Scripts/02 ThemePrefsRows.lua
	-- to init both the ThemePrefs and ThemePrefsRows tables.
	ThemePrefs.InitAll( SL_CustomPrefs.Get() )

	-- run our own rudimentary validation
	SL_CustomPrefs.Validate()

	-- finally, call ThemePrefs.Save() so that a [Simply Love] section
	-- can be created in ./Save/ThemePrefs.ini if one was not found
	ThemePrefs.Save()
end

SL_CustomPrefs.Init()
