---------------------------------------------------------------------------
-- do as much setup work as possible in another file to keep default.lua
-- from becoming overly cluttered
local setup = LoadActor("./Setup.lua")
if setup == nil then
	return LoadActor(THEME:GetPathB("ScreenSelectMusicCasual", "overlay/NoValidSongs.lua"))
end


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
local params_for_input = { GroupWheel=GroupWheel, SongWheel=SongWheel, OptionsWheel=OptionsWheel, OptionRows=OptionRows, EnteringSong=EnteringSong,DifficultyIndex=4}

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
		SL.Global.GoToOptions = false
		SL.Global.GameplayReloadCheck = false
		setup.InitGroups()
		self:GetChild("GroupWheel"):SetDrawByZPosition(true)
		self:queuecommand("Capture")
		--SongMT only broadcasts this message when the song is different from the previous one (ie ignores changing steps)
		--But this won't work when we first enter ScreenSelectMusicExperiment so we broadcast here once.
		params_for_input.DifficultyIndex = Difficulty:Reverse()[GAMESTATE:GetCurrentSteps(0):GetDifficulty()]
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
		self:queuecommand("EnableInput")
	end,
	-- a hackish solution to prevent users from button-spamming and breaking input :O
	SwitchFocusToSongsMessageCommand=function(self)
		self:sleep(TransitionTime):queuecommand("EnableInput")
	end,
	SwitchFocusToGroupsMessageCommand=function(self)
		self:sleep(TransitionTime):queuecommand("EnableInput")
	end,
	SwitchFocusToSingleSongMessageCommand=function(self)
		setup.InitOptionRowsForSingleSong()

		self:sleep(TransitionTime):queuecommand("EnableInput")
	end,													  
	EnableInputCommand=function(self)
		Input.Enabled = true
	end,
	
	-- broadcast by SongMT as part of a wheel transition. Also broadcast from somewhere not in the theme. SongMT adds a song to params
	-- while the other source doesn't so we can use that to check and only act on the one we want to (the SongMT one)
	CurrentSongChangedMessageCommand=function(self, params)
		if params.song then
			-- Here we determine which set of steps we should be on when the song changes. params_for_input.DifficultyIndex is used by the cursor
			-- to figure out where to display.
			
			--if we're grouping by grade then we want to keep the chosen grade set for the next song. (only if at least one set of steps has a grade)
			--note that we set params_for_input.DifficultyIndex manually here because we might be forcing the cursor to a different difficulty
			if SL.Global.GroupType == "Grade" and SL.Global.GradeGroup ~= "No_Grade" then
				local currentGrade = SL.Global.GradeGroup
				for steps in ivalues(params.song:GetStepsByStepsType(GetStepsType())) do
					local highScore = PROFILEMAN:GetProfile(0):GetHighScoreList(params.song,steps):GetHighScores()[1] --TODO this only works for player 1
					if highScore then 
						if highScore:GetGrade() == currentGrade then 
							GAMESTATE:SetCurrentSteps(0,steps) --TODO this only works for player 1
							params_for_input.DifficultyIndex = Difficulty:Reverse()[GAMESTATE:GetCurrentSteps(0):GetDifficulty()]
							break
						end
					end
				end
			--if we're grouping by difficulty then we want to keep the chosen difficulty when changing songs
			--note that we set params_for_input.DifficultyIndex manually here because we might be forcing the cursor to a different difficulty
			elseif SL.Global.GroupType == "Difficulty" then
				local currentDifficulty = SL.Global.DifficultyGroup
				for steps in ivalues(params.song:GetStepsByStepsType(GetStepsType())) do
					if steps:GetMeter() == tonumber(currentDifficulty) then
						GAMESTATE:SetCurrentSteps(0,steps) --TODO this only works for player 1
						params_for_input.DifficultyIndex = Difficulty:Reverse()[GAMESTATE:GetCurrentSteps(0):GetDifficulty()]
						break
					end
				end
			--otherwise try to choose the same difficulty if it exists(challenge, expert, basic, etc)
			elseif Input.DifficultyExists() then
				GAMESTATE:SetCurrentSteps(0,params.song:GetOneSteps('StepsType_Dance_Single',params_for_input.DifficultyIndex))
			--otherwise default to next closest
			--note that we set params_for_input.DifficultyIndex manually here because we might be forcing the cursor to a different difficulty
			else
				--check if there's an easier chart
				local easier = Input.NextEasiest() and Difficulty:Reverse()[Input.NextEasiest():GetDifficulty()] or nil
				--check if there's a harder chart
				local harder = Input.NextHardest() and Difficulty:Reverse()[Input.NextHardest():GetDifficulty()] or nil
				--if the difference between harder and current difficulty is greater than the difference between easier and current
				--then we can throw away the harder steps as we know the easier is closer
				if harder and easier then 
					if harder - params_for_input.DifficultyIndex > params_for_input.DifficultyIndex - easier then harder = nil end
				end
				--if they're equally close then default to harder steps, otherwise, set to the closest difficulty
				GAMESTATE:SetCurrentSteps(0,harder and Input.NextHardest() or easier and Input.NextEasiest())
				params_for_input.DifficultyIndex = Difficulty:Reverse()[GAMESTATE:GetCurrentSteps(0):GetDifficulty()]
				
			end
		end
	end,
	
				
	-- Apply player modifiers from profile
	LoadActor("./PlayerModifiers.lua"),
	LoadActor("./PlayerOptionsShared.lua", {row, col, Input}),
	-- right now this just has the black rectangle going across the screen.
	-- there are also left/right arrows and a different style of text that are disabled
	LoadActor("./SongWheelShared.lua", {row, col, songwheel_y_offset}), 
	-- this has information about the groups - number of songs/charts/filters/# of passed charts
	LoadActor("./GroupWheelShared.lua", {row, col, group_info}), 
	-- create a sickwheel metatable for songs
	SongWheel:create_actors( "SongWheel", 12, song_mt, 0, songwheel_y_offset - 13), 
	-- the grey bar at the top as well as total time since start																				
	LoadActor("./Header.lua", row),
	-- create a sickwheel metatable for groups
	GroupWheel:create_actors( "GroupWheel", row.how_many * col.how_many, group_mt, 0, 0, true), 
	LoadActor("FooterHelpText.lua"), -- profile information and time spent in game
	
	-- Graphical Banner
	LoadActor("./Banner.lua"), -- the big banner above song information
	
	--All of this stuff is put in an AF because we hide and show it together
	--Information about the song - including the grid/stream info, nps histogram, and step information
	Def.ActorFrame{
		OnCommand = function(self) self:queuecommand("Show") end,
		SwitchFocusToGroupsMessageCommand=function(self) self:queuecommand("Hide") end,
		SwitchFocusToSingleSongMessageCommand=function(self) self:queuecommand("Hide") end,
		SwitchFocusToSongsMessageCommand = function(self) self:queuecommand("Show") end,
		CloseThisFolderHasFocusMessageCommand = function(self) self:queuecommand("Hide") end, --don't display any of this when we're on the close folder item
		CurrentSongChangedMessageCommand = function(self) --brings things back after CloseThisFolderHasFocusMessageCommand runs
			if self:GetDiffuseAlpha() == 0 then self:queuecommand("Show") end end,
		CurrentCourseChangedMessageCommand = function(self)  end,
		HideCommand = function(self) self:linear(.3):diffusealpha(0):visible(false) end,
		ShowCommand = function(self) self:visible(true):linear(.3):diffusealpha(1) end,

		-- elements we need two of (one for each player) that draw underneath the StepsDisplayList
		-- this includes the stepartist boxes and the PaneDisplays (number of steps, jumps, holds, etc.)
		LoadActor("./PerPlayer/Under.lua"),
		-- grid of Difficulty Blocks (normal) or CourseContentsList (CourseMode)
		LoadActor("./StepsDisplayList/default.lua"),
		-- elements we need two of that draw over the StepsDisplayList (just the bouncing cursors, really)
		LoadActor("./PerPlayer/Over.lua"),
		-- Song Artist, BPM, Duration (Referred to in other themes as "PaneDisplay")
		LoadActor("./songDescription.lua"),
	},
	-- finally, load the overlay used for sorting the MusicWheel (and more), hidden by default
	LoadActor("./SortMenu/default.lua"),
	-- a Test Input overlay can (maybe) be accessed from the SortMenu
	LoadActor("./TestInput.lua"),
	-- The menu for adding/removing tags
	LoadActor("./TagMenu/default.lua"),

	
	-- Sort Menu Stuff
	
	-- Broadcast when we enter the Sort Menu. Don't want to let input touch the normal screen
	DirectInputToSortMenuMessageCommand=function(self)
		Input.Enabled = false
	end,
	-- Broadcast when coming out of the Sort Menu.
	DirectInputToEngineMessageCommand=function(self)
		self:playcommand("EnableInput")
	end,
	-- Broadcast by SortMenu_InputHandler when someone chooses a sort type
	GroupTypeChangedMessageCommand=function(self)
		-- we have to figure out what group we're supposed to be in now depending on the current song
		-- if they entered the sort menu while on "Close This Folder" then GetCurrentSong() will return nil
		-- in that case grab the last seen song (set by SongMT)
		local current_song = GAMESTATE:GetCurrentSong() or SL.Global.LastSeenSong

		--set global variables for the difficulty group and grade group so we can keep the scroll on the correct one when CurrentSongChangedMessageCommand is called
		SL.Global.DifficultyGroup = GAMESTATE:GetCurrentSteps(0):GetMeter()
		local highScore = PROFILEMAN:GetProfile(0):GetHighScoreList(current_song,GAMESTATE:GetCurrentSteps(0)):GetHighScores()[1] --TODO this only works for player one
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
	ScreenTransitionMessageCommand=function(self) 
		Input.Enabled = false --TODO double tap start to enter options won't work with this
		self:playcommand("TransitionQuadOff")
		self:queuecommand("ShowPressStartForOptions")
		params_for_input.EnteringSong = true
		self:sleep(2):queuecommand("GoToNextScreen")
	end,
	
	-- ScreenTransitionMessageCommand waits two seconds for the user to hit start again - then goes to either options or gameplay
	GoToNextScreenCommand=function(self)
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
end
OptionsWheel['PlayerNumber_P1'].focus_pos = #OptionRows --start with the bottom (Start) selected


