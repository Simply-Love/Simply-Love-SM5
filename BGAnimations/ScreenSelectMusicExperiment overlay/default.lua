---------------------------------------------------------------------------
-- do as much setup work as possible in another file to keep default.lua
-- from becoming overly cluttered
local setup = LoadActor("./Setup.lua")
if setup == nil then
	return LoadActor(THEME:GetPathB("ScreenSelectMusicCasual", "overlay/NoValidSongs.lua"))
end

--Used to keep track of when we're changing songs
local timeToGo = 0
local scroll = 0

local steps_type = setup.steps_type
local group_info = setup.group_info

local OptionRows = setup.OptionRows
local OptionsWheel = setup.OptionsWheel
local GroupWheel = setup.GroupWheel
local SongWheel = setup.SongWheel
local row = setup.row
local col = setup.col

local TransitionTime = 0.5
local songwheel_y_offset = -13

local EnteringSong=false
---------------------------------------------------------------------------
-- a table of params from this file that we pass into the InputHandler file
-- so that the code there can work with them easily
local params_for_input = { GroupWheel=GroupWheel, SongWheel=SongWheel, OptionsWheel=OptionsWheel, OptionRows=OptionRows, EnteringSong=EnteringSong,DifficultyIndex0=4,DifficultyIndex1=4}

---------------------------------------------------------------------------
-- load the InputHandler and pass it the table of params
local Input = LoadActor( "./Input.lua", params_for_input )

-- metatables
local group_mt = LoadActor("./GroupMT.lua", {GroupWheel,SongWheel,TransitionTime,steps_type,row,col,Input})
local song_mt = LoadActor("./SongMT.lua", {SongWheel,TransitionTime,row,col})
local optionrow_mt = LoadActor("./OptionRowMT.lua")
local optionrow_item_mt = LoadActor("./OptionRowItemMT.lua")

---------------------------------------------------------------------------

