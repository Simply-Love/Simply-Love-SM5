local SL_CustomPrefs =
{
	AllowFailingOutOfSet =
	{
		Default = true,
		Choices = { "Yes", "No" },
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
		Choices = { "Hide", "Show" },
		Values 	= { true, false }
	},
	MusicWheelStyle =
	{
		Default = "ITG",
		Choices = { "ITG", "IIDX" }
	},
	AllowDanceSolo =
	{
		Default = false,
		Choices = { "Yes", "No" },
		Values 	= { true, false }
	},
	DefaultGameMode =
	{
		Default = "Competitive",
		Choices = {
			THEME:GetString("ScreenSelectPlayMode", "Casual"),
			THEME:GetString("ScreenSelectPlayMode", "Competitive"),
			THEME:GetString("ScreenSelectPlayMode", "ECFA"),
			THEME:GetString("ScreenSelectPlayMode", "StomperZ"),
		},
		Values 	= { "Casual", "Competitive", "ECFA", "StomperZ" }
	},
	TimingWindowAdd = {
		Default = 0,
		Choices = { 0, 0.0015 },
		Values = { 0, 0.0015 }
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
	ShowGradesInMusicWheel =
	{
		Default = false,
		Choices = { "Show", "Hide "},
		Values = { true, false }
	},
	VisualTheme =
	{
		Default = "Hearts",
		Choices = { "Hearts", "Arrows" },
	},
	RainbowMode = {
		Default = false,
		Choices = { "On", "Off" },
		Values 	= { true , false }
	},
	-- - - - - - - - - - - - - - - - - - - -
	-- SimplyLoveColor saves the theme color for the next time
	-- the StepMania application is started.
	SimplyLoveColor =
	{
		-- a nice pinkish-purple, by default
		Default = 3,
		Choices = { 1,2,3,4,5,6,7,8,9,10,11,12 },
		Values = { 1,2,3,4,5,6,7,8,9,10,11,12 }
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

	-- - - - - - - - - - - - - - - - - - - -
	-- Enable/Disable Certain Screens
	AllowScreenSelectProfile =
	{
		Default = false,
		Choices = { "Yes", "No" },
		Values 	= { true, false }
	},
	AllowScreenSelectColor =
	{
		Default = true,
		Choices = { "Yes", "No" },
		Values 	= { true, false }
	},
	AllowScreenEvalSummary =
	{
		Default = true,
		Choices = { "Yes", "No" },
		Values 	= { true, false }
	},
	AllowScreenGameOver =
	{
		Default = true,
		Choices = { "Yes", "No" },
		Values 	= { true, false }
	},
	AllowScreenNameEntry =
	{
		Default = true,
		Choices = { "Yes", "No" },
		Values 	= { true, false }
	},
}

-- We need to InitAll() now so that ./Scripts/SL_Init.lua can use
-- this theme's ThemePrefs shortly after.
ThemePrefs.InitAll(SL_CustomPrefs)

-- For more information on how this works, read:
-- ./StepMania 5/Docs/ThemerDocs/ThemePrefs.txt
-- ./StepMania 5/Docs/ThemerDocs/ThemePrefsRows.txt

local file = IniFile.ReadFile("Save/ThemePrefs.ini")

-- If no [Simply Love] ThemePrefs section is found...
if not file["Simply Love"] then

	-- ...make one by calling Save()
	ThemePrefs.Save()

else

	for k,v in pairs( file["Simply Love"] ) do

		-- it's possible a setting exists in the ThemePrefs.ini file
		-- but does not exist here, where we define the ThemePrefs for this theme!
		-- Check to ensure that the master defintion returns something for
		-- each key from ThemePrefs.ini
		if SL_CustomPrefs[k] then

			-- if we reach here, the setting exists in both the master definition
			-- as well as the user's ThemePrefs.ini; check for type mismatch now
			if type( v ) ~= type( SL_CustomPrefs[k].Default ) then

				-- in the event of a type mismatch, overwrite the user's erroneous setting with the default value
				ThemePrefs.Set(k, SL_CustomPrefs[k].Default)
			end
		end
	end
end