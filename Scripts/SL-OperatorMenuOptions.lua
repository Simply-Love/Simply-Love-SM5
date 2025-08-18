OperatorMenuOptionRows = {}

-- -----------------------------------------------------------------------
-- System Options

OperatorMenuOptionRows.Theme = function()
	return {
		Name = "Theme",
		Choices = THEME:GetSelectableThemeNames(),
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		LoadSelections = function(self, list, pn)
			local theme = THEME:GetCurThemeName()
			if not theme then return end

			local i = FindInTable(theme, self.Choices) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i=1, #list do
				if list[i] then
					if self.Choices[i] ~= THEME:GetCurThemeName() then
						-- if the user is switching to some other version of SL they have installed
						-- don't bother them with the ResetPreferences prompt; just switch to that theme
						-- try a simple check first
						if self.Choices[i]:match("Simply Love")	then
							THEME:SetTheme( self.Choices[i] )
							return
						end

						-- if not, attempt a more roundabout check by peeking into the new theme's ThemeInfo.ini
						if FILEMAN:DoesFileExist("/Themes/"..self.Choices[i].."/ThemeInfo.ini") then
							local info = IniFile.ReadFile("/Themes/"..self.Choices[i].."/ThemeInfo.ini")
							if info and info.ThemeInfo and info.ThemeInfo.DisplayName and info.ThemeInfo.DisplayName:match("Simply Love") then
								THEME:SetTheme( self.Choices[i] )
								return
							end
						end

						-- if not, we'll assume the new theme is different enough to warrant prompting the user
						SL.NextTheme = self.Choices[i]
						SCREENMAN:GetTopScreen():SetNextScreenName("ScreenPromptToResetPreferencesToStock")
					end
				end
			end
		end,
	}
end

