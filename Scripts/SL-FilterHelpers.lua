------------------------------------------------------------
-- Helper Functions for PlayerOptions
------------------------------------------------------------

local function GetModsAndPlayerOptions(player)
	local mods = SL[ToEnumShortString(player)].ActiveModifiers
	local topscreen = SCREENMAN:GetTopScreen():GetName()
	local modslevel = topscreen  == "ScreenEditOptions" and "ModsLevel_Stage" or "ModsLevel_Preferred"
	local playeroptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions(modslevel)
	return mods, playeroptions
end

------------------------------------------------------------
-- when to use Choices() vs. Values()
--
-- Each OptionRow needs stringified choices to present to the player.  Sometimes using hardcoded strings
-- is okay. For example, SpeedModType choices (x, C, M) are the same in English as in French.
--
-- Other times, we need to be able to localize the choices presented to the player but also
-- maintain an internal value that code within the theme can rely on regardless of language.
--
-- For each of the subtables in Overrides, you must specify 'Choices' and/or 'Values' depending on your
-- needs. Each can be either a table of strings or a function that returns a table of strings.
-- Using a function can be helpful when the OptionRow needs to present different options depending
-- on certain conditions.
--
-- If you specify only 'Choices', the engine presents the strings exactly as-is and also uses those
-- same strings internally.
--
-- If you specify only 'Values', the engine will use those raw strings internally but localize them
-- using the corresponding display strings in en.ini (or es.ini, fr.ini, etc.) for the user.
--
-- If you specify both, then the strings in 'Choices' are presented as-is,
-- but the strings in 'Values' are what the theme stores into the ActiveModifiers table.

------------------------------------------------------------

-- Define SL's custom OptionRows that appear in ScreenPlayerOptions as subtables within Overrides.
-- As an OptionRow, each subtable is expected to have specific key/value pairs:
--
-- ExportOnChange (boolean)
-- 	false if unspecified; if true, calls SaveSelections() whenever the current choice changes
-- LayoutType (string)
-- 	"ShowAllInRow" if unspecified; you can set it to "ShowOneInRow" if needed
-- OneChoiceForAllPlayers (boolean)
-- 	false if unspecified
-- SelectType (string)
-- 	"SelectOne" if unspecified; you can set it to "SelectMultiple" if needed
-- LoadSelections (function)
-- 	normally (in other themes) called when the PlayerOption screen initializes
-- 	read the notes surrounding ApplyMods() for further discussion of additional work SL does
-- SaveSelections (function)
-- 	this is where you should do whatever work is needed to ensure that the player's choice
-- 	persists beyond the PlayerOptions screen; normally called around the time of ScreenPlayerOption's
-- 	OffCommand; can also be called because ExportOnChange=true


-- It's not necessary to define each possible key for each OptionRow.  Anything you don't specify
-- will use fallback values in OptionRowDefault (defined later, below).


--Filters is a table of tables containing information for setting up each row. 
--First item is the name of the filter as seen in SL.Global.ActiveModifiers (SL_Init.lua)
--Second item is the minimum number in the range of possible choices
--Third item is the maximum number in the range of possible choices
--Fourth item is the amount to increment by
local filters = { 
	{"MaxJumps",5,1000,5},
	{"MinJumps",5,1000,5},
	{"MinSteps",100,100000,100},
	{"MaxSteps",100,100000,100},
	{"MinDifficulty",1,30,1},
	{"MaxDifficulty",1,30,1},
}
	
local Overrides = {}

Overrides["TagsFilter"] = {
	SelectType = "SelectMultiple",
	Values = GetGroups("Tag"),
	ExportOnChange = true,
	SaveSelections = function(self, list, pn)
		local t = {}
		for k,v in pairs(GetGroups("Tag")) do
			t[v] = list[k]
		end
		SL.Global.ActiveFilters["HideTags"] = t
	end,
	LoadSelections = function(self, list, pn)
		if SL.Global.ActiveFilters["HideTags"] then 
			for k,v in pairs(GetGroups("Tag")) do
				list[k] = SL.Global.ActiveFilters["HideTags"][v] or false
			end
		else
			for k,v in pairs(list) do
				list[k] = false
			end
		end
	end,
}
	
