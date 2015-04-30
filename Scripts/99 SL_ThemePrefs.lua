local SL_CustomPrefs =
{
	AllowFailingOutOfSet =
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
	NumberOfContinuesAllowed =
	{
		Default = 0,
		Choices = { 0,1,2,3,4,5,6,7,8,9 },
		Values = { 0,1,2,3,4,5,6,7,8,9 }
	},
	SimplyLoveColor =
	{
		-- a nice pinkish-purple, by default
		Default = 3,
		Choices = { 1,2,3,4,5,6,7,8,9,10,11,12 },
		Values = { 1,2,3,4,5,6,7,8,9,10,11,12 }
	},
	MusicWheelStyle =
	{
		Default = "ITG",
		Choices = { "ITG", "IIDX" }
	},
}

-- We need to InitAll() now so that ./Scripts/SL_Init.lua can use
-- this theme's ThemePrefs shortly after.
ThemePrefs.InitAll(SL_CustomPrefs)

-- For more information on how this works, read:
-- ./StepMania 5/Docs/ThemerDocs/ThemePrefs.txt
-- ./StepMania 5/Docs/ThemerDocs/ThemePrefsRows.txt