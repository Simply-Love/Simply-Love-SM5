
local t = Def.ActorFrame {
	-- Graphical Banner
	LoadActor("./banner.lua"),
	-- Song info like artist, bpm, and song length.
	LoadActor("./songDescription.lua"),
	LoadActor("./playerModifiers.lua"),
	-- number of steps, jumps, holds, etc., and high scores associated with the current stepchart
	LoadActor("./PaneDisplay.lua"),
	-- elements we need two of that draw over the StepsDisplayList (just the bouncing cursors, really)
	LoadActor("./PerPlayer/Over.lua"),
	-- grid of Difficulty Blocks (normal) or CourseContentsList (CourseMode)
	LoadActor("./StepsDisplayList/default.lua"),
}

return t