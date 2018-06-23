local OptionRows = {
	{
		name = "Charts",
		helptext = THEME:GetString("ScreenSelectMusicCasual", "SelectDifficulty"),
		choices = {},
		values = {},
		OnSave=function(self, pn, choice, choices, values)
			GAMESTATE:SetCurrentSteps(pn, choice)
		end,
	},
	{
		Name = "Speed",
		helptext = THEME:GetString("ScreenSelectMusicCasual", "SelectSpeedMod"),
		choices = {
			THEME:GetString("ScreenSelectMusicCasual", "Normal"),
			THEME:GetString("ScreenSelectMusicCasual", "MoreSpace"),
			THEME:GetString("ScreenSelectMusicCasual", "LessSpace"),
		},
		values = {225, 350, 150},
		OnSave=function(self, pn, choice, choices, values)
			local index = FindInTable(choice, choices)
			local player_options = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
			player_options:CMod(values[index])
		end,
	},
}

-- add Exit row last
OptionRows[#OptionRows + 1] = {
	Name = "Exit",
	helptext = "",
	choices = {},
	values = {},
}

return OptionRows