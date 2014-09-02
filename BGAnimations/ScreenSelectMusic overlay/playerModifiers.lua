-- This file is necessary to apply Speed Mods and Mini from profile(s).
-- These are normally applied in ScreenPlayerOptions, but there is the
-- possibility a player will not visit that screen, expecting mods to already
-- be set from a previous game.

return Def.ActorFrame{
	OnCommand=cmd(queuecommand,"ApplyModifiers"),
	PlayerJoinedMessageCommand=cmd(queuecommand,"ApplyModifiers"),
	ApplyModifiersCommand=function(self)
		-- there is the possibility a player just joined via latejoin
		-- so ensure that this is set correctly now
		if #GAMESTATE:GetHumanPlayers() > 1 then
			SL.Global.Gamestate.Style = "versus"
		end

		local Players = GAMESTATE:GetHumanPlayers()
		for pn in ivalues(Players) do
			ApplySpeedMod(pn)
			ApplyMini(pn)
		end
	end
}