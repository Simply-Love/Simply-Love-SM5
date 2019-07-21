local t = ...

local game_name = GAMESTATE:GetCurrentGame():GetName()
local column = {
	dance = "Up",
	pump = "UpRight",
	techno = "Up",
	kb7 = "Key1"
}

local GetNoteSkinActor = function(ns)

	-- most NoteSkins are free of errors, but we cannot assume they all are
	-- one error in one NoteSkin is enough to halt ScreenPlayerOptions overlay
	-- so, use pcall() to catch errors.  The first argument is the function we
	-- want to check for runtime errors, and the remaining arguments would we what
	-- we would have passed to that function.
	--
	-- Using pcall() like this returns [multiple] values.  A boolean indicating that the
	-- function is error-free (true) or that errors were caught (false), and then whatever
	-- calling that function would have normally returned
	local okay, noteskin_actor = pcall(NOTESKIN.LoadActorForNoteSkin, NOTESKIN, column[game_name] or "Up", "Tap Note", ns)

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
			okay = pcall(noteskin_actor.InitCommand)
		end

		if okay then
			return noteskin_actor..{
				Name="NoteSkin_"..ns,
				InitCommand=function(self) self:visible(false) end
			}
		end
	end

	-- if the user has ShowThemeErrors enabled, let them know about the Lua errors via SystemMessage
	if PREFSMAN:GetPreference("ShowThemeErrors") then
		SM( Screen.String("NoteSkinErrors"):format(ns) )
	end

	-- return a dummy Actor using the name of NoteSkin that had
	-- errors so that the preview system still finds *something*
	return Def.Actor{
		Name="NoteSkin_"..ns,
		InitCommand=function(self) self:visible(false) end
	}
end

-- Add noteskin actors to the primary AF and hide them immediately.
-- We'll refer to these later via ActorProxy in ./Graphics/OptionRow Frame.lua
for noteskin in ivalues( CustomOptionRow("NoteSkin").Choices ) do
	t[#t+1] = GetNoteSkinActor(noteskin)
end