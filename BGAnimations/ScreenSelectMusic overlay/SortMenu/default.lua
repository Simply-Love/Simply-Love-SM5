local sort_wheel = setmetatable({}, sick_wheel_mt)

local input = LoadActor("InputHandler.lua", sort_wheel)
local wheel_item_mt = LoadActor("WheelItemMT.lua")

local sortmenu = { w=210, h=160 }
-- - - - - - - - - - - - - - - - - - - - - - - - - - - -

local t = Def.ActorFrame {
	Name="SortMenu",
	InitCommand=function(self)
		-- ALWAYS ensure that the SortMenu is hidden and that players have
		-- input directed back to them on screen initialization.  Always.
		self:queuecommand("HideSortMenu")
			:draworder(1)
	end,
	ShowSortMenuCommand=function(self)
		SOUND:StopMusic()
		SCREENMAN:GetTopScreen():AddInputCallback(input)

		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			SCREENMAN:set_input_redirected(player, true)
		end
		self:visible(true)
	end,
	HideSortMenuCommand=function(self)
		SCREENMAN:GetTopScreen():RemoveInputCallback(input)
		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			SCREENMAN:set_input_redirected(player, false)
		end
		self:visible(false)
	end,

	OnCommand=function(self)
		self:visible(false)

		local wheel_options = {
			{"SortBy", "Group"},
			{"SortBy", "Title"},
			{"SortBy", "Artist"},
			{"SortBy", "Genre"},
			{"SortBy", "BPM"},
			{"SortBy", "Length"},
			{"SortBy", "BeginnerMeter"},
			{"SortBy", "EasyMeter"},
			{"SortBy", "MediumMeter"},
			{"SortBy", "HardMeter"},
			{"SortBy", "ChallengeMeter"},
			{"SortBy", "Popularity"},
			{"SortBy", "Recent"}
		}

		-- Allow players to switch from single to double and from double to single
		-- but only present these options if Joint Double or Joint Premium is enabled
		if PREFSMAN:GetPreference("Premium") ~= "Off" then
			if SL.Global.Gamestate.Style == "single" then
				table.insert(wheel_options, {"ChangeStyle", "Double"})
			elseif SL.Global.Gamestate.Style == "double" then
				table.insert(wheel_options, {"ChangeStyle", "Single"})
			end
		end


		-- Allow players to switch out to a different GameMode if no stages have been played yet.
		if SL.Global.Stages.PlayedThisGame == 0 then
			table.insert(wheel_options, {"ChangeMode", "Competitive"})
			table.insert(wheel_options, {"ChangeMode", "ECFA"})
			table.insert(wheel_options, {"ChangeMode", "StomperZ"})
		end

		-- Override sick_wheel's default focus_pos, which is math.floor(num_items / 2)
		--
		-- keep in mind that num_items is the number of Actors in the wheel (here, 7)
		-- NOT the total number of things you can eventually scroll through (#wheel_options = 14)
		--
		-- so, math.floor(7/2) gives focus to the third item in the wheel, which looks weird
		-- in this particular usage.  Thus, set the focus to the wheel's current 4th Actor.
		sort_wheel.focus_pos = 4

		-- get the currenly active SortOrder and truncate the "SortOrder_" from the beginning
		local current_sort_order = ToEnumShortString(GAMESTATE:GetSortOrder())
		local current_sort_order_index = 1

		for i=1, #wheel_options do
			if wheel_options[i][1] == "SortBy" and wheel_options[i][2] == current_sort_order then
				current_sort_order_index = i
				break
			end
		end
		for i=1, #wheel_options do
			if wheel_options[i][1] == "ChangeMode" and wheel_options[i][2] == SL.Global.GameMode then
				table.remove(wheel_options, i)
				break
			end
		end

		-- the second argument passed to set_info_set is the index of the item in wheel_options
		-- that we want to have focus when the wheel is created
		sort_wheel:set_info_set(wheel_options, current_sort_order_index)
	end,

	-- slightly darken the entire screen
	Def.Quad {
		InitCommand=function(self) self:FullScreen():diffuse(Color.Black):diffusealpha(0.8) end
	},

	-- OptionsList Header Quad
	Def.Quad {
		InitCommand=cmd(Center; zoomto,sortmenu.w+2,22; xy, _screen.cx, _screen.cy-92)
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
		InitCommand=cmd(Center; zoomto,sortmenu.w+2,sortmenu.h+2)
	},
	-- BG of the sortmenu box
	Def.Quad {
		InitCommand=cmd(Center; zoomto,sortmenu.w,sortmenu.h; diffuse,Color.Black)
	},
	-- top mask
	Def.Quad {
		InitCommand=cmd(Center; zoomto,sortmenu.w,_screen.h/2; y,40; MaskSource )
	},
	-- bottom mask
	Def.Quad {
		InitCommand=cmd(zoomto,sortmenu.w,_screen.h/2; xy,_screen.cx,_screen.cy+200; MaskSource)
	},

	-- "Press SELECT To Cancel" text
	Def.BitmapText{
		Font="_wendy small",
		Text=ScreenString("Cancel"),
		InitCommand=function(self)
			if PREFSMAN:GetPreference("ThreeKeyNavigation") then
				self:visible(false)
			else
				self:xy(_screen.cx, _screen.cy+100):zoom(0.3):diffusealpha(0.6)
			end
		end
	},

	-- this returns an ActorFrame ( see: ./Scripts/Consensual-sick_wheel.lua )
	sort_wheel:create_actors( "sort_wheel", 7, wheel_item_mt, _screen.cx, _screen.cy )
}

t[#t+1] = LoadActor( THEME:GetPathS("ScreenSelectMaster", "change") )..{ Name="change_sound", SupportPan = false }
t[#t+1] = LoadActor( THEME:GetPathS("common", "start") )..{ Name="start_sound", SupportPan = false }

return t
