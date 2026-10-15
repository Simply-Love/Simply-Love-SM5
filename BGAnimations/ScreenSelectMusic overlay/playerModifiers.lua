for player in ivalues(GAMESTATE:GetHumanPlayers()) do

	local pn = ToEnumShortString(player)
	local key = SL[pn].PlayerOptionsStringKey or "PlayerOptionsString"

	if SL[pn][key] then
		-- SL[pn].PlayerOptionsString is set in ScreenGameplay in.lua
		-- Each ScreenGameplay in, we store the current PlayerOptions (from the engine) there as a string.
		--
		-- Here, in ScreenSelectMusic, we compare the engine's sense of PlayerOptions against that previously
		-- stored in SL[pn].PlayerOptionsString.  If they don't match, we assume that the engine's
		-- sense of PlayerOptions was modified during the last ScreenGameplay by ITG mods via ApplyGameCommands()
		--
		-- If so, we don't want those mods to persist into the next ScreenGameplay, so if the engine's notion of PlayerOptions
		-- doesn't match theme's notion of PlayerOptions, reset the engine to match the theme.
		if SL[pn][key] ~= GAMESTATE:GetPlayerState(player):GetPlayerOptionsString("ModsLevel_Preferred") then
			GAMESTATE:GetPlayerState(player):SetPlayerOptions("ModsLevel_Preferred", SL[pn][key])

			-- ensure that FailSetting is maintained according to whatever the machine operator set in Advanced Options
			GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred"):FailSetting( GetDefaultFailType() )
		end
	end
end

-- AutoSetStyle restores the selected chart in OnCommand. Apply its preferences
-- after that temporary music-wheel style change has finished.
return Def.Actor{
	CurrentStyleChangedMessageCommand=function(self) self:queuecommand("Apply") end,
	OnCommand=function(self) self:queuecommand("Apply") end,
	ApplyCommand=function(self)
		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			local pn = ToEnumShortString(player)
			local state = GAMESTATE:GetPlayerState(player)
			local key = GetPlayerOptionsStringKey(player)
			-- Profile loading applies the original base preferences first.
			local previous_key = SL[pn].PlayerOptionsStringKey or "PlayerOptionsString"
			SL[pn].PlayerOptionsStringKey = key
			if key ~= previous_key then
				SL[pn][previous_key] = state:GetPlayerOptionsString("ModsLevel_Preferred")
				local options = SL[pn][key] or SL[pn].PlayerOptionsString or SL[pn][previous_key]
				state:SetPlayerOptions("ModsLevel_Preferred", options)
				local po = state:GetPlayerOptions("ModsLevel_Preferred")
				po:ResetDisabledTimingWindows()
				po:FailSetting(GetDefaultFailType())

				-- Keep the option rows consistent with the incoming style, so a
				-- later ApplyMods call cannot reapply the outgoing style's values.
				local mods = SL[pn].ActiveModifiers
				if po:CMod() then
					mods.SpeedModType, mods.SpeedMod = "C", po:CMod()
				elseif po:MMod() then
					mods.SpeedModType, mods.SpeedMod = "M", po:MMod()
				else
					mods.SpeedModType, mods.SpeedMod = "X", po:XMod()
				end
				mods.Mini = ("%g%%"):format(po:Mini()*100)
				mods.VisualDelay = ("%gms"):format(po:VisualDelay()*1000)
				mods.HideTargets = po:Dark() > 0
				mods.HideSongBG = po:Cover() > 0
				mods.NoteSkin, mods.NoteSkinVariant = po:NoteSkin(), nil
				if NOTESKIN:IsNoteSkinVariant(mods.NoteSkin) then
					mods.NoteSkinVariant = mods.NoteSkin
					for noteskin in ivalues(NOTESKIN:GetNoteSkinNames(false)) do
						if FindInTable(mods.NoteSkinVariant, NOTESKIN:GetVariantNamesForNoteSkin(noteskin)) then
							mods.NoteSkin = noteskin
							break
						end
					end
				end
				SL[pn][key] = state:GetPlayerOptionsString("ModsLevel_Preferred")
			end
		end
	end
}
