local PlayerThatLateJoined = nil

return Def.Actor{
	OnCommand=function(self)
		for player in ivalues(GAMESTATE:GetHumanPlayers()) do

			local pn = ToEnumShortString(player)

			-- On first load of ScreenSelectMusic, CurrentPlayerOptions.String will be nil
			-- So don't bother trying to use it to reset PlayerOptions
			if SL[pn].CurrentPlayerOptions.String then
				-- SL[pn].CurrentPlayerOptions.String is set in ScreenGameplay in.lua
				-- Each ScreenGameplay in, we store the current PlayerOptions (from the engine) there as a string.
				--
				-- Here, in ScreenSelectMusic, we compare the engine's sense of PlayerOptions against that previously
				-- stored in SL[pn].CurrentPlayerOptions.String.  If they don't match, we assume that the engine's
				-- sense of PlayerOptions was modified during the last ScreenGameplay by ITG mods via ApplyGameCommands()
				--
				-- If so, we don't want those mods to persist into the next ScreenGameplay, so if the engine's notion of PlayerOptions
				-- doesn't mach theme's notion of PlayerOptions, reset the engine to match the theme.
				if SL[pn].CurrentPlayerOptions.String ~= GAMESTATE:GetPlayerState(player):GetPlayerOptionsString("ModsLevel_Preferred") then
					GAMESTATE:GetPlayerState(player):SetPlayerOptions("ModsLevel_Preferred", SL[pn].CurrentPlayerOptions.String)
				end
			end
		end
	end,
	PlayerJoinedMessageCommand=function(self, params)
		-- a player just joined via latejoin...
		-- so ensure that the Theme's sense of CurrentStyle is correct...
		SL.Global.Gamestate.Style = GAMESTATE:GetCurrentStyle():GetName()

		-- ...and queue a command to set that player's modifiers
		-- Queueing is necessary here to give LoadProfileCustom() time to read this player's mods from file
		-- and set the SL[pn].ActiveModifiers table accordingly.  If we call ApplyMods(params.Player) here,
		-- the SL[pn].ActiveModifiers table is still in its default state, and mods won't be set properly.
		PlayerThatLateJoined = params.Player
		self:queuecommand("ApplyMods")
	end,
	ApplyModsCommand=function(self)
		if PlayerThatLateJoined then
			-- ApplyMods() is defined at the bottom of ./Scripts/SL-PlayerOptions.lua
			ApplyMods(PlayerThatLateJoined)
			-- and reset this back to nil... just in case...
			PlayerThatLateJoined = nil
		end
	end
}