Overrides["PassFailFilter"] = {
	SelectType = "SelectMultiple",
	Values = { "Passed", "Failed", "Unplayed" },
	ExportOnChange = true,
	SaveSelections = function(self, list, pn)
		SL.Global.ActiveFilters["HidePassed"] = list[1]
		SL.Global.ActiveFilters["HideFailed"] = list[2]
		SL.Global.ActiveFilters["HideUnplayed"] = list[3]
	end,
	LoadSelections = function(self, list, pn)
		list[1] = SL.Global.ActiveFilters["HidePassed"] or false
		list[2] = SL.Global.ActiveFilters["HideFailed"] or false
		list[3] = SL.Global.ActiveFilters["HideUnplayed"] or false
		return list
	end,
}
			
for item in ivalues(filters) do
	Overrides[item[1].."Filter"] = {
		Choices = function()
			local minNum	= item[2]
			local maxNum 	= item[3]
			local step 		= item[4]
			local t = stringify( range(minNum, maxNum, step))
			table.insert(t,1,"Off")
			return t
		end,
		ExportOnChange = true,
		LayoutType = "ShowOneInRow",
		SaveSelections = function(self, list, pn)
			for i=1,#self.Choices do
				if list[i] then
					SL.Global.ActiveFilters[item[1]] = self.Choices[i]
				end
			end
		end,
		LoadSelections = function(self, list, pn)
			local filter = SL.Global.ActiveFilters[item[1]]
			local i = FindInTable(filter, self.Choices) or 1
			list[i] = true
			return list
		end,
	}
end


------------------------------------------------------------
-- Generic OptionRow Definition
------------------------------------------------------------
local OptionRowDefault = {
	-- the __index metatable will serve to define a completely generic OptionRow
	__index = {
		initialize = function(self, name)

			self.Name = name

			if Overrides[name].Values then
				if Overrides[name].Choices then
					self.Choices = type(Overrides[name].Choices)=="function" and Overrides[name].Choices() or Overrides[name].Choices
				else
					self.Choices = {}
					for i, v in ipairs( (type(Overrides[name].Values)=="function" and Overrides[name].Values() or Overrides[name].Values) ) do
						if THEME:HasString("SLFilterOptions", v) then
							self.Choices[i] = THEME:GetString("SLFilterOptions", v)
						else
							self.Choices[i] = v
						end
					end
				end
				self.Values = type(Overrides[name].Values)=="function" and Overrides[name].Values() or Overrides[name].Values
			else
				self.Choices = type(Overrides[name].Choices)=="function" and Overrides[name].Choices() or Overrides[name].Choices
			end

			-- define fallback values to use here if an override isn't specified
			self.LayoutType = Overrides[name].LayoutType or "ShowAllInRow"
			self.SelectType = Overrides[name].SelectType or "SelectOne"
			self.OneChoiceForAllPlayers = Overrides[name].OneChoiceForAllPlayers or false
			self.ExportOnChange = Overrides[name].ExportOnChange or false


			if self.SelectType == "SelectOne" then

				self.LoadSelections = Overrides[name].LoadSelections or function(subself, list, pn)
					local mods, playeroptions = GetModsAndPlayerOptions(pn)
					local choice = mods[name] or (playeroptions[name] ~= nil and playeroptions[name](playeroptions)) or self.Choices[1]
					local i = FindInTable(choice, (self.Values or self.Choices)) or 1
					list[i] = true
					return list
				end
				self.SaveSelections = Overrides[name].SaveSelections or function(subself, list, pn)
					local mods = SL[ToEnumShortString(pn)].ActiveModifiers
					local vals = self.Values or self.Choices
					for i, val in ipairs(vals) do
						if list[i] then mods[name] = val; break end
					end
				end

			else
				-- "SelectMultiple" typically means a collection of theme-defined flags in a single OptionRow
				-- most of these behave the same and can fall back on this generic definition; a notable exception is "Hide"
				self.LoadSelections = Overrides[name].LoadSelections or function(subself, list, pn)
					local mods = SL[ToEnumShortString(pn)].ActiveModifiers
					local vals = self.Values or self.Choices
					for i, mod in ipairs(vals) do
						list[i] = mods[mod] or false
					end
					return list
				end
				self.SaveSelections = Overrides[name].SaveSelections or function(subself, list, pn)
					local mods = SL[ToEnumShortString(pn)].ActiveModifiers
					local vals = self.Values or self.Choices
					for i, mod in ipairs(vals) do
						mods[mod] = list[i]
					end
				end
			end

			return self
		end
	}
}

