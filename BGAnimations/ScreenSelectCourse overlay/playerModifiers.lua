for player in ivalues(GAMESTATE:GetHumanPlayers()) do

	local pn = ToEnumShortString(player)

	if SL[pn].PlayerOptionsString then
		-- SL[pn].PlayerOptionsString is set in ScreenGameplay in.lua
		-- Each ScreenGameplay in, we store the current PlayerOptions (from the engine) there as a string.
		--
		-- Here, in ScreenSelectMusicDD, we compare the engine's sense of PlayerOptions against that previously
		-- stored in SL[pn].PlayerOptionsString.  If they don't match, we assume that the engine's
		-- sense of PlayerOptions was modified during the last ScreenGameplay by ITG mods via ApplyGameCommands()
		--
		-- If so, we don't want those mods to persist into the next ScreenGameplay, so if the engine's notion of PlayerOptions
		-- doesn't mach theme's notion of PlayerOptions, reset the engine to match the theme.
		if SL[pn].PlayerOptionsString ~= GAMESTATE:GetPlayerState(player):GetPlayerOptionsString("ModsLevel_Preferred") then
			GAMESTATE:GetPlayerState(player):SetPlayerOptions("ModsLevel_Preferred", SL[pn].PlayerOptionsString)

			-- ensure that FailSetting is maintained according to whatever the machine operator set in Advanced Options
			GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred"):FailSetting( GetDefaultFailType() )
		end
	end
end

-- ---------------------------------------------

local PlayerThatLateJoined = nil

return Def.Actor{
	PlayerJoinedMessageCommand=function(self, params)
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