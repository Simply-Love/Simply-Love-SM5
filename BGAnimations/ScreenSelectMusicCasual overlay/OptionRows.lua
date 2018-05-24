local OptionRows = {
	{
		name = "Charts",
		helptext = "SELECT YOUR DIFFICULTY",
		choices = {},
		values = {},
		OnSave=function(self, pn, choice, choices, values)
			GAMESTATE:SetCurrentSteps(pn, choice)
		end,
	},
	{
		Name = "Speed",
		helptext = "SELECT YOUR ARROW SPACING",
		choices = {"Normal", "More Space", "Less Space"},
		values = {1.5, 2, 1},
		OnSave=function(self, pn, choice, choices, values)
			local index = FindInTable(choice, choices)
			local player_options = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
			player_options:XMod(values[index])
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