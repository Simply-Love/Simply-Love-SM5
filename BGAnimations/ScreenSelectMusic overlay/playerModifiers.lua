-- This file is necessary to apply Speed Mods and Mini from profile(s).
-- These are normally applied in ScreenPlayerOptions, but there is the
-- possibility a player will not visit that screen, expecting mods to already
-- be set from a previous game.

return Def.Actor{
	OnCommand=cmd(queuecommand,"ApplyModifiers"),
	PlayerJoinedMessageCommand=cmd(queuecommand,"ApplyModifiers"),
	ApplyModifiersCommand=function(self)

		local Players = GAMESTATE:GetHumanPlayers()

		-- there is the possibility a player just joined via latejoin
		-- so ensure that this is set correctly now
		if #Players > 1 then
			SL.Global.Gamestate.Style = "versus"
		end

		for player in ivalues(Players) do

			-- see: ./Scripts/SL-PlayerOptions.lua
			ApplyMods(player)

			local pn = ToEnumShortString(player)

			-- On first load of ScreenSelectMusic, PlayerOptions will be nil
			-- So don't bother trying to use it to reset PlayerOptions
			if SL[pn].CurrentPlayerOptions.String then
				if SL[pn].CurrentPlayerOptions.String ~= GAMESTATE:GetPlayerState(player):GetPlayerOptionsString("ModsLevel_Preferred") then
					GAMESTATE:GetPlayerState(player):SetPlayerOptions("ModsLevel_Preferred", SL[pn].CurrentPlayerOptions.String)
				end
			end
		end
	end
}