------------------------------------------------------------
-- Passed a string like "Mini", CustomOptionRow() will return table that represents
-- the themeside attributes of the OptionRow for Mini.
--
-- CustomOptionRow() is mostly used in Metrics.ini under [ScreenPlayerOptions] and siblings
-- to pass OptionRow data (Lua) to the engine (C++) via Metrics (ini).
--
-- Thre are a few other places in the theme where CustomOptionRow() is used to retrieve a list
-- of possible choices for a given OptionRow and then do something based on that list.
-- For example, ./ScreenPlayerOptions overlay/NoteSkinPreviews.lua uses it to get a list of NoteSkins
-- so it can load preview NoteSkin actors into the overlay's ActorFrame ahead of time.

function CustomFilterRow( name )
	-- assign the properties of the generic OptionRowDefault to OptRow
	local OptRow = setmetatable( {}, OptionRowDefault )

	-- now that OptRow has the method available, run its initialize() method
	return OptRow:initialize( name )
end


---------------------------------------------------------------------------
-- Sets each value in SL.Global.ActiveFilters to "OFF" this is called when
-- filters get rid of every single song (leaving none available)
ResetFilters = function()
	for k,v in pairs(SL.Global.ActiveFilters) do
		SL.Global.ActiveFilters[k] = "Off"
	end
	SL.Global.ActiveFilters['HidePassed'] = false
	SL.Global.ActiveFilters['HideFailed'] = false
	SL.Global.ActiveFilters['HideUnplayed'] = false
	SL.Global.ActiveFilters['HideTags'] = nil
end


-- returns a table with numbers replacing booleans to make ValidateChart easier to use
local ConvertFilters = function()
	local converted = {}
	converted["minSteps"] = SL.Global.ActiveFilters["MinSteps"] == "Off" and 0 or tonumber(SL.Global.ActiveFilters["MinSteps"])
	converted["maxSteps"] = SL.Global.ActiveFilters["MaxSteps"] == "Off" and 1000000 or tonumber(SL.Global.ActiveFilters["MaxSteps"])
	converted["minDifficulty"] = SL.Global.ActiveFilters["MinDifficulty"] == "Off" and 0 or tonumber(SL.Global.ActiveFilters["MinDifficulty"])
	converted["maxDifficulty"] = SL.Global.ActiveFilters["MaxDifficulty"] == "Off" and 1000000 or tonumber(SL.Global.ActiveFilters["MaxDifficulty"])
	converted["minJumps"] = SL.Global.ActiveFilters["MinJumps"] == "Off" and 0 or tonumber(SL.Global.ActiveFilters["MinJumps"])
	converted["maxJumps"] = SL.Global.ActiveFilters["MaxJumps"] == "Off" and 1000000 or tonumber(SL.Global.ActiveFilters["MaxJumps"])
	return converted
end

-- requires a song and chart as input parameters. returns true if the chart passes all filters and false otherwise
ValidateChart = function(song, chart, player, inputFilters)
	local mpn = GAMESTATE:GetMasterPlayerNumber()
	local filters = inputFilters or ConvertFilters()
	local chartMeter = chart:GetMeter()
	local chartSteps = chart:GetRadarValues(mpn):GetValue('RadarCategory_TapsAndHolds') --TODO this only works for the master player.
	local chartJumps = chart:GetRadarValues(mpn):GetValue('RadarCategory_Jumps') --TODO this only works for the master player.
	local highScore = GetGrade(song, chart)
	--Check pass/fail stuff
	if highScore then
		if SL.Global.ActiveFilters["HidePassed"] and highScore < 17 then return false end
		if SL.Global.ActiveFilters["HideFailed"] and highScore == 17 then return false end
	end
	if SL.Global.ActiveFilters["HideUnplayed"] and highScore == nil then return false end
	--Check difficulty, steps, and jumps
	if chartMeter > filters["maxDifficulty"] or chartMeter < filters["minDifficulty"] then return false end
	if chartSteps > filters["maxSteps"] or chartSteps < filters["minSteps"] then return false end
	if chartJumps > filters["maxJumps"] or chartJumps < filters["minJumps"] then return false end
	--Check tags
	if SL.Global.ActiveFilters["HideTags"] then
		for k,v in pairs(GetGroups("Tag")) do
			if SL.Global.ActiveFilters["HideTags"][v] == true then
				if GetTags(song, v) then return false end
				if v == "BPM Changes" then if song:HasSignificantBPMChangesOrStops() then return false end end
				if v == "No Tags Set" then if not GetTags(song) and not song:HasSignificantBPMChangesOrStops() then return false end end
			end
		end
	end
	--if we make it to the bottom then the song is good to go.
	return true
