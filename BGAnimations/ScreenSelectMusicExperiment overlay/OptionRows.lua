-- helper functions
local GetDifficulty = function(steps)
	return {THEME:GetString( "CustomDifficulty", steps:GetDifficulty():gsub("Difficulty_", "") ), steps:GetMeter()}
end

-- ------------------------------------------------------
local OptionRows = {
	{
		Name = "GoToOptions",
		HelpText = THEME:GetString("ScreenSelectMusicExperiment", "GoToOptions"),
		Choices = function(self) return { "No", "Yes" } end,
		Values = function(self) return { false, true } end,
		OnLoad = function(actor, pn, choices, values)
			local index = 1
			actor:set_info_set(choices, index)
		end,
		OnSave=function(self, pn, choice, choices, values)
			local index = FindInTable(choice, choices)
			SL.Global.GoToOptions = self:Values()[index]
		end,
	},
}
-- ------------------------------------------------------
-- Option Panes
OptionRows[#OptionRows + 1] = {
	Name = "ChangeDisplay",
		HelpText = THEME:GetString("ScreenSelectMusicExperiment", "ChangeDisplay"),
		Choices = function()
			return {
				"Song Background",
				"BPM Helper",
				"Songs Played Today",
			}
		end,
		Values = function() return {1, 2, 3} end,
		OnLoad=function(actor, pn, choices, values)
			actor:set_info_set(choices, SL.Global['ActivePlayerOptionsPane'..PlayerNumber:Reverse()[pn]]+1)
		end,
		OnSave=function(self, pn, choice, choices, values)
			local index = FindInTable(choice, choices)
			SL.Global['ActivePlayerOptionsPane'..PlayerNumber:Reverse()[pn]] = self:Values()[index] - 1
		end,
}
-- add Exit row last
OptionRows[#OptionRows + 1] = {
	Name = "Exit",
	HelpText = "",
}

return OptionRows