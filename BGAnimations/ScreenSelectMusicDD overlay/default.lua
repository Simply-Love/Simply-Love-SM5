---------------------------------------------------------------------------
-- do as much setup work as possible in another file to keep default.lua
-- from becoming overly cluttered

local setup = LoadActor("./Setup.lua")
local ChartUpdater = LoadActor("./UpdateChart.lua")
local LeavingScreenSelectMusicDD = false

ChartUpdater.UpdateCharts()

if setup == nil then
	return LoadActor(THEME:GetPathB("ScreenSelectMusicDD", "overlay/NoValidSongs.lua"))
end

local steps_type = setup.steps_type
local Groups = setup.Groups
local group_index = setup.group_index
local group_info = setup.group_info

local GroupWheel = setmetatable({}, sick_wheel_mt)
local SongWheel = setmetatable({}, sick_wheel_mt)
local SearchWheel = setmetatable({}, sick_wheel_mt)

local row = setup.row
local col = setup.col

local TransitionTime = 0.3
local songwheel_y_offset = 13

---------------------------------------------------------------------------
-- a table of params from this file that we pass into the InputHandler file
-- so that the code there can work with them easily
local params_for_input = { GroupWheel=GroupWheel, SongWheel=SongWheel, SortWheel=SortWheel }

---------------------------------------------------------------------------
-- load the InputHandler and pass it the table of params
local Input = LoadActor( "./Input.lua", params_for_input )

-- metatables
local group_mt = LoadActor("./GroupMT.lua", {GroupWheel,SongWheel,TransitionTime,steps_type,row,col,Input,setup.PruneSongsFromGroup,Groups[group_index]})
local song_mt = LoadActor("./SongMT.lua", {SongWheel,TransitionTime,row,col})

---------------------------------------------------------------------------

local CloseCurrentFolder = function()
	-- if focus is already on the GroupWheel, we don't need to do anything more
	if Input.WheelWithFocus == GroupWheel then 
	NameOfGroup = ""
	return end

	--GAMESTATE:SetCurrentSong(nil)
	if SongSearchWheelNeedsResetting == true then
		SongSearchWheelNeedsResetting = false
		MESSAGEMAN:Broadcast("ReloadSSMDD")
	else	
		-- otherwise...
		MESSAGEMAN:Broadcast("SwitchFocusToGroups")
		Input.WheelWithFocus.container:queuecommand("Hide")
		Input.WheelWithFocus = GroupWheel
		Input.WheelWithFocus.container:queuecommand("Unhide")
	end
	
end



local t = Def.ActorFrame {
	InitCommand=function(self)
		GroupWheel:set_info_set(Groups, group_index)
		local groupWheel = self:GetChild("GroupWheel")
		groupWheel:SetDrawByZPosition(true)

		self:queuecommand("Capture")
	end,
	OnCommand=function(self)
		if PREFSMAN:GetPreference("MenuTimer") then self:queuecommand("Listen") end
	end,
	ListenCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()
		local seconds = topscreen:GetChild("Timer"):GetSeconds()
	end,
	CaptureCommand=function(self)

		-- One element of the Input table is an internal function, Handler
		SCREENMAN:GetTopScreen():AddInputCallback( Input.Handler )

		-- set up initial variable states
		Input:Init()

		-- It should be safe to enable input for players now
		self:queuecommand("EnableInput")
	end,
	
	ShowOptionsJawnMessageCommand=function(self)
		if LeavingScreenSelectMusicDD == false then
			LeavingScreenSelectMusicDD = true
		end
	end,
	CodeMessageCommand=function(self, params)
		-- I'm using Metrics-based code detection because the engine is already good at handling
		-- simultaneous button presses (CancelSingleSong when ThreeKeyNavigation=1),
		-- as well as long input patterns (Exit from EventMode) and I see no need to
		-- reinvent that functionality for the Lua InputCallback that I'm using otherwise.
		
		-- Don't do these codes if the sort menu is open or if going to the options screen
		if LeavingScreenSelectMusicDD == false then
			if isSortMenuVisible == false then
				if InputMenuHasFocus == false then
					if params.Name == "CancelSingleSong" then
						-- otherwise, run the function to cancel this single song choice
						Input.CancelSongChoice()
					end
					if params.Name == "CloseCurrentFolder" or params.Name == "CloseCurrentFolder2" then
						if Input.WheelWithFocus == SongWheel then
							SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
							CloseCurrentFolder()
							MESSAGEMAN:Broadcast("CloseThisFolderHasFocus")
						end
					end
					if params.Name == "SortList" or params.Name == "SortList2" then
						isSortMenuVisible = true
						SOUND:StopMusic()
						SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "sort.ogg") )
						if params.PlayerNumber == 'PlayerNumber_P1' then
							PlayerControllingSort = 'PlayerNumber_P1' 
						else
							PlayerControllingSort = 'PlayerNumber_P2'
						end
						if GAMESTATE:GetCurrentSong() ~= nil then
							DDStats.SetStat(PLAYER_1, 'LastSong', GAMESTATE:GetCurrentSong():GetSongDir())
						end
						MESSAGEMAN:Broadcast("InitializeDDSortMenu")
						MESSAGEMAN:Broadcast("CheckForSongLeaderboard")
						MESSAGEMAN:Broadcast("ToggleSortMenu")
					end
				end
			--- do this to close the sort menu for people using 3 button input
			else 
				if params.Name == "SortList" or params.Name == "SortList2" then
					if IsSortMenuInputToggled == false then
						if SortMenuNeedsUpdating == true then
							SortMenuNeedsUpdating = false
							MESSAGEMAN:Broadcast("ToggleSortMenu")
							MESSAGEMAN:Broadcast("ReloadSSMDD")
							isSortMenuVisible = false
							SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
						elseif SortMenuNeedsUpdating == false then
							isSortMenuVisible = false
							SOUND:PlayOnce( THEME:GetPathS("ScreenPlayerOptions", "cancel all.ogg") )
							MESSAGEMAN:Broadcast("ToggleSortMenu")
						end
					else
						SOUND:PlayOnce( THEME:GetPathS("common", "invalid.ogg") )
						MESSAGEMAN:Broadcast("UpdateCursorColor")
						MESSAGEMAN:Broadcast("ToggleSortMenuMovement")
					end
				end
			end
		end
	end,

	-- a hackish solution to prevent users from button-spamming and breaking input :O
	SwitchFocusToSongsMessageCommand=function(self)
		self:sleep(TransitionTime):queuecommand("EnableInput")
	end,
	SwitchFocusToGroupsMessageCommand=function(self)
		self:sleep(TransitionTime):queuecommand("EnableInput")
	end,
	SwitchFocusToSingleSongMessageCommand=function(self)
		self:sleep(TransitionTime):queuecommand("EnableInput")
	end,
	EnableInputCommand=function(self)
		Input.Enabled = true
	end,
	
	-- #Wheels. Define how many items exist in the wheel here and how many songs it's offset by/the X/Y positioning btw.
	SongWheel:create_actors( "SongWheel", IsUsingWideScreen() and 14 or 19, song_mt, IsUsingWideScreen() and 0 or 160, songwheel_y_offset, IsUsingWideScreen() and 6 or 10),
	GroupWheel:create_actors( "GroupWheel", IsUsingWideScreen() and row.how_many * col.how_many or 19, group_mt, IsUsingWideScreen() and 0 or 160, IsUsingWideScreen() and 0 or -98),
	
	-- The highlight for the current song/group
	LoadActor("./WheelHighlight.lua"),
	-- Graphical Banner
	LoadActor("./banner.lua"),
	-- Song info like artist, bpm, and song length.
	LoadActor("./songDescription.lua"),
	LoadActor("./playerModifiers.lua"),
	-- The profile pane that shows things like songs played set, average bpm/diff/etc
	LoadActor("./ProfileDisplay/default.lua"),
	-- number of steps, jumps, holds, etc., and high scores associated with the current stepchart
	LoadActor("./PaneDisplay.lua"),
	-- this includes the stepartist boxes and the PaneDisplays (number of steps, jumps, holds, etc.)
	LoadActor("./PerPlayer/Under.lua"),
	-- elements we need two of that draw over the StepsDisplayList (just the bouncing cursors, really)
	LoadActor("./PerPlayer/Over.lua"),
	-- grid of Difficulty Blocks (normal) or CourseContentsList (CourseMode)
	LoadActor("./StepsDisplayList/default.lua"),
	-- The GrooveStats leaderboard that can (maybe) be accessed from the SortMenu
	-- This is only added in "dance" mode and if the service is available.
	LoadActor("./Leaderboard.lua"),
	-- included, but unused for now
	LoadActor("./GroupWheelShared.lua", {row, col, group_info}),
	-- Sort and Filter menu wow
	LoadActor("./SortMenu/default.lua"),
	-- a Test Input overlay can be accessed from the SortMenu
	LoadActor("./TestInput.lua"),
	-- Handles song search data
	LoadActor("./SongSearch.lua"),
	-- For backing out of SSMDD.
	LoadActor('./EscapeFromEventMode.lua'),
	-- For transitioning to either gameplay or player options.
	LoadActor('./OptionsMessage.lua'),
}

return t