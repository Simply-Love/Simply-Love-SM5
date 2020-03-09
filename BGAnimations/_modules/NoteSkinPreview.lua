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
	Name="NoteSkin_"..(noteskin_name or ""),
	InitCommand=function(self) self:visible(false) end
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
	-- that attempts to use a nil constant "FIXUP" in its InitCommand that exhibits this.
	-- So, pcall() again, now specifically on the noteskin_actor's InitCommand if it has one.
	if noteskin_actor.InitCommand then
		okay = pcall(noteskin_actor.InitCommand, noteskin_actor)
	end

	if okay then
		return noteskin_actor..{
			Name="NoteSkin_"..noteskin_name,
			InitCommand=function(self) self:visible(false) end
		}
	end
end

-- if the user has ShowThemeErrors enabled, let them know about the Lua errors.
lua.ReportScriptError( THEME:GetString("ScreenPlayerOptions", "NoteSkinErrors"):format(noteskin_name) )

return dummy
