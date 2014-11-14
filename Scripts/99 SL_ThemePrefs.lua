local SL_CustomPrefs =
{
	AllowFailingOutOfSet =
	{
		Default = 0,
		Choices = { "Yes", "No" },
		Values 	= { 1, 0 }
	},
	AllowScreenEvalSummary =
	{
		Default = 1,
		Choices = { "Yes", "No" },
		Values 	= { 1, 0 }
	},
	AllowScreenGameOver =
	{
		Default = 1,
		Choices = { "Yes", "No" },
		Values 	= { 1, 0 }
	},
	AllowScreenNameEntry =
	{
		Default = 1,
		Choices = { "Yes", "No" },
		Values 	= { 1, 0 }
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
		Choices = { 1,2,3,4,5,6,7,8,9,10,11,12 }
	},
}

-- We need to InitAll() now so that ./Scripts/SL_Init.lua can use
-- this theme's ThemePrefs shortly after.
ThemePrefs.InitAll(SL_CustomPrefs)

-- For more information on how this works, read:
-- ./StepMania 5/Docs/ThemerDocs/ThemePrefs.txt
-- ./StepMania 5/Docs/ThemerDocs/ThemePrefsRows.txt


-- If no ThemePrefs section is found, make one.  We don't always want to ForceSave()
-- because this will write using the Default values established above.
local file =  IniFile.ReadFile("Save/ThemePrefs.ini")
if not file["Simply Love"] then
  ThemePrefs.ForceSave()
end

-- Check if old preferences need to be converted to new types
if type(file["Simply Love"]["AllowFailingOutOfSet"]) ~= "number" then
  ThemePrefs.ForceSave()
end