OperatorMenuOptionRows.EditorNoteskin = function()
	local skins = NOTESKIN:GetNoteSkinNames()
	return {
		Name = "EditorNoteSkin",
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

-- -----------------------------------------------------------------------
-- Advanced Options


OperatorMenuOptionRows.DefaultFailType = function()
	local failTypes = { "Immediate", "ImmediateContinue", "Off" }
	return {
		Name = "DefaultFailType",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = failTypes,
		LoadSelections = function(self, list, pn)
			local failType = GetDefaultFailType()
			if not failType then return end
			local i = FindInTable(ToEnumShortString(failType), failTypes) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i = 1, #failTypes do
				if list[i] then
					local default_mods = PREFSMAN:GetPreference("DefaultModifiers") or "failimmediate"
					local selected_fail = failTypes[i]
					local default_fail = "" -- An empty string means Immediate fail
					local new_fail = "failimmediate"
					local fail_strings = {}
				
					for mod in string.gmatch(default_mods, "%w+") do
						if mod:lower():find("fail") then
							-- we found something matches "fail", so set our default_fail variable
							-- if we don't find anything that means the fail type is Immediate
							default_fail = mod
							break;
						end
					end

					-- -------------------------------------------------------------------
					-- these mappings just recreate the if/else chain in PlayerOptions.cpp
					fail_strings.failimmediate         = "Immediate"
					fail_strings.failimmediatecontinue = "ImmediateContinue"
					fail_strings.failoff               = "Off"
					fail_strings.failatend             = "EndOfSong"
					-- Map the selected fail type to the failtype string for DefaultModifiers
					for k, v in pairs(fail_strings) do
						if selected_fail == v then
							new_fail = k
							break
						end
					end

					-- If default_fail is empty, then we need to append the new fail type to the front
					-- of the DefaultModifiers string.  Otherwise, we need to replace the old fail type
					-- with the new fail type.
					if default_fail == "" and (new_fail ~= "failimmediate") then
						-- if default_mods is empty we cant have the comma
						if default_mods == "" then
							PREFSMAN:SetPreference("DefaultModifiers", new_fail)
						else
							PREFSMAN:SetPreference("DefaultModifiers", new_fail .. "," .. default_mods)
						end
					else
						default_mods = string.gsub(default_mods, default_fail, new_fail)
						PREFSMAN:SetPreference("DefaultModifiers", default_mods)	
					end
					break
				end
			end
		end,
	}
end

OperatorMenuOptionRows.LongAndMarathonTime = function( str )
	-- define a range of reasonable choices first
	-- 150 seconds is 2.5 minutes
	-- 300 seconds is 5   minutes
	-- 600 seconds is 10  minutes
	local choices = {
		Long=    {Choices=map(SecondsToMSS, range(150, 300, 15)), Values=range(150, 300, 15)},
		Marathon={Choices=map(SecondsToMSS, range(300, 600, 15)), Values=range(300, 600, 15)}
	}

	-- 999999 seconds ≅ 11 days, 13 hours
	-- it's an arbitrarily large numerical value to stand-in for "no song should count as multiple rounds"
	-- it will be presented to the user as the last choice in the OptionRows as a localized "Off"
	choices.Long.Choices[#choices.Long.Choices+1] = THEME:GetString("ThemePrefs", "Off")
	choices.Long.Values[#choices.Long.Values+1] = 999999
	choices.Marathon.Choices[#choices.Marathon.Choices+1] = THEME:GetString("ThemePrefs", "Off")
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

OperatorMenuOptionRows.MusicWheelSpeed = function()

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

------------------------------------------------------------
-- Graphics/Sound Options

OperatorMenuOptionRows.VideoRenderer = function()

	-- opengl is a valid VideoRenderer for all platforms right now
	-- so start by assuming it is the only choice.
	-- If there is a method available to Lua to get available renderers
	-- from the engine, I haven't found it yet.
	local choices = { "opengl" }
	local values  = { "opengl" }

	-- Windows also has d3d as a VideoRenderer on ITGm.
	-- The convention(?) there is to list both available
	-- backends in Preferences.ini, but only use the first
	local architecture = HOOKS:GetArchName():lower()
	if architecture:match("windows") then
		table.insert(choices, "d3d")
		values = { "opengl,d3d", "d3d,opengl" }
	end

	return {
		Name = "VideoRenderer",
		Choices = choices,
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		LoadSelections = function(self, list, pn)
			local pref = PREFSMAN:GetPreference("VideoRenderers")

			-- Multiple comma-delimited VideoRenderers may be listed, but
			-- we only want the first because that's the one actually in use.
			-- Split the string on commas, get the first match found, and
			-- immediately break from the loop.
			for renderer in pref:gmatch("(%w+),?") do
				pref = renderer
				break
			end

			if not pref then return end

			local i = FindInTable(pref, self.Choices) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i=1, #list do
				if list[i] then
					PREFSMAN:SetPreference("VideoRenderers", values[i])
					break
				end
			end
		end,
	}
end

function offsetMS(pref, low, high)
	local val = PREFSMAN:GetPreference(pref)
	local ms = round(val * 1000)	-- convert seconds to milliseconds

	-- If the player has a value set outside of the specified range
	-- accommodate by extending the range.
	low = math.min(low, ms)
	high = math.max(high, ms)

	-- _values as a temp table of values * 1000 as an intermediate step, not presented to players
	--  choices as millisecond integers with "ms" appended, presented to players
	local _values  = range(low, high)
	local choices  = stringify(_values, "%ims")

	return {
		Name=pref,
		Choices=choices,
		LayoutType = "ShowOneInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		LoadSelections = function(self, list, pn)
			local i = ms - low + 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i=1, #choices do
				if list[i] then
					PREFSMAN:SetPreference(pref, (low + i - 1) / 1000)
					break
				end
			end
		end
	}
end

OperatorMenuOptionRows.GlobalOffsetSeconds = function()
	-- up to 1s of audio delay (via HDMI), because some TVs are really slow
	return offsetMS("GlobalOffsetSeconds", -1000, 1000)
end

OperatorMenuOptionRows.VisualDelaySeconds = function()
	-- up to 1s of visual delay, because some TVs are really slow
	return offsetMS("VisualDelaySeconds", -1000, 1000)
end

-- -----------------------------------------------------------------------
-- USB profiles

-- the engine doesn't seem to have a conf definition
-- for the MemoryCards preference, so make one here
OperatorMenuOptionRows.MemoryCards = function()

	local values = {false, true}
	local choices = {THEME:GetString("OptionNames","Off"), THEME:GetString("OptionNames","On")}

	return {
		Name="MemoryCards",
		Choices=choices,
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		LoadSelections = function(self, list, pn)
			local pref = PREFSMAN:GetPreference("MemoryCards") and 2 or 1
			list[pref] = true
		end,
		SaveSelections = function(self, list, pn)
			local pref = (list[2]==true)
			PREFSMAN:SetPreference("MemoryCards", pref)
		end,
	}
end


OperatorMenuOptionRows.CustomSongsMaxSeconds = function()
	-- first, define a reasonable range of 1:45 to 15:00
	local choices = map(SecondsToMSS, range(105,900,15))
	local values  = range(105,900,15)
	-- top it off by including 2 hours as a choice
	table.insert(choices, "2:00:00")
	table.insert(values, 7200)

	return {
		Name="CustomSongsMaxSeconds",
		Choices=choices,
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		LoadSelections = function(self, list, pn)
			local time = SecondsToMMSS(PREFSMAN:GetPreference("CustomSongsMaxSeconds")):gsub("^0*", "")
			local i = FindInTable(time, choices) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i=1, #choices do
				if list[i] then
					PREFSMAN:SetPreference("CustomSongsMaxSeconds", values[i])
					break
				end
			end
		end,
	}
end

OperatorMenuOptionRows.CustomSongsMaxMegabytes = function()
	-- first, define a reasonable range of integers from [3,9]
	local values = range(3,9)
	local choices = stringify(values, "%d MB")

	-- then, a second range of slightly larger values, more spaced out
	for i, x in ipairs(range(10,30,2.5)) do
		table.insert(values, x)

		if i % 2 == 0 then
			table.insert(choices, ("%.1f MB"):format(x))
		else
			table.insert(choices, ("%d MB"):format(x))
		end
	end

	-- lmao
	table.insert(values, 1000)
	table.insert(choices, "1 GB 😮")

	return {
		Name="CustomSongsMaxMegabytes",
		Choices=choices,
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		LoadSelections = function(self, list, pn)
			local pref = PREFSMAN:GetPreference("CustomSongsMaxMegabytes")
			local i = FindInTable(pref, values) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i=1, #choices do
				if list[i] then
					PREFSMAN:SetPreference("CustomSongsMaxMegabytes", values[i])
					break
				end
			end
		end,
	}
end

OperatorMenuOptionRows.CustomSongsLoadTimeout = function()
	-- first, define a reasonable range of integers from [3,10]
	local choices = range(3,10)
	table.insert(choices, 60)

	-- accommodate custom values rather than steamrolling over them
	local pref = PREFSMAN:GetPreference("CustomSongsLoadTimeout")
	if not FindInTable(pref, choices) then table.insert(choices, pref) end

	return {
		Name="CustomSongsLoadTimeout",
		Choices=choices,
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		LoadSelections = function(self, list, pn)
			local i = FindInTable(pref, choices) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i=1, #choices do
				if list[i] then
					PREFSMAN:SetPreference("CustomSongsLoadTimeout", choices[i])
					break
				end
			end
		end,
	}
end
