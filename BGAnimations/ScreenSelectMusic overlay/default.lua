local t = Def.ActorFrame{
	InitCommand=function(self) SL.Global.GameplayReloadCheck = false end,
	ChangeStepsMessageCommand=function(self, params)
		self:playcommand("StepsHaveChanged", params)
	end,

	-- ---------------------------------------------------
	--  first, load files that contain no visual elements, just code that needs to run

	-- MenuButton code for backing out of SelectMusic when in EventMode
	LoadActor("./EscapeFromEventMode.lua"),
	-- MenuTimer code for preserving SSM's timer value
	LoadActor("./MenuTimer.lua"),
	-- Apply player modifiers from profile
	LoadActor("./PlayerModifiers.lua"),

	-- ---------------------------------------------------
	-- next, load visual elements; the order of the layers matters for most of these

	-- make the MusicWheel appear to cascade down; this should draw underneath P2's PaneDisplay
	LoadActor("./MusicWheelAnimation.lua"),

	-- elements we need two of (one for each player) that draw underneath the StepsDisplayList
	-- this includes the stepartist boxes and the PaneDisplays (number of steps, jumps, holds, etc.)
	LoadActor("./PerPlayer/Under.lua"),
	-- grid of Difficulty Blocks (normal) or CourseContentsList (CourseMode)
	LoadActor("./StepsDisplayList/default.lua"),
	-- elements we need two of that draw over the StepsDisplayList (just the bouncing cursors, really)
	LoadActor("./PerPlayer/Over.lua"),

	-- Graphical Banner
	LoadActor("./Banner.lua"),
	-- Song Artist, BPM, Duration (Referred to in other themes as "PaneDisplay")
	LoadActor("./SongDescription.lua"),

	-- ---------------------------------------------------
	-- finally, load the overlay used for sorting the MusicWheel (and more), hidden by default
	LoadActor("./SortMenu/default.lua"),
	-- a Test Input overlay can (maybe) be accessed from the SortMenu
	LoadActor("./TestInput.lua"),
}

return t