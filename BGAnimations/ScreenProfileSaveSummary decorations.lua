-- FIXME: Player mods stored in SL[pn].ActiveModifiers get saved to profile in "Simply Love UserPrefs.ini"
-- and are automatically applied via ApplyMods() near the bottom of ./Scripts/SL-PlayerOptions.lua
--
-- Mods like Dizzy, Beat, Confusion, Flip, etc. are engine-side.  They are technically
-- saved in the profile's Stats.xml as modifiers used during a song, but the <DefaultModifiers>
-- tag is what really matters, and I don't know how to access/read from/write to it from a theme.
--
-- Some players have specifically requested that this be fixed/added, noting that Dizzy actually
-- helps them keep distinct columns of arrows mentally separated.  It would be nice to help such
-- people and not force them to visit ScreenPlayerOptions each new game cycle if they are using a profile.

local af = LoadActor(THEME:GetPathB("ScreenProfileSave", "decorations"))

af[#af+1] = Def.Actor{
	OnCommand=function(self)
		PROFILEMAN:SaveMachineProfile()
		self:queuecommand("Load")
	end,
	LoadCommand=function()
		SCREENMAN:GetTopScreen():Continue()
	end
}

return af