end

--Returns the grade for a given song and chart or nil if there isn't a high score.
GetGrade = function(song, chart)
	local grade = PROFILEMAN:GetProfile(0):GetHighScoreList(song,chart):GetHighScores()[1] --TODO this only grabs scores for player one
	if grade then
		local converted_grade = Grade:Reverse()[grade:GetGrade()]
		if converted_grade > 17 then converted_grade = 17 end
		return converted_grade
	end
	return nil
end

-- returns a table of just the active filters
GetActiveFilters = function()
	local filterExists = false
	local t = {}
	for k,v in pairs(SL.Global.ActiveFilters) do
		-- these are either "Off" or a number (type=string)
		if type(v) == 'string' then
			if v ~= "Off" then t[k] = v filterExists = true end
		elseif type(v) == 'boolean' then
			if v == true then t[k] = v filterExists = true end
		end
	end
	if SL.Global.ActiveFilters["HideTags"] then
		t["HideTags"] = {}
		for k,v in pairs(GetGroups("Tag")) do
			if SL.Global.ActiveFilters["HideTags"][v] == true then t["HideTags"][#t["HideTags"]+1] = v filterExists = true end
		end
	end
	if filterExists then return t
	else return nil end
end
------------------------------------------------------
--Formats a string with all the active filters
GetActiveFiltersString = function()
	local activeFilters = GetActiveFilters()
	if not activeFilters then return "No Filters Set" end
	local toPrint = "FILTERS:\n"
	local numberFilters = {'Steps','Jumps','Difficulty'}
	for filterType in ivalues(numberFilters) do
		toPrint = toPrint..filterType.." - "
		local foundFilter = false
		if activeFilters['Min'..filterType] then toPrint = toPrint.."Min:"..activeFilters['Min'..filterType].." " foundFilter = true end
		if activeFilters['Max'..filterType] then toPrint = toPrint.."Max:"..activeFilters['Max'..filterType] foundFilter = true end
		if not foundFilter then toPrint = toPrint.."Off\n"
		else toPrint = toPrint.."\n" end
	end

	if SL.Global.ActiveFilters["HidePassed"] or SL.Global.ActiveFilters["HideFailed"] or SL.Global.ActiveFilters["HideUnplayed"] then
		toPrint = toPrint.."-Hide by Pass Status-\n"
		if activeFilters["HidePassed"] then toPrint = toPrint.."Passed Songs\n" end
		if activeFilters["HideFailed"] then toPrint = toPrint.."Failed Songs\n" end
		if activeFilters["HideUnplayed"] then toPrint = toPrint.."Unplayed Songs\n" end
	else toPrint = toPrint.."Hide by Pass Status - Off\n" end	
	if #activeFilters["HideTags"] > 0 then
		toPrint = toPrint.."-----Hide Tags-----\n"
		for tagName in ivalues(activeFilters["HideTags"]) do
			toPrint = toPrint..tagName.."\n"
		end
	else toPrint = toPrint.."Hide Tags - Off\n" end
	return toPrint
end

-------------------------------------------------------------------------------------
--prunes a list of songs using SL.Global.ActiveFilters
PruneSongList= function(song_list)

	local filters = ConvertFilters()
	local songs = {}
	
	for song in ivalues(song_list) do
		-- this should be guaranteed by this point, but better safe than segfault
		if song:HasStepsType(GetStepsType()) then
			for chart in ivalues(song:GetStepsByStepsType(GetStepsType())) do
				if ValidateChart(song, chart) then songs[#songs+1] = song break end
			end
		end
	end
	return songs
end