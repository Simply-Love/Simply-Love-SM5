-- Simply Thonk needs render-to-texture, and render-to-texture doesn't work with SM5's D3D implementation
local ThonkAndRTTOkay = function()
	if ThemePrefs.Get("VisualTheme") == "Thonk" and not SupportsRenderToTexture() then
		SM( THEME:GetString("ScreenThemeOptions", "ThonkRequiresRenderToTexture") )
		return false
	end
	return true
end

local InputHandler = function(event)
	if not event then return false end
	if event.type == "InputEventType_FirstPress" and event.GameButton == "Back" then
		 if ThonkAndRTTOkay() and CurrentGameIsSupported() then
			 SCREENMAN:GetTopScreen():Cancel()
		 end
	end
	return false
end

return Def.Actor{
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( InputHandler ) end,
	BeginCommand=function(self)
		-- we might have just backed out of ScreenThemeOptions ("Simply Love Options")
		-- in which case we'll want to call ThemePrefs.Save() now
		ThemePrefs.Save()

		-- but, we might have also just backed out of ScreenSelectGame ("System Options")
		-- where we might have just changed the language, in which case the ThemePrefsRows table
		-- needs to update its text to use that language.
		SL_CustomPrefs.Init()

		-- Aside: the engine does not broadcast anything when SM5's language is changed via ConfOption
		--        and the engine does not expose any methods for setting the language directly using Lua.

		-- Broadcast a message for "./BGAnimations/_shared background/" to listen for in case VisualTheme has changed.
		-- This compensates for ThemePrefsRows' current lack of support for ExportOnChange() and SaveSelections().
		MESSAGEMAN:Broadcast("BackgroundImageChanged")
	end,

	-- OffCommand() will be called if the player tries to leave the operator menu by choosing an OptionRow
	-- it will not be called if the player presses the "Back" MenuButton (typically Esc on a keyboard),
	-- so we handle that case using a Lua InputCallback function
	OffCommand=function(self)
		if SCREENMAN:GetTopScreen():AllAreOnLastRow() then
			if not ThonkAndRTTOkay() then
				SCREENMAN:SetNewScreen("ScreenOptionsService")
			end

			if not CurrentGameIsSupported() then
				SM( THEME:GetString("ScreenInit", "UnsupportedGame"):format(GAMESTATE:GetCurrentGame():GetName()) )
				SCREENMAN:SetNewScreen("ScreenSelectGame")
			end

			if not StepManiaVersionIsSupported() then
				SM( THEME:GetString("ScreenInit", "UnsupportedSMVersion"):format(ProductVersion()) )
				SCREENMAN:SetNewScreen("ScreenSelectGame")
			end
		end
	end
}