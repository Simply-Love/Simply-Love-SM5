------------------------------------------------------------
-- set up the SortMenu's choices first, prior to Actor initialization
-- sick_wheel_mt is a metatable with global scope defined in ./Scripts/Consensual-sick_wheel.lua
local sort_wheel = setmetatable({}, sick_wheel_mt)
-- the logic that handles navigating the SortMenu
-- (scrolling through choices, choosing one, canceling)
-- is large enough that I moved it to its own file
local sortmenu_input = LoadActor("SortMenu_InputHandler.lua", sort_wheel)
local testinput_input = LoadActor("TestInput_InputHandler.lua")
local leaderboard_input = LoadActor("Leaderboard_InputHandler.lua")
-- "MT" is my personal means of denoting that this thing (the file, the variable, whatever)
-- has something to do with a Lua metatable.
--
-- metatables in Lua are a useful construct when designing reusable components.
-- For example, I'm using them here to define a generic definition of any choice within the SortMenu.
-- The file WheelItemMT.lua contains a metatable definition; the "MT" is my own personal convention
-- in Simply Love.
--
-- Unfortunately, many online tutorials and guides on Lua metatables are
-- *incredibly* obtuse and unhelpful for non-computer-science people (like me).
-- https://lua.org/pil/13.html is just frustratingly scant.
--
-- http://phrogz.net/lua/LearningLua_ValuesAndMetatables.html is less bad than most.
-- I do get immediately lost in the criss-crossing diagrams, and I'll continue to
-- argue that naming things foo, bar, and baz "because we want to teach an idea, not a skill"
-- results in programming tutorials so abstract they don't seem applicable to this world,
-- but its prose was approachable enough for wastes-of-space like me, so I guess I'll
-- recommend it until I find a more helpful one.
--                                      -quietly
local wheel_item_mt = LoadActor("WheelItemMT.lua")
local sortmenu = { w=210, h=160 }

local hasSong = GAMESTATE:GetCurrentSong() and true or false

local FilterTable = function(arr, func)
	local new_index = 1
	local size_orig = #arr
	for v in ivalues(arr) do
		if func(v) then
			arr[new_index] = v
			new_index = new_index + 1
		end
	end
	for i = new_index, size_orig do arr[i] = nil end
end

local GetBpmTier = function(bpm)
	return math.floor((bpm + 0.5) / 10) * 10
end

local SongSearchSettings = {
	Question="'pack/song' format will search for songs in specific packs\n'[###]' format will search for BPMs/Difficulties",
	InitialAnswer="",
	MaxInputLength=30,
	OnOK=function(input)
		if #input == 0 then return end

		-- Lowercase the input text for comparison
		local searchText = input:lower()

		-- First extract out the "numbers".
		-- Anything <= 35 is considered a difficulty, otherwise it's a bpm.
		local difficulty = nil
		local bpmTier = nil

		for match in searchText:gmatch("%[(%d+)]") do
			local value = tonumber(match)
			if value <= 35 then
				difficulty = value
			else
				-- Determine the "tier".
				bpmTier = GetBpmTier(value)
			end
		end

		-- Remove the parsed atoms, and then strip leading/trailing whitespace.
		searchText = searchText:gsub("%[%d+]", ""):gsub("^%s*(.-)%s*$", "%1")

		-- The we separate out the pack and song into their own search terms.
		local packName = nil
		local songName = nil

		local forwardSlashIdx = searchText:find('/')
		if not forwardSlashIdx then
			songName = searchText
		else
			packName = searchText:sub(1, forwardSlashIdx - 1)
			songName = searchText:sub(forwardSlashIdx + 1)
		end

		-- Normalize empty strings to nil.
		if packName and #packName == 0 then packName = nil end
		if songName and #songName == 0 then songName = nil end

		-- If we have no search criteria, then return early.
		if not (packName or songName or difficulty or bpmTier) then return end

		-- Start with the complete song list.
		local candidates = SONGMAN:GetAllSongs()
		local stepsType = GAMESTATE:GetCurrentStyle():GetStepsType()

		-- Only add valid candidates if there are steps in the current mode.
		FilterTable(candidates, function(song) return song:HasStepsType(stepsType) end)

		if songName then
			FilterTable(candidates, function(song)
				return (song:GetDisplayFullTitle():lower():find(songName) ~= nil or
						song:GetTranslitFullTitle():lower():find(songName) ~= nil)
			end)
		end

		if packName then
			FilterTable(candidates, function(song) return song:GetGroupName():lower():find(packName) end)
		end

		if difficulty then
			FilterTable(candidates, function(song)
				local allSteps = song:GetStepsByStepsType(stepsType)
				for steps in ivalues(allSteps) do
					-- Don't consider edits.
					if steps:GetDifficulty() ~= "Difficulty_Edit" then
						if steps:GetMeter() == difficulty then
							return true
						end
					end
				end
				return false
			end)
		end

		if bpmTier then
			FilterTable(candidates, function(song)
				-- NOTE(teejusb): Not handling split bpms now, sorry.
				local bpms = song:GetDisplayBpms()
				if bpms[2]-bpms[1] == 0 then
					-- If only one BPM, then check to see if it's in the same tier.
					return bpmTier == GetBpmTier(bpms[1])
				else
					-- Otherwise check and see if the bpm is in the span of the tier.
					local lowTier = GetBpmTier(bpms[1])
					local highTier = GetBpmTier(bpms[2])
					return lowTier <= bpmTier and bpmTier <= highTier
				end
			end)
		end

		-- Even if we don't have any results, we want to show that to the player.
		MESSAGEMAN:Broadcast("DisplaySearchResults", {searchText=input, candidates=candidates})
	end,
}

