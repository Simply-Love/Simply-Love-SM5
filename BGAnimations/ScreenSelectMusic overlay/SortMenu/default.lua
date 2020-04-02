------------------------------------------------------------
-- set up the SortMenu's choices first, prior to Actor initialization

-- sick_wheel_mt is a metatable with global scope defined in ./Scripts/Consensual-sick_wheel.lua
local sort_wheel = setmetatable({}, sick_wheel_mt)

-- the logic that handles navigating the SortMenu
-- (scrolling through choices, choosing one, canceling)
-- is large enough that I moved it to its own file
local sortmenu_input = LoadActor("SortMenu_InputHandler.lua", sort_wheel)
local testinput_input = LoadActor("TestInput_InputHandler.lua")

-- WheelItemMT is a generic definition of an choice within the SortMenu
-- "mt" is my personal means of denoting that it (the file, the variable, whatever)
-- has something to do with a Lua metatable.
--
-- metatables in Lua are a useful construct when designing reusable components,
-- but many online tutorials and guides are incredibly obtuse and unhelpful
-- for non-computer-science people (like me). https://lua.org/pil/13.html is just frustratingly scant.
--
-- http://phrogz.net/lua/LearningLua_ValuesAndMetatables.html is less bad than most.
-- I get immediately lost in the criss-crossing diagrams, and I'll continue to
-- argue that naming things foo, bar, and baz abstract programming tutorials right
-- out of practical reality, but I found its prose to be practical, applicable, and concise,
-- so I guess I'll recommend that tutorial until I find a more helpful one.
local wheel_item_mt = LoadActor("WheelItemMT.lua")

local sortmenu = { w=210, h=160 }

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


	ShowSortMenuCommand=function(self) self:visible(true) end,
	HideSortMenuCommand=function(self) self:visible(false) end,

	DirectInputToSortMenuCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		local overlay = self:GetParent()

		screen:RemoveInputCallback(testinput_input)
		screen:AddInputCallback(sortmenu_input)

		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			SCREENMAN:set_input_redirected(player, true)
		end
		self:playcommand("ShowSortMenu")
		overlay:playcommand("HideTestInput")
	end,
	DirectInputToTestInputCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		local overlay = self:GetParent()

		screen:RemoveInputCallback(sortmenu_input)
		screen:AddInputCallback(testinput_input)

		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			SCREENMAN:set_input_redirected(player, true)
		end
		self:playcommand("HideSortMenu")
		overlay:playcommand("ShowTestInput")
	end,
	-- this returns input back to the engine and its ScreenSelectMusic
	DirectInputToEngineCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		local overlay = self:GetParent()

		screen:RemoveInputCallback(sortmenu_input)
		screen:RemoveInputCallback(testinput_input)

		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			SCREENMAN:set_input_redirected(player, false)
		end
		self:playcommand("HideSortMenu")
		overlay:playcommand("HideTestInput")
	end,



	AssessAvailableChoicesCommand=function(self)
		self:visible(false)

		-- normally I would give variables like these file scope, and not declare
		-- within OnCommand(), but if the player uses the SortMenu to switch from
		-- single to double, we'll need reassess which choices to present.

		-- a style like "single", "double", "versus", "solo", or "routine"
		-- remove the possible presence of an "8" in case we're in Techno game
		-- and the style is "single8", "double8", etc.
		local style = GAMESTATE:GetCurrentStyle():GetName():gsub("8", "")

		local wheel_options = {
			{"SortBy", "Group"},
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
				if ThemePrefs.Get("AllowDanceSolo") then
					table.insert(wheel_options, {"ChangeStyle", "Solo"})
				end

				table.insert(wheel_options, {"ChangeStyle", "Double"})

			elseif style == "double" then
				table.insert(wheel_options, {"ChangeStyle", "Single"})

			elseif style == "solo" then
				table.insert(wheel_options, {"ChangeStyle", "Single"})

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
		end

		-- allow players to switch to a TestInput overlay if the current game has visual assets to support it
		-- and if we're in EventMode (public arcades probably don't want random players attempting to diagnose the pads...)
		local game = GAMESTATE:GetCurrentGame():GetName()
		if (game=="dance" or game=="pump" or game=="techno") and GAMESTATE:IsEventMode() then
			table.insert(wheel_options, {"FeelingSalty", "TestInput"})
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
		Font="_wendy small",
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
		Font="_wendy small",
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
