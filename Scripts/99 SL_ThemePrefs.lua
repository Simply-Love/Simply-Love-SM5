local SL_ThemePrefs =
{
	SimplyLoveColor =
	{
		-- a nice pinkish-purple, by default
		Default = 3,
		Choices = { 1,2,3,4,5,6,7,8,9,10,11,12 }
	},
	AllowFailingOutOfSet =
	{
		Default = false,
		Choices = { THEME:GetString('OptionTitles', 'Yes'), THEME:GetString('OptionTitles',  'No') },
		Values 	= { true, false }
	},
	NumberOfContinuesAllowed =
	{
		Default = 0,
		Choices = { 0,1,2,3,4,5,6,7,8,9 },
		Values = { 0,1,2,3,4,5,6,7,8,9 }
	}
}

ThemePrefs.InitAll(SL_ThemePrefs)