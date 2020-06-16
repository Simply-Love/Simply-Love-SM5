-- two arguments can be passed in as key/value pairs: noteskin_name and column
--    noteskin_name is a string that matches some available NoteSkin for the current game
--    column is an (optional) string for the column you want returned, like "Left" or "DownRight"
--
-- if no errors are encountered, a full NoteSkin actor is returned
-- otherwise, a generic Def.Actor is returned
-- in both these cases, the Name of the returned actor will be ("NoteSkin_"..noteskin_name)

local args = ...
local noteskin_name = args.noteskin_name or ""

-- prepare a dummy Actor using the name of NoteSkin in case errors are
-- encountered so that a valid (inert, not-drawing) actor still gets returned
local dummy = Def.Actor{
	Name="NoteSkin_"..(noteskin_name or "")
}
-- perform first check: does the NoteSkin exist for the current game?
if not NOTESKIN:DoesNoteSkinExist(noteskin_name) then return dummy end

local game_name = GAMESTATE:GetCurrentGame():GetName()
local fallback_column = { dance="Up", pump="UpRight", techno="Up", kb7="Key1" }

-- prefer the value for column if one was passed in, otherwise use a fallback value
local column = args.column or fallback_column[game_name] or "Up"

-- most NoteSkins are free of errors, but we cannot assume they all are
-- one error in one NoteSkin is enough to halt ScreenPlayerOptions overlay
-- so, use pcall() to catch errors.  The first argument is the function we
-- want to check for runtime errors, and the remaining arguments are what
-- we would have passed to that function.
--
-- Using pcall() like this returns [multiple] values.  A boolean indicating that the
-- function is error-free (true) or that errors were caught (false), and then whatever
-- calling that function would have normally returned
local okay, noteskin_actor = pcall(NOTESKIN.LoadActorForNoteSkin, NOTESKIN, column, "Tap Note", noteskin_name)

-- if no errors were caught and we have a NoteSkin actor from NOTESKIN:LoadActorForNoteSkin()
if okay and noteskin_actor then
	-- If we've made it this far, the screen will function without halting, but there
	-- may still be Lua errors in the NoteSkin's InitCommand that might cause the actor
	-- to display strangely (because Lua halted and sizing/positioning/etc. never happened).
	--
	-- There is some version of an "smx" NoteSkin that got passed around the community
	-- that attempts to use a nil constant "FIXUP" in its InitCommand like this:
	--      InitCommand=function(self) FIXUP end,
	--
	-- FIXUP evaluates to nil when the NoteSkin's InitCommand is called, an error is thrown,
	-- and the ActorProxy in Simply Love's ScreenPlayerOptions overlay remains visible
	-- because execution didn't make it to visible(false)
	--
	-- That's a legitimate Lua error.  But this is tricky, because when we use pcall like
	--      okay = pcall(noteskin_actor.InitCommand, noteskin_actor)
	-- the noteskin_actor passed as an argument to its own InitCommand() will be a Lua table,
	-- rather than an SM actor, and trying to use ANY actor method will throw a nil error.
	--
	-- So correct code like:
	--      	InitCommand=function(self) self:x(100) end
	-- will also throw an error because x() isn't an available method of self, which is, in
	-- this pcall context, a generic Lua table.
	--
	-- Ideally, I'd like to report NoteSkin errors, but reporting false positives when
	-- a NoteSkin's Lua is actually fine (e.g. "midi-solo" that ships with SM5) isn't good.
	--
	-- ...so for now, let's try wiping out this preview NoteSkin's InitCommand so it can't
	-- contain any programmer errors or come back as a false postive because I'm incompetent.
	--
	-- To be clear, this doesn't modify the NoteSkins files, so a NoteSkin with actual errors
	-- will still have those errors during ScreenGameplay.  But, this is a means of showing
	-- players preview of NoteSkins (ScreenPlayerOptions, ScreenEvaluation, etc.) more consistently.
	if noteskin_actor.InitCommand then
		noteskin_actor.InitCommand = nil
	end

	return noteskin_actor..{
		Name="NoteSkin_"..noteskin_name,
		InitCommand=function(self) self:visible(false) end
	}
end

-- if the user has ShowThemeErrors enabled, let them know about the Lua errors.
lua.ReportScriptError( THEME:GetString("ScreenPlayerOptions", "NoteSkinErrors"):format(noteskin_name) )

return dummy