-- FIXME: This is dumb.  Add the player option StartButton visual last so it
--  draws over everything else and we can hide cusors behind it when needed...
t[#t+1] = LoadActor("./StartButton.lua")

----------------------------------------------------------
-- More Screen Transition stuff----------------------------------
-- This is added last so the black quad covers everything up

t[#t+1] = Def.Quad{
	InitCommand=function(self) self:diffuse(0,0,0,0):FullScreen():cropbottom(1):fadebottom(0.5) end,
	TransitionQuadOffCommand=function(self) 
		self:linear(0.3):cropbottom(-0.5):diffusealpha(1)
	end
}

t[#t+1] = LoadFont("Common Normal")..{
		Name="TextDisplay",
		Text=THEME:GetString("ScreenSelectMusic", "Press Start for Options"),
		InitCommand=function(self) self:visible(false):Center():zoom(1):diffusealpha(0) end,
		ShowPressStartForOptionsCommand=function(self) self:hibernate(.3):visible(true):linear(0.3):diffusealpha(1) end,
		ShowEnteringOptionsCommand=function(self) self:linear(0.125):diffusealpha(0):queuecommand("NewText") end,
		NewTextCommand=function(self) self:hibernate(0.1):settext(THEME:GetString("ScreenSelectMusic", "Entering Options...")):linear(0.125):diffusealpha(1):sleep(1) end
}

return t