local t = Def.ActorFrame {
	-- Graphical Banner
	LoadActor("./banner.lua"),
	-- Song info like artist, bpm, and song length.
	LoadActor("./songDescription.lua"),
	-- Sets player's preferred mods before going to the next screen.
	LoadActor("./playerModifiers.lua"),
	-- number of steps, jumps, holds, etc., and high scores associated with the current stepchart
	LoadActor("./PaneDisplay.lua"),
	-- Shows which songs/difficulty charts are in the course
	LoadActor("./CourseContentsList.lua"),
}

return t