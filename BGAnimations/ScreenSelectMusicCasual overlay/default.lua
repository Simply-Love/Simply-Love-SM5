-- because no one wants "Invalid PlayMode 7"
GAMESTATE:SetCurrentPlayMode(0)

---------------------------------------------------------------------------
-- a steps_type like "StepsType_Dance_Single" is needed so we can filter out steps that aren't suitable
-- there has got to be a better way to do this...
local steps_type = "StepsType_"..GAMESTATE:GetCurrentGame():GetName():gsub("^%l", string.upper).."_"
if GAMESTATE:GetCurrentStyle():GetName() == "double" then
	steps_type = steps_type .. "Double"
else
	steps_type = steps_type .. "Single"
end

---------------------------------------------------------------------------
-- variables local to this file
local margin = {
	w = -WideScale(54,72),
	h = -30
}

local numCols = 3
local numRows = 5

-- simple option definitions
local OptionRows = LoadActor("./OptionRows.lua")

local Players = GAMESTATE:GetHumanPlayers()

---------------------------------------------------------------------------

-- variables that are to be passed between files
local GroupWheel = setmetatable({}, sick_wheel_mt)
local SongWheel = setmetatable({}, sick_wheel_mt)
local OptionsWheel = {}

for player in ivalues(Players) do
	-- create the options wheel for this player
	OptionsWheel[player] = setmetatable({disable_wrapping = true}, sick_wheel_mt)

	for i=1,#OptionRows do
		OptionsWheel[player][i] = setmetatable({}, sick_wheel_mt)
	end
end

local TransitionTime = 0.5

local col = {
	how_many = numCols,
	w = (_screen.w/numCols) + margin.w,
}
local row = {
	how_many = numRows,
	h = ((_screen.h + (margin.h*(numRows-2))) / (numRows-2)),
}

---------------------------------------------------------------------------
-- a table of params from this file that we pass into the InputHandler file
-- so that the code there can work with them easily
local params = { GroupWheel=GroupWheel, SongWheel=SongWheel, OptionsWheel=OptionsWheel, OptionRows=OptionRows }

---------------------------------------------------------------------------

-- metatables
local group_mt = LoadActor("./GroupMT.lua", {GroupWheel,SongWheel,TransitionTime,steps_type,row,col})
local song_mt = LoadActor("./SongMT.lua", {SongWheel,TransitionTime,row,col})
local optionrow_mt = LoadActor("./OptionRowMT.lua")
local optionrow_item_mt = LoadActor("./OptionRowItemMT.lua")

-- load the InputHandler and pass it the table of params
local Input = LoadActor( "./Input.lua", params )

-- Input, declared here so it has file-scope
-- local Input = setmetatable({}, inputhandler_mt)
---------------------------------------------------------------------------

local t = Def.ActorFrame {
	InitCommand=function(self)
		GroupWheel.ActiveRow = 2
		SongWheel.ActiveRow = 2

		-- prune out packs that have no valid steps
		local Groups = {}
		for group in ivalues(SONGMAN:GetSongGroupNames()) do
			for song in ivalues(SONGMAN:GetSongsInGroup(group)) do
				if song:HasStepsType(steps_type) then
					Groups[#Groups+1] = group
					break
				end
			end
		end

		GroupWheel:set_info_set(Groups, 1)
		self:queuecommand("Capture")
	end,
	CaptureCommand=function(self)

		-- One element of the table returned above is an internal function, handler
		SCREENMAN:GetTopScreen():AddInputCallback( Input.Handler )

		-- set up initial variable states and the players' OptionRows
		Input:Init()

		-- It should be safe to enable input for players now
		self:queuecommand("EnableInput")
	end,
	CodeMessageCommand=function(self, params)
		if params.Name == "Exit" then
			if PREFSMAN:GetPreference("EventMode") then
				SCREENMAN:GetTopScreen():SetNextScreenName( Branch.SSMCancel() ):StartTransitioningScreen("SM_GoToNextScreen")
			else
				if SL.Global.Stages.PlayedThisGame == 0 then
					SL.Global.GameMode = "Competitive"
					SetGameModePreferences()
					THEME:ReloadMetrics()
					SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSSM"):StartTransitioningScreen("SM_GoToNextScreen")
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

		local steps = SongUtil.GetPlayableSteps( GAMESTATE:GetCurrentSong() )
		OptionRows[1].choices = steps

		for pn in ivalues(Players) do
			OptionsWheel[pn]:set_info_set( OptionRows, 1)

			for i=1,#OptionRows do
				OptionsWheel[pn][i]:set_info_set( OptionRows[i].choices, 1)
			end
		end

		self:sleep(TransitionTime):queuecommand("EnableInput")
	end,
	EnableInputCommand=function(self)
		Input.Enabled = true
	end,


	Def.Quad{
		Name="SongWheelBackground",
		InitCommand=cmd(zoomto, _screen.w, _screen.h/(row.how_many-2); diffuse, Color.Black; diffusealpha,0),
		OnCommand=cmd(xy, _screen.cx, math.ceil((row.how_many-2)/2) * row.h + 10),
		SwitchFocusToSongsMessageCommand=cmd(sleep,0.3; linear,0.1; diffusealpha,0.4),
		SwitchFocusToGroupsMessageCommand=cmd(sleep,0.3; linear,0.1; diffusealpha,0),
		SwitchFocusToSingleSongMessageCommand=cmd(sleep,0.3; linear,0.1; diffusealpha,0),
	},


	LoadActor("PlayerOptionsShared", {row, col}),

	SongWheel:create_actors( "SongWheel", row.how_many * col.how_many, song_mt, 0, 0),

	-- SongHeader needs to be over the SongWheel but under the GroupWheel
	LoadActor("./SongHeader.lua", row),

	GroupWheel:create_actors( "GroupWheel", row.how_many * col.how_many, group_mt, 0, 0),

	-- we want the GroupHeader drawn over the GroupWheel so that Group folder scroll underneath it
	LoadActor("./GroupHeader.lua", row),

	StandardDecorationFromFile( "Footer", "footer" ),
}

-- Add player options ActorFrames to our primary ActorFrame
for pn in ivalues(Players) do
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

t[#t+1] = LoadActor("./StartButton.lua")

return t