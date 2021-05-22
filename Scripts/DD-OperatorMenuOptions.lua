OperatorMenuOptionRows = {}

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

OperatorMenuOptionRows.LongAndMarathonTime = function( str )
	local choices = {
		Long={Choices=SecondsToMMSS_range(150, 300, 15), Values=range(150, 300, 15)},
		Marathon={Choices=SecondsToMMSS_range(300, 600, 15), Values=range(300, 600, 15)}
	}

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
						if self.Choices[i]:match("Digital Dance")	then
							THEME:SetTheme( self.Choices[i] )
							return
						end

						-- if not, attempt a more roundabout check by peeking into the new theme's ThemeInfo.ini
						if FILEMAN:DoesFileExist("/Themes/"..self.Choices[i].."/ThemeInfo.ini") then
							local info = IniFile.ReadFile("/Themes/"..self.Choices[i].."/ThemeInfo.ini")
							if info and info.ThemeInfo and info.ThemeInfo.DisplayName and info.ThemeInfo.DisplayName:match("Digital Dance") then
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

------------------------------------------------------------
-- Graphics/Sound Options

OperatorMenuOptionRows.VideoRenderer = function()

	-- opengl is a valid VideoRenderer for all platforms right now
	-- so start by assuming it is the only choice.
	-- If there is a method available to Lua to get available renderers
	-- from the engine, I haven't found it yet.
	local choices = { "opengl" }
	local values  = { "opengl" }

	-- Windows also has d3d as a VideoRenderer, and the convention(?)
	-- there is to list both in Preferences.ini, but only use the first
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

OperatorMenuOptionRows.VisualDelaySeconds = function()

	-- visual delay seconds
	local vds = PREFSMAN:GetPreference("VisualDelaySeconds")
	-- visual delay milliseconds, rounded to nearest int
	local vdms = round(vds * 1000)

	-- it's hopefully safe to assume that the player does not have a VisualDelaySeconds value
	-- smaller than -1 or larger than 1, but accommodate if they do by using their value as
	-- the largest or smallest available choice in this OptionRow
	local low  = round(math.min(-1000, vdms))
	local high = round(math.max( 1000, vdms))

	-- _values as a temp table of values * 1000 as an intermediate step, not presented to players
	-- _choices as millisecond integers, used for comparison, not presented to players
	--  choices as millisecond integers with "ms" appended, presented to players
	local _values  = range(low, high)
	local _choices = stringify(_values, "%i")
	local choices  = stringify(_values, "%ims")

	return {
		Name="VisualDelaySeconds",
		Choices=choices,
		LayoutType = "ShowOneInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		LoadSelections = function(self, list, pn)
			local i = FindInTable(("%i"):format(vdms), _choices) or math.ceil(#choices/2)
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i=1, #choices do
				if list[i] then
					PREFSMAN:SetPreference("VisualDelaySeconds", tonumber(_choices[i])/1000)
					break
				end
			end
		end
	}
end

------------------------------------------------------------
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
	local choices = SecondsToMMSS_range(105,900,15)
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
