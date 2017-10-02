-- This file is necessary to apply Speed Mods and Mini from profile(s).
-- These are normally applied in ScreenPlayerOptions, but there is the
-- possibility a player will not visit that screen, expecting mods to already
-- be set from a previous game.

return Def.Actor{
	OnCommand=function(self) self:queuecommand("ApplyModifiers") end,
	PlayerJoinedMessageCommand=function(self) self:queuecommand("ApplyModifiers") end,
	ApplyModifiersCommand=function(self)

		local Players = GAMESTATE:GetHumanPlayers()

		-- there is the possibility a player just joined via latejoin
		-- so ensure that this is set correctly now
		if #Players > 1 then
			SL.Global.Gamestate.Style = "versus"
		end

		for player in ivalues(Players) do

			local pn = ToEnumShortString(player)

			-- see: ./Scripts/SL-PlayerOptions.lua
			ApplyMods(player)

			-- On first load of ScreenSelectMusic, PlayerOptions will be nil
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
	end
}