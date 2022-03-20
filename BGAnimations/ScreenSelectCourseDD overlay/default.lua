---------------------------------------------------------------------------
-- do as much setup work as possible in another file to keep default.lua
-- from becoming overly cluttered

local setup = LoadActor("./Setup.lua")
local ChartUpdater = LoadActor("./UpdateChart.lua")
local LeavingScreenSelectMusicDD = false

ChartUpdater.UpdateCharts()

if setup == nil then
	return LoadActor(THEME:GetPathB("ScreenSelectCourseDD", "overlay/NoValidCourses.lua"))
end

local steps_type = setup.steps_type
local Groups = setup.Groups
local group_index = setup.group_index
local group_info = setup.group_info

local GroupWheel = setmetatable({}, sick_wheel_mt)
local CourseWheel = setmetatable({}, sick_wheel_mt)

local row = setup.row
local col = setup.col

TransitionTime = 0.3
local songwheel_y_offset = 16

---------------------------------------------------------------------------
-- a table of params from this file that we pass into the InputHandler file
-- so that the code there can work with them easily
local params_for_input = { GroupWheel=GroupWheel, CourseWheel=CourseWheel }

---------------------------------------------------------------------------
-- load the InputHandler and pass it the table of params
local Input = LoadActor( "./Input.lua", params_for_input )

-- metatables
local group_mt = LoadActor("./GroupMT.lua", {GroupWheel,CourseWheel,TransitionTime,steps_type,row,col,Input,setup.PruneCoursesFromGroup,Groups[group_index]})
local course_mt = LoadActor("./CourseMT.lua", {CourseWheel,TransitionTime,row,col})

---------------------------------------------------------------------------

local CloseCurrentFolder = function()
	-- if focus is already on the GroupWheel, we don't need to do anything more
	if Input.WheelWithFocus == GroupWheel then 
	NameOfGroup = ""
	return end

	MESSAGEMAN:Broadcast("SwitchFocusToGroups")
	Input.WheelWithFocus.container:playcommand("Hide")
	Input.WheelWithFocus = GroupWheel
	Input.WheelWithFocus.container:playcommand("Unhide")
	
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
						if Input.WheelWithFocus == CourseWheel then
							SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
							MESSAGEMAN:Broadcast("CloseCurrentFolder")
							CloseCurrentFolder()
						end
					end
					if params.Name == "SortList" or params.Name == "SortList2" then
						local P1Enabled = GAMESTATE:IsPlayerEnabled(0)
						local P2Enabled = GAMESTATE:IsPlayerEnabled(1)
						local OpenSort = false
						
						if params.PlayerNumber == 'PlayerNumber_P1' and P1Enabled == true then
							OpenSort = true
						elseif params.PlayerNumber == 'PlayerNumber_P2' and P2Enabled == true then
							OpenSort = true
						end
						
						if OpenSort then
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
	SwitchFocusToCoursesMessageCommand=function(self)
		self:sleep(TransitionTime):queuecommand("EnableInput")
	end,
	SwitchFocusToGroupsMessageCommand=function(self)
		self:sleep(TransitionTime):queuecommand("EnableInput")
	end,
	SwitchFocusToCoursesMessageCommand=function(self)
		self:playcommand("DisableInput"):sleep(TransitionTime):queuecommand("EnableInput")
	end,
	CloseCurrentFolderMessageCommand=function(self)
		self:playcommand("DisableInput"):sleep(TransitionTime):queuecommand("EnableInput")
	end,
	EnableInputCommand=function(self)
		Input.Enabled = true
	end,
	DisableInputCommand=function(self)
		Input.Enabled = false
	end,
	
	-- #Wheels. Define how many items exist in the wheel here and how many songs it's offset by/the X/Y positioning btw.
	CourseWheel:create_actors( "CourseWheel", IsUsingWideScreen() and 19, course_mt, IsUsingWideScreen() and (164 - SCREEN_CENTER_X) - 5 or 160, songwheel_y_offset, IsUsingWideScreen() and 6 or 10),
	GroupWheel:create_actors( "GroupWheel", IsUsingWideScreen() and 19, group_mt, IsUsingWideScreen() and (164 - SCREEN_CENTER_X) - 5 or 160, IsUsingWideScreen() and -47 or -98),
	
	-- The highlight for the current song/group
	LoadActor("./WheelHighlight.lua"),
	-- Graphical Banner
	LoadActor("./banner.lua"),
	LoadActor("./footer.lua"),
	-- Song info like artist, bpm, and song length.
	LoadActor("./songDescription.lua"),
	LoadActor("./playerModifiers.lua"),
	-- number of steps, jumps, holds, etc., and high scores associated with the current stepchart
	LoadActor("./PaneDisplay.lua"),
	-- CourseContentsList
	LoadActor("./CourseContentsList.lua"),
	-- This is only added in "dance" mode and if the service is available.
	LoadActor("./Leaderboard.lua"),
	-- included, but unused for now
	LoadActor("./GroupWheelShared.lua", {row, col, group_info}),
	-- Sort and Filter menu wow
	LoadActor("./SortMenu/default.lua"),
	-- a Test Input overlay can be accessed from the SortMenu
	LoadActor("./TestInput.lua"),
	-- For backing out of SSMDD.
	LoadActor('./EscapeFromEventMode.lua'),
	-- For transitioning to either gameplay or player options.
	LoadActor('./OptionsMessage.lua'),
}

return t