-- General purpose function to redirect input back to the engine.
-- "self" here should refer to the SortMenu ActorFrame.
local DirectInputToEngine = function(self)
	local screen = SCREENMAN:GetTopScreen()
	local overlay = self:GetParent()

	screen:RemoveInputCallback(sortmenu_input)
	screen:RemoveInputCallback(testinput_input)
	screen:RemoveInputCallback(leaderboard_input)

	for player in ivalues(PlayerNumber) do
		SCREENMAN:set_input_redirected(player, false)
	end
	self:playcommand("HideSortMenu")
	overlay:playcommand("HideTestInput")
	overlay:playcommand("HideLeaderboard")
end

------------------------------------------------------------

local t = Def.ActorFrame {
	Name="SortMenu",
	-- Always ensure player input is directed back to the engine when initializing SelectMusic.
	InitCommand=function(self) self:visible(false):queuecommand("DirectInputToEngine") end,
	-- Always ensure player input is directed back to the engine when leaving SelectMusic.
	OffCommand=function(self) self:playcommand("DirectInputToEngine") end,
	-- Figure out which choices to put in the SortWheel based on various current conditions.
	OnCommand=function(self) self:playcommand("AssessAvailableChoices") end,
	-- We'll want to (re)assess available choices in the SortMenu if a player late-joins
	PlayerJoinedMessageCommand=function(self, params) self:queuecommand("AssessAvailableChoices") end,
	-- We'll also (re)asses if we want to display the leaderboard depending on if we're actually hovering over a song.
	CurrentSongChangedMessageCommand=function(self)
		if IsServiceAllowed(SL.GrooveStats.Leaderboard) then
			local curSong = GAMESTATE:GetCurrentSong()
			-- Only reasses if we go from song->group or group->song
			if (curSong and not hasSong) or (not curSong and hasSong) then
				self:queuecommand("AssessAvailableChoices")
			end
			hasSong = curSong and true or false
		end
	end,
	ShowSortMenuCommand=function(self) self:visible(true) end,
	HideSortMenuCommand=function(self) self:visible(false) end,
	DirectInputToSortMenuCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		local overlay = self:GetParent()
		screen:RemoveInputCallback(testinput_input)
		screen:RemoveInputCallback(leaderboard_input)
		screen:AddInputCallback(sortmenu_input)
		for player in ivalues(PlayerNumber) do
			SCREENMAN:set_input_redirected(player, true)
		end
		self:playcommand("ShowSortMenu")
		overlay:playcommand("HideTestInput")
		overlay:playcommand("HideLeaderboard")
	end,
	DirectInputToTestInputCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		local overlay = self:GetParent()
		screen:RemoveInputCallback(sortmenu_input)
		screen:AddInputCallback(testinput_input)
		for player in ivalues(PlayerNumber) do
			SCREENMAN:set_input_redirected(player, true)
		end
		self:playcommand("HideSortMenu")
		
		overlay:playcommand("ShowTestInput")
	end,
	DirectInputToLeaderboardCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		local overlay = self:GetParent()
		screen:RemoveInputCallback(sortmenu_input)
		screen:AddInputCallback(leaderboard_input)
		for player in ivalues(PlayerNumber) do
			SCREENMAN:set_input_redirected(player, true)
		end
		self:playcommand("HideSortMenu")
		
		overlay:playcommand("ShowLeaderboard")
	end,
	-- this returns input back to the engine and its ScreenSelectMusic
	DirectInputToEngineCommand=function(self)
		DirectInputToEngine(self)
	end,
	DirectInputToEngineForSongSearchCommand=function(self)
		DirectInputToEngine(self)

		-- Then add the ScreenTextEntry on top.
		SCREENMAN:AddNewScreenToTop("ScreenTextEntry")
		SCREENMAN:GetTopScreen():Load(SongSearchSettings)
	end,
	DirectInputToEngineForSelectProfileCommand=function(self)
		DirectInputToEngine(self)

		-- Then add the ScreenSelectProfile on top.
		SCREENMAN:AddNewScreenToTop("ScreenSelectProfile")
	end,

	AssessAvailableChoicesCommand=function(self)
		-- normally I would give variables like these file scope, and not declare
		-- within OnCommand(), but if the player uses the SortMenu to switch from
		-- single to double, we'll need reassess which choices to present.
		-- a style like "single", "double", "versus", "solo", or "routine"
		-- remove the possible presence of an "8" in case we're in Techno game
		-- and the style is "single8", "double8", etc.
		local style = GAMESTATE:GetCurrentStyle():GetName():gsub("8", "")
		local wheel_options = {
			{"ImLovinIt","AddFavorite"},
			{"SortBy", "Group"},
			{"MixTape","Favorites"},
			{"SortBy", "Title"},
			{"SortBy", "Artist"},
			{"SortBy", "Genre"},
			{"SortBy", "BPM"},
			{"SortBy", "Length"},
		}
		-- the engine's MusicWheel has distinct items in the SortOrder enum for double
		if style == "double" then
			table.insert(wheel_options, {"SortBy", "DoubleChallengeMeter"})
			table.insert(wheel_options, {"SortBy", "DoubleHardMeter"})
			table.insert(wheel_options, {"SortBy", "DoubleMediumMeter"})
			table.insert(wheel_options, {"SortBy", "DoubleEasyMeter"})
			table.insert(wheel_options, {"SortBy", "DoubleBeginnerMeter"})
		-- Otherwise... use the SortOrders that don't specify double.
		-- Does this imply that difficulty sorting in more uncommon styles
		-- (solo, routine, etc.) probably doesn't work?
		else
			table.insert(wheel_options, {"SortBy", "ChallengeMeter"})
			table.insert(wheel_options, {"SortBy", "HardMeter"})
			table.insert(wheel_options, {"SortBy", "MediumMeter"})
			table.insert(wheel_options, {"SortBy", "EasyMeter"})
			table.insert(wheel_options, {"SortBy", "BeginnerMeter"})
		end
		table.insert(wheel_options, {"SortBy", "Popularity"})
		table.insert(wheel_options, {"SortBy", "Recent"})
		-- Allow players to switch from single to double and from double to single
		-- but only present these options if Joint Double or Joint Premium is enabled
		if not (PREFSMAN:GetPreference("Premium") == "Premium_Off" and GAMESTATE:GetCoinMode() == "CoinMode_Pay") then
			if style == "single" then
				table.insert(wheel_options, {"ChangeStyle", "Double"})
				if ThemePrefs.Get("AllowDanceSolo") then
					table.insert(wheel_options, {"ChangeStyle", "Solo"})
				end
			elseif style == "double" then
				table.insert(wheel_options, {"ChangeStyle", "Single"})
				if ThemePrefs.Get("AllowDanceSolo") then
					table.insert(wheel_options, {"ChangeStyle", "Solo"})
				end
			elseif style == "solo" then
				table.insert(wheel_options, {"ChangeStyle", "Single"})
				table.insert(wheel_options, {"ChangeStyle", "Double"})
			-- Routine is not ready for use yet, but it might be soon.
			-- This can be uncommented at that time to allow switching from versus into routine.
			-- elseif style == "versus" then
			--	table.insert(wheel_options, {"ChangeStyle", "Routine"})
			end
		end
		-- Allow players to switch out to a different SL GameMode if no stages have been played yet,
		-- but don't add the current SL GameMode as a choice. If a player is already in FA+, don't
		-- present a choice that would allow them to switch to FA+.
		if SL.Global.Stages.PlayedThisGame == 0 then
			if SL.Global.GameMode ~= "ITG"      then table.insert(wheel_options, {"ChangeMode", "ITG"}) end
			if SL.Global.GameMode ~= "FA+"      then table.insert(wheel_options, {"ChangeMode", "FA+"}) end
			-- Casual players often choose the wrong mode and an experienced player in the area may notice this
			-- and offer to switch them back to casual mode. This allows them to do so again.
			-- It's technically not possible to reach the sort menu in Casual Mode, but juuust in case let's still
			-- include the check.
			if SL.Global.GameMode ~= "Casual"   then table.insert(wheel_options, {"ChangeMode", "Casual"}) end

		end

		-- Add operator functions if in event mode. (Public arcades probably don't want random players
		-- attempting to diagnose the pads or reload songs ...)
		if GAMESTATE:IsEventMode() then
			-- Allow players to switch to a TestInput overlay if the current game has visual assets to support it.
			local game = GAMESTATE:GetCurrentGame():GetName()
			if (game=="dance" or game=="pump" or game=="techno") then
				table.insert(wheel_options, {"FeelingSalty", "TestInput"})
			end

			table.insert(wheel_options, {"TakeABreather", "LoadNewSongs"})

			-- Only display the View Downloads option if we're connected to
			-- GrooveStats and Auto-Downloads are enabled.
			if SL.GrooveStats.IsConnected and ThemePrefs.Get("AutoDownloadUnlocks") then
				table.insert(wheel_options, {"NeedMoreRam", "ViewDownloads"})
			end
		end

		-- The relevant Leaderboard.lua actor is only added if these same conditions are met.
		if IsServiceAllowed(SL.GrooveStats.Leaderboard) then
			-- Also only add this if we're actually hovering over a song.
			if GAMESTATE:GetCurrentSong() then
				table.insert(wheel_options, {"GrooveStats", "Leaderboard"})
			end
		end

		if not GAMESTATE:IsCourseMode() then
			if ThemePrefs.Get("KeyboardFeatures") then
				-- Only display this option if keyboard features are enabled
				table.insert(wheel_options, {"WhereforeArtThou", "SongSearch"})
			end
		end

		if ThemePrefs.Get("AllowScreenSelectProfile") then
			table.insert(wheel_options, {"NextPlease", "SwitchProfile"})
		end

		-- Override sick_wheel's default focus_pos, which is math.floor(num_items / 2)
		--
		-- keep in mind that num_items is the number of Actors in the wheel (here, 7)
		-- NOT the total number of things you can eventually scroll through (#wheel_options = 14)
		--
		-- so, math.floor(7/2) gives focus to the third item in the wheel, which looks weird
		-- in this particular usage.  Thus, set the focus to the wheel's current 4th Actor.
		sort_wheel.focus_pos = 4
		-- get the currently active SortOrder and truncate the "SortOrder_" from the beginning
		local current_sort_order = ToEnumShortString(GAMESTATE:GetSortOrder())
		local current_sort_order_index = 1
		-- find the sick_wheel index of the item we want to display first when the player activates this SortMenu
		for i=1, #wheel_options do
			if wheel_options[i][1] == "SortBy" and wheel_options[i][2] == current_sort_order then
				current_sort_order_index = i
				break
			end
		end
		-- the second argument passed to set_info_set is the index of the item in wheel_options
		-- that we want to have focus when the wheel is displayed
		sort_wheel:set_info_set(wheel_options, current_sort_order_index)
	end,
	-- slightly darken the entire screen
	Def.Quad {
		InitCommand=function(self) self:FullScreen():diffuse(Color.Black):diffusealpha(0.8) end
	},
	-- OptionsList Header Quad
	Def.Quad {
		InitCommand=function(self) self:Center():zoomto(sortmenu.w+2,22):xy(_screen.cx, _screen.cy-92) end
	},
	-- "Options" text
	Def.BitmapText{
		Font="Common Bold",
		Text=ScreenString("Options"),
		InitCommand=function(self)
			self:xy(_screen.cx, _screen.cy-92):zoom(0.4)
				:diffuse( Color.Black )
		end
	},
	-- white border
	Def.Quad {
		InitCommand=function(self) self:Center():zoomto(sortmenu.w+2,sortmenu.h+2) end
	},
	-- BG of the sortmenu box
	Def.Quad {
		InitCommand=function(self) self:Center():zoomto(sortmenu.w,sortmenu.h):diffuse(Color.Black) end
	},
	-- top mask
	Def.Quad {
		InitCommand=function(self) self:Center():zoomto(sortmenu.w,_screen.h/2):y(40):MaskSource() end
	},
	-- bottom mask
	Def.Quad {
		InitCommand=function(self) self:zoomto(sortmenu.w,_screen.h/2):xy(_screen.cx,_screen.cy+200):MaskSource() end
	},
	-- "Press SELECT To Cancel" text
	Def.BitmapText{
		Font="Common Bold",
		Text=ScreenString("Cancel"),
		InitCommand=function(self)
			if PREFSMAN:GetPreference("ThreeKeyNavigation") then
				self:visible(false)
			else
				self:xy(_screen.cx, _screen.cy+100):zoom(0.3):diffuse(0.7,0.7,0.7,1)
			end
		end
	},
	-- this returns an ActorFrame ( see: ./Scripts/Consensual-sick_wheel.lua )
	sort_wheel:create_actors( "Sort Menu", 7, wheel_item_mt, _screen.cx, _screen.cy )
}
t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="change_sound", SupportPan = false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="start_sound", SupportPan = false }
return t
