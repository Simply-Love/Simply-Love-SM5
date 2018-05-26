function OptionRowEditorNoteskin()
	local skins = NOTESKIN:GetNoteSkinNames()
	return {
		Name = "Editor Noteskin",
		LayoutType = "ShowOneInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = skins,
		LoadSelections = function(self, list, pn)
			local skin = PREFSMAN:GetPreference("EditorNoteSkinP1") or
				PREFSMAN:GetPreference("EditorNoteSkinP2") or
				THEME:GetMetric("Common", "DefaultNoteSkinName")
			if not skin then return end

			local i = FindInTable(skin, skins) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i = 1, #skins do
				if list[i] then
					PREFSMAN:SetPreference("EditorNoteSkinP1", skins[i])
					PREFSMAN:SetPreference("EditorNoteSkinP2", skins[i])
					break
				end
			end
		end,
	}
end

function OptionRowLongAndMarathonTime( str )
	local choices = {
		Long={Choices=SecondsToMMSS_range(150, 300, 15), Values=range(150, 300, 15)},
		Marathon={Choices=SecondsToMMSS_range(300, 600, 15), Values=range(300, 600, 15)}
	}

	choices.Long.Choices[#choices.Long.Choices+1] = "Off"
	choices.Long.Values[#choices.Long.Values+1] = 999999
	choices.Marathon.Choices[#choices.Marathon.Choices+1] = "Off"
	choices.Marathon.Values[#choices.Marathon.Values+1] = 999999

	return {
		Name = str .. " Time",
		LayoutType = "ShowOneInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = choices[str].Choices,
		LoadSelections = function(self, list, pn)
			if PREFSMAN:GetPreference(str.."VerSongSeconds") == 999999 then
				list[#list] = true
			else
				local time = SecondsToMMSS(PREFSMAN:GetPreference(str.."VerSongSeconds")):gsub("^0*", "")
				local i = FindInTable(time, choices[str].Choices) or 1
				list[i] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			for i = 1, #choices[str].Choices do
				if list[i] then
					PREFSMAN:SetPreference(str.."VerSongSeconds", choices[str].Values[i])
					break
				end
			end
		end,
	}
end

function OptionRowMusicWheelSpeed()

	local choices = { "Slow", "Normal", "Fast", "Faster", "Ridiculous", "Ludicrous", "Plaid" }
	local values = { 5, 10, 15, 25, 30, 45, 100 }
	local localized_choices = {}

	for i=1, #choices do
		localized_choices[i] = THEME:GetString("MusicWheelSpeed", choices[i] )
	end

	-- it's possible the user has manually edited Preferences.ini and set an arbitrary value
	-- try to accommodate, rather than obliterating that custom setting
	local user_setting = PREFSMAN:GetPreference("MusicWheelSwitchSpeed") or 15
	if not FindInTable(user_setting, values) then
		values[#values+1] = user_setting
		choices[ #choices+1 ] = THEME:GetString("MusicWheelSpeed", "Custom")
	end

	return {
		Name = "MusicWheelSpeed",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = localized_choices,
		LoadSelections = function(self, list, pn)
			local i = FindInTable(user_setting, values) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i = 1, #values do
				if list[i] then
					PREFSMAN:SetPreference("MusicWheelSwitchSpeed", values[i] )
					break
				end
			end
		end
	}
end