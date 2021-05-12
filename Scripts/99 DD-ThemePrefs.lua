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
	return {
		AllowFailingOutOfSet =
		{
			Default = true,
			Choices = { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values 	= { true, false }
		},
		NumberOfContinuesAllowed =
		{
			Default = 0,
			Choices = { 0,1,2,3,4,5,6,7,8,9 },
			Values = { 0,1,2,3,4,5,6,7,8,9 }
		},


		HideStockNoteSkins =
		{
			Default = false,
			Choices = { THEME:GetString("ThemePrefs", "Show"), THEME:GetString("ThemePrefs", "Hide") },
			Values 	= { false, true }
		},
		MusicWheelStyle =
		{
			Default = "IIDX",
			Choices = { "ITG", "IIDX" }
		},
		AllowDanceSolo =
		{
			Default = false,
			Choices = { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values 	= { true, false }
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
			Values 	= { "none", "single", "versus", "double" }
		},
		-- - - - - - - - - - - - - - - - - - - -
		-- MenuTimer values for various screens
		ScreenSelectMusicMenuTimer =
		{
			Default = 300,
			Choices = SecondsToMMSS_range(60, 450, 15),
			Values = range(60, 450, 15),
		},
		ScreenPlayerOptionsMenuTimer =
		{
			Default = 90,
			Choices = SecondsToMMSS_range(30, 450, 15),
			Values = range(30, 450, 15),
		},
		ScreenEvaluationMenuTimer =
		{
			Default = 60,
			Choices = SecondsToMMSS_range(15, 450, 15),
			Values = range(15, 450, 15),
		},
		ScreenEvaluationSummaryMenuTimer =
		{
			Default = 60,
			Choices = SecondsToMMSS_range(30, 450, 15),
			Values = range(30, 450, 15),
		},
		ScreenNameEntryMenuTimer =
		{
			Default = 60,
			Choices = SecondsToMMSS_range(15, 450, 15),
			Values = range(15, 450, 15),
		},

		AllowScreenEvalSummary =
		{
			Default = true,
			Choices = { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values 	= { true, false }
		},
		AllowScreenGameOver =
		{
			Default = true,
			Choices = { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values 	= { true, false }
		},
		AllowScreenNameEntry =
		{
			Default = true,
			Choices = { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values 	= { true, false }
		},
		
		-- - - - - - - - - - - - - - - - - - - -
		-- SM5.1's ImageCache System (used in DDMode)
		UseImageCache = {
			Default = false,
			Choices =  { THEME:GetString("ThemePrefs","Yes"), THEME:GetString("ThemePrefs", "No") },
			Values	= { true, false }
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
				-- if we reach here, the setting exists in both the master definition as well as the user's ThemePrefs.ini
				-- so perform some rudimentary validation; check for both type mismatch and presence in sl_prefs
				if type( v ) ~= type( sl_prefs[k].Default )
				or not FindInTable(v, (sl_prefs[k].Values or sl_prefs[k].Choices))
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

	-- finally, call ThemePrefs.Save() so that a [Digital Dance] section
	-- can be created in ./Save/ThemePrefs.ini if one was not found
	ThemePrefs.Save()
end

SL_CustomPrefs.Init()