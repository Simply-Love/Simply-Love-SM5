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

		-- If we're in Casual mode, we want to reduce the number of judgments,
		-- so turn Decents and WayOffs off now.
		if SL.Global.GameMode == "Casual" then
			SL.Global.ActiveModifiers.DecentsWayOffs = "Off"

		elseif SL.Global.GameMode ~= "Casual" and SL.Global.PlayedThisGame == 0 then
			SL.Global.ActiveModifiers.DecentsWayOffs = "On"
		end

		for player in ivalues(Players) do

			local pn = ToEnumShortString(player)

			-- see: ./Scripts/SL-PlayerOptions.lua
			ApplyMods(player)

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