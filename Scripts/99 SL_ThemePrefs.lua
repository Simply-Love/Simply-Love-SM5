local SL_ThemePrefs =
{
	SimplyLoveColor =
	{
		Default = 1,
		Choices = { 1,2,3,4,5,6,7,8,9,10,11,12 }
	},
	AllowFailingOutOfSet =
	{
		Default = "Yes",
		Choices = { THEME:GetString('OptionTitles', 'Yes'), THEME:GetString('OptionTitles',  'No') },
		Values 	= { "Yes", "No" }
	},
	NumberOfContinuesAllowed =
	{
		Default = 0,
		Choices = { 0,1,2,3,4,5 },
		Values = { 0,1,2,3,4,5 }
	}
}

ThemePrefs.InitAll(SL_ThemePrefs)