local t = Def.ActorFrame {
	InitCommand=function(self)
		SL.Global.ExperimentScreen = true
		SL.Global.GoToOptions = false
		SL.Global.GameplayReloadCheck = false
		setup.InitGroups()
		self:GetChild("GroupWheel"):SetDrawByZPosition(true)
		self:queuecommand("Capture")
		local mpn = GAMESTATE:GetMasterPlayerNumber()
		--SongMT only broadcasts this message when the song is different from the previous one (ie ignores changing steps)
		--But this won't work when we first enter ScreenSelectMusicExperiment so we broadcast here once.
		params_for_input['DifficultyIndex'..PlayerNumber:Reverse()[mpn]] = Difficulty:Reverse()[GAMESTATE:GetCurrentSteps(mpn):GetDifficulty()]
		MESSAGEMAN:Broadcast("CurrentSongChanged",{song=GAMESTATE:GetCurrentSong()})
	end,
	OnCommand=function(self)
		if PREFSMAN:GetPreference("MenuTimer") then self:queuecommand("Listen") end
	end,
	ListenCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		local seconds = topscreen:GetChild("Timer"):GetSeconds()
		-- if necessary, force the players into Gameplay because the MenuTimer has run out
		if not Input.AllPlayersAreAtLastRow() and seconds <= 0 then

			-- if we we're not currently in the optionrows,
			-- we'll need to initialize them for the current song, first
			if Input.WheelWithFocus ~= OptionsWheel then
				setup.InitOptionRowsForSingleSong()
			end

			for player in ivalues(GAMESTATE:GetHumanPlayers()) do

				for index=1, #OptionRows-1 do
					local choice = OptionsWheel[player][index]:get_info_at_focus_pos()
					local choices= OptionRows[index]:Choices()
					local values = OptionRows[index].Values()

					OptionRows[index]:OnSave(player, choice, choices, values)
				end
			end
			topscreen:StartTransitioningScreen("SM_GoToNextScreen")
		else
			self:sleep(0.5):queuecommand("Listen")
		end
	end,
	CaptureCommand=function(self)

		-- One element of the Input table is an internal function, Handler
		SCREENMAN:GetTopScreen():AddInputCallback( Input.Handler )
		-- set up initial variable states and the players' OptionRows
		Input:Init()
		-- It should be safe to enable input for players now
		self:queuecommand("EnableMainInput")
	end,
	-- a hackish solution to prevent users from button-spamming and breaking input :O
	SwitchFocusToSongsMessageCommand=function(self)
		self:stoptweening():sleep(TransitionTime):queuecommand("EnableMainInput")
	end,
	SwitchFocusToGroupsMessageCommand=function(self)
		self:stoptweening():sleep(TransitionTime):queuecommand("EnableMainInput")
	end,
	SwitchFocusToSingleSongMessageCommand=function(self)
		setup.InitOptionRowsForSingleSong()
		self:stoptweening():sleep(TransitionTime):queuecommand("EnableMainInput")
	end,													  
	EnableMainInputCommand=function(self)
		Input.Enabled = true
	end,
	
	--Wrap this in an actor so stoptweening doesn't affect everything else
	Def.Actor{
		-- Called by SongMT when changing songs. Updating the histogram and the stream breakdown lags SM if players hold down left or right 
		-- and the wheel scrolls too quickly. To alleviate this, instead of using CurrentSongChanged, we wait for .08 seconds to have
		-- passed without changing songs before broadcasting "LessLag" which PaneDisplay receives. 
		BeginSongTransitionMessageCommand=function(self)
			self:stoptweening()	--TODO if you press enter while holding left or right you can break input
			scroll = scroll + 1
			if scroll > 3 then
				if not SL.Global.Scrolling then SL.Global.Scrolling = true MESSAGEMAN:Broadcast("BeginScrolling") end
			end
			timeToGo = GetTimeSinceStart() - SL.Global.TimeAtSessionStart + .08 --TODO on especially laggy computers these numbers don't work
			self:sleep(.15):queuecommand("FinishSongTransition")
		end,
		FinishSongTransitionMessageCommand=function(self)
			if (GetTimeSinceStart() - SL.Global.TimeAtSessionStart) > timeToGo and SL.Global.SongTransition then
				self:stoptweening()
				scroll = 0
				SL.Global.Scrolling = false
				SL.Global.SongTransition=false
				MESSAGEMAN:Broadcast("LessLag")
			end
		end
	},
	--if we choose a song in Search then we want to jump straight to it even if we're on the group wheel
	SetSongViaSearchMessageCommand=function(self)
		if Input.WheelWithFocus == GroupWheel then --going from group to song
			Input.WheelWithFocus.container:playcommand("Start")
			SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
			Input.WheelWithFocus = SongWheel
			Input.WheelWithFocus.container:playcommand("Unhide")
			SL.Global.GroupToSong = true
		end
	end,		
	-- Apply player modifiers from profile
	LoadActor("./PlayerModifiers.lua"),
	-- Shared items on the OptionWheel GUI
	LoadActor("./PlayerOptionsShared.lua", {row, col, Input}),
	-- elements we need two of - panes for the OptionWheel GUI
	LoadActor("./PerPlayer/PlayerOptionsPanes/default.lua"),
	-- right now this just has the black rectangle going across the screen.
	-- there's also a different style of text that are disabled
	LoadActor("./SongWheelShared.lua", {row, col, songwheel_y_offset}), 
	-- create a sickwheel metatable for songs
	SongWheel:create_actors( "SongWheel", 13, song_mt, 0, songwheel_y_offset - 40), 
	-- the grey bar at the top as well as total time since start																				
	LoadActor("./Header.lua", row),
	-- profile information and time spent in game
	-- note that this covers the footer in graphics
	LoadActor("Footer.lua"),
	-- this has information about the groups - number of songs/charts/filters/# of passed charts
	LoadActor("./GroupWheelShared.lua", {row, col, group_info}), 
	-- create a sickwheel metatable for groups
	GroupWheel:create_actors( "GroupWheel", row.how_many * col.how_many, group_mt, 0, 0, true), 
	-- Graphical Banner
	LoadActor("./Banner.lua"), -- the big banner above song information
	--All of this stuff is put in an AF because we hide and show it together
	--Information about the song - including the grid/stream info, nps histogram, and step information
	Def.ActorFrame{
		SwitchFocusToGroupsMessageCommand=function(self) self:stoptweening():queuecommand("Hide") end,
		SwitchFocusToSingleSongMessageCommand=function(self) self:stoptweening():queuecommand("Hide") end,
		SwitchFocusToSongsMessageCommand = function(self) self:stoptweening():queuecommand("Show") end,
		CloseThisFolderHasFocusMessageCommand = function(self) self:stoptweening():queuecommand("Hide") end, --don't display any of this when we're on the close folder item
		CurrentSongChangedMessageCommand = function(self, params) --brings things back after CloseThisFolderHasFocusMessageCommand runs
			if params.song and self:GetDiffuseAlpha() == 0 and Input.WheelWithFocus == SongWheel then self:stoptweening():queuecommand("Show") end end,
		CurrentCourseChangedMessageCommand = function(self)  end,
		HideCommand = function(self) self:linear(.3):diffusealpha(0):visible(false) end,
		ShowCommand = function(self) self:visible(true):linear(.3):diffusealpha(1) end,

		-- elements we need two of (one for each player) that draw underneath the StepsDisplayList
		-- this includes the stepartist boxes and the PaneDisplays (number of steps, jumps, holds, etc.)
		LoadActor("./PerPlayer/Under.lua"),
		-- grid of Difficulty Blocks (normal) or CourseContentsList (CourseMode)
		LoadActor("./StepsDisplayList/default.lua"),
		-- elements we need two of that draw over the StepsDisplayList (cursor and function to automatically jump to a valid chart when changing songs)
		LoadActor("./PerPlayer/Over.lua", params_for_input),
		-- Song Artist, BPM, Duration (Referred to in other themes as "PaneDisplay")
		LoadActor("./songDescription.lua"),
		-- Scroll bar
		Def.Quad{
			InitCommand=function(self) 
				self:x(_screen.w-10):valign(0):visible(false)
			end,
			CurrentSongChangedMessageCommand=function(self,params)
				local num_songs = #PruneSongList(GetSongList(SL.Global.CurrentGroup))
				if SL.Global.Order == "Difficulty/BPM" then num_songs = #DifficultyBPM end
				local size = (_screen.h-64) / num_songs --header and footer are each 32
				local position = params.index and params.index or FindInTable(GAMESTATE:GetCurrentSong(),PruneSongList(GetSongList(SL.Global.CurrentGroup))) or 0
				if position == 0 then self:visible(false) --if we're on the close folder option
				else self:visible(true):zoomto(20,size):y(position*size-size+32) end
			end
		}
	},
	-- finally, load the overlay used for sorting the MusicWheel (and more), hidden by default
	LoadActor("./SortMenu/default.lua"),
	-- a Test Input overlay can (maybe) be accessed from the SortMenu
	LoadActor("./TestInput.lua"),
	-- The menu for adding/removing tags
	LoadActor("./TagMenu/default.lua"),
	-- The menu for changing the order songs display in
	LoadActor("./OrderMenu/default.lua"),
	--Stuff related to searching
	LoadActor("./Search/default.lua"),
	
	-- Broadcast when we enter the Sort Menu. Don't want to let input touch the normal screen
	DirectInputToSortMenuMessageCommand=function(self)
		Input.Enabled = false
	end,
	-- Broadcast when coming out of the Sort Menu.
	DirectInputToEngineMessageCommand=function(self)
		self:queuecommand("EnableMainInput")
		if Input.WheelWithFocus == SongWheel then
			play_sample_music()
		end
	end,
	-- Broadcast by SortMenu_InputHandler when someone chooses a sort type
	GroupTypeChangedMessageCommand=function(self)
		-- we have to figure out what group we're supposed to be in now depending on the current song
		-- if they entered the sort menu while on "Close This Folder" then GetCurrentSong() will return nil
		-- in that case grab the last seen song (set by SongMT)
		local current_song = GAMESTATE:GetCurrentSong() or SL.Global.LastSeenSong
		local mpn = GAMESTATE:GetMasterPlayerNumber()
		--set global variables for the difficulty group and grade group so we can keep the scroll on the correct one when CurrentSongChangedMessageCommand is called
		SL.Global.DifficultyGroup = GAMESTATE:GetCurrentSteps(mpn):GetMeter()
		local highScore = PROFILEMAN:GetProfile(mpn):GetHighScoreList(current_song,GAMESTATE:GetCurrentSteps(mpn)):GetHighScores()[1] --TODO this only works for master player
		if highScore then SL.Global.GradeGroup = highScore:GetGrade()
		else SL.Global.GradeGroup = "No_Grade" end
		setup.InitGroups() --this prunes out groups with no songs in them (or resets filters if we have 0 songs) and resets GroupWheel
		group_info = setup.GetGroupInfo()
		-- Broadcast to GroupWheelShared letting it know to reset all its information
		MESSAGEMAN:Broadcast("UpdateGroupInfo", {group_info, GroupWheel:get_actor_item_at_focus_pos().groupName})
	end,
	
	--Screen Transition stuff

	-- This command is broadcast by input.handler when it tries to start a song.
	-- Emulates the "Press START for options that native screenselectmusic has
	-- if we're allowing it (set in prefs)
	ScreenTransitionMessageCommand=function(self) 
		if ThemePrefs.Get("AllowTwoTap") then
			self:playcommand("TransitionQuadOff")
			self:queuecommand("ShowPressStartForOptions")
			params_for_input.EnteringSong = true
			self:sleep(2):queuecommand("GoToNextScreen")

		else
			Input.Enabled = false
			self:playcommand("TransitionQuadOff")
			self:sleep(.3):queuecommand("GoToNextScreen")
		end
	end,
	
	-- ScreenTransitionMessageCommand waits two seconds for the user to hit start again - then goes to either options or gameplay
	GoToNextScreenCommand=function(self)
		SL.Global.ExperimentScreen = false
		local topscreen = SCREENMAN:GetTopScreen()
		if topscreen then
			topscreen:StartTransitioningScreen("SM_GoToNextScreen")
		end
	end,
	-- If someone presses start then we set a flag telling us where to go next and change from "Press Start..." to "Entering Options"
	GoToOptionsMessageCommand=function(self)
		SL.Global.GoToOptions = true
		self:playcommand("ShowEnteringOptions")
	end,
	-- Exit Code from normal Simply Love
	-- TODO if you don't know about this it's hard to find, bad if you accidentally hit it. find a better way
	CodeMessageCommand=function(self, params)
		if params.Name == "Exit" then
			SCREENMAN:GetTopScreen():SetNextScreenName( Branch.SSMCancel() ):StartTransitioningScreen("SM_GoToNextScreen") 
		end
	end,
}

-- Add player options ActorFrames to our primary ActorFrame
for pn in ivalues( {PLAYER_1, PLAYER_2} ) do
	local x_offset = (pn==PLAYER_1 and -1) or 1

	-- create an optionswheel that has enough items to handle the number of optionrows necessary
	t[#t+1] = OptionsWheel[pn]:create_actors("OptionsWheel"..ToEnumShortString(pn), #OptionRows, optionrow_mt, _screen.cx - 100 + 140 * x_offset, _screen.cy - 30)

	for i=1,#OptionRows do
		-- Create sub-wheels for each optionrow with 3 items each.
		-- Regardless of how many items are actually in that row,
		-- we only display 1 at a time.
		t[#t+1] = OptionsWheel[pn][i]:create_actors(ToEnumShortString(pn).."OptionWheel"..i, 3, optionrow_item_mt, WideScale(30, 130) + 140 * x_offset, _screen.cy - 5 + i * 62)
	end
	OptionsWheel[pn].focus_pos = #OptionRows --start with the bottom (Start) selected
end

-- FIXME: This is dumb.  Add the player option StartButton visual last so it
--  draws over everything else and we can hide cusors behind it when needed...
t[#t+1] = LoadActor("./StartButton.lua")

----------------------------------------------------------
-- More Screen Transition stuff----------------------------------
-- This is added last so the black quad covers everything up

t[#t+1] = Def.Quad{
	InitCommand=function(self) self:diffuse(0,0,0,0):FullScreen():cropbottom(1) end,
	TransitionQuadOffCommand=function(self) 
		self:linear(0.3):cropbottom(0):diffusealpha(1)
	end
}

t[#t+1] = LoadFont("Common Normal")..{
		Name="TextDisplay",
		Text=THEME:GetString("ScreenSelectMusicExperiment", "Press Start for Options"),
		InitCommand=function(self) self:visible(false):Center():zoom(1):diffusealpha(0) end,
		ShowPressStartForOptionsCommand=function(self) self:hibernate(.3):visible(true):linear(0.3):diffusealpha(1) end,
		ShowEnteringOptionsCommand=function(self) self:linear(0.125):diffusealpha(0):queuecommand("NewText") end,
		NewTextCommand=function(self) self:hibernate(0.1):settext(THEME:GetString("ScreenSelectMusicExperiment", "Entering Options...")):linear(0.125):diffusealpha(1):sleep(1) end
}

return t