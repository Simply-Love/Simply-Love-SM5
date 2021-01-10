local af = Def.ActorFrame{
	-- GameplayReloadCheck is a kludgy global variable used in ScreenGameplay in.lua to check
	-- if ScreenGameplay is being entered "properly" or being reloaded by a scripted mod-chart.
	-- If we're here in SelectMusic, set GameplayReloadCheck to false, signifying that the next
	-- time ScreenGameplay loads, it should have a properly animated entrance.
	InitCommand=function(self) SL.Global.GameplayReloadCheck = false end,

	-- ---------------------------------------------------
	--  first, load files that contain no visual elements, just code that needs to run

	-- MenuTimer code for preserving SSM's timer value when going
	-- from SSM to Player Options and then back to SSM
	LoadActor("./PreserveMenuTimer.lua"),
	-- Apply player modifiers from profile
	LoadActor("./PlayerModifiers.lua"),

	-- ---------------------------------------------------
	-- next, load visual elements; the order of these matters
	-- i.e. content in PerPlayer/Over needs to draw on top of content from PerPlayer/Under

	-- make the MusicWheel appear to cascade down; this should draw underneath P2's PaneDisplay
	LoadActor("./MusicWheelAnimation.lua"),

	-- elements we need two of (one for each player) that draw underneath the StepsDisplayList
	-- this includes the stepartist boxes and the PaneDisplays (number of steps, jumps, holds, etc.)
	LoadActor("./PerPlayer/Under.lua"),
	-- grid of Difficulty Blocks (normal) or CourseContentsList (CourseMode)
	LoadActor("./StepsDisplayList/default.lua"),
	-- elements we need two of that draw over the StepsDisplayList (just the bouncing cursors, really)
	LoadActor("./PerPlayer/Over.lua"),

	-- Banner Art
	LoadActor("./Banner.lua"),
	-- Song's Musical Artist, BPM, Duration
	LoadActor("./SongDescription/SongDescription.lua"),

	-- ---------------------------------------------------
	-- finally, load the overlay used for sorting the MusicWheel (and more), hidden by default
	LoadActor("./SortMenu/default.lua"),
	-- a Test Input overlay can (maybe) be accessed from the SortMenu
	LoadActor("./TestInput.lua"),
	-- a yes/no prompt overlay for backing out of SelectMusic when in EventMode can be
	-- activated via "CodeEscapeFromEventMode" under [ScreenSelectMusic] in Metrics.ini
	LoadActor("./EscapeFromEventMode.lua"),
}

return af