---------------------------------------------------------------------------
-- do as much setup work as possible in another file to keep default.lua
-- from becoming overly cluttered

local setup = LoadActor("./Setup.lua")
local ChartUpdater = LoadActor("./UpdateChart.lua")

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

local row = setup.row
local col = setup.col

local TransitionTime = 0.3
local songwheel_y_offset = -13

---------------------------------------------------------------------------
-- a table of params from this file that we pass into the InputHandler file
-- so that the code there can work with them easily
local params_for_input = { GroupWheel=GroupWheel, SongWheel=SongWheel }

---------------------------------------------------------------------------
-- load the InputHandler and pass it the table of params
local Input = LoadActor( "./Input.lua", params_for_input )

-- metatables
local group_mt = LoadActor("./GroupMT.lua", {GroupWheel,SongWheel,TransitionTime,steps_type,row,col,Input,setup.PruneSongsFromGroup})
local song_mt = LoadActor("./SongMT.lua", {SongWheel,TransitionTime,row,col})

---------------------------------------------------------------------------

local CloseCurrentFolder = function()
	-- if focus is already on the GroupWheel, we don't need to do anything more
	if Input.WheelWithFocus == GroupWheel then 
	NameOfGroup = GAMESTATE:GetCurrentSong():GetGroupName()
	return end

	GAMESTATE:SetCurrentSong(nil)

	MESSAGEMAN:Broadcast("SwitchFocusToGroups")
	Input.WheelWithFocus.container:queuecommand("Hide")
	Input.WheelWithFocus = GroupWheel
	Input.WheelWithFocus.container:queuecommand("Unhide")
end



local t = Def.ActorFrame {
	InitCommand=function(self)
		GroupWheel:set_info_set(Groups, group_index)
		self:GetChild("GroupWheel"):SetDrawByZPosition(true)

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
	CodeMessageCommand=function(self, params)
		-- I'm using Metrics-based code detection because the engine is already good at handling
		-- simultaneous button presses (CancelSingleSong when ThreeKeyNavigation=1),
		-- as well as long input patterns (Exit from EventMode) and I see no need to
		-- reinvent that functionality for the Lua InputCallback that I'm using otherwise.

		if params.Name == "Exit" then
			if PREFSMAN:GetPreference("EventMode") then
				SCREENMAN:GetTopScreen():SetNextScreenName( Branch.SSMCancel() ):StartTransitioningScreen("SM_GoToNextScreen")
			else
				if SL.Global.Stages.PlayedThisGame == 0 then
					SL.Global.GameMode = "ITG"
					SetGameModePreferences()
					THEME:ReloadMetrics()
					SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSSM"):StartTransitioningScreen("SM_GoToNextScreen")
				end
			end
		end
		if params.Name == "CancelSingleSong" then
			-- otherwise, run the function to cancel this single song choice
			Input.CancelSongChoice()
		end
		if params.Name == "CloseCurrentFolder" then
			if Input.WheelWithFocus == SongWheel then
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
				CloseCurrentFolder()
				MESSAGEMAN:Broadcast("CloseThisFolderHasFocus")
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

	LoadActor("./SongWheelShared.lua", {row, col, songwheel_y_offset}),

	SongWheel:create_actors( "SongWheel", 12, song_mt, 0, songwheel_y_offset),
	
	LoadActor("./WheelHighlight.lua"),

	GroupWheel:create_actors( "GroupWheel", row.how_many * col.how_many, group_mt, 0, 0, true),
	-- Graphical Banner
	LoadActor("./banner.lua"),
	-- Song info like artist, bpm, and song length.
	LoadActor("./songDescription.lua"),
	LoadActor("./playerModifiers.lua"),
	-- this includes the stepartist boxes and the PaneDisplays (number of steps, jumps, holds, etc.)
	LoadActor("./PerPlayer/Under.lua"),
	-- elements we need two of that draw over the StepsDisplayList (just the bouncing cursors, really)
	LoadActor("./PerPlayer/Over.lua"),
	-- grid of Difficulty Blocks (normal) or CourseContentsList (CourseMode)
	LoadActor("./StepsDisplayList/default.lua"),
	-- included, but unused for now
	LoadActor("./GroupWheelShared.lua", {row, col, group_info}),
	-- For transitioning to either gameplay or player options.
	LoadActor('./OptionsMessage.lua'),
}

return t