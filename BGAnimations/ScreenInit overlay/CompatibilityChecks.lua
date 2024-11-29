-- ScreenInit is the first screen to load, as defined in Metrics.ini under [Common]
--
-- we want to ensure that the current game (dance, pump, techno, kb7, etc.)
-- is actually supported by Simply Love and won't cause Lua errors that could result
-- in players getting stuck within the theme.
--
-- If the player is in the operator menu and tries to switch to, say, kickbox
-- the engine will change the game, the theme will reload, this screen will load,
-- we'll detect that kickbox isn't supported, and bounce them right back to choosing a different game.
--
-- The same thing basically happens if StepMania starts up in an unsupported game
-- or if the player switches into Simply Love from another theme in an unsupported game.

return Def.Actor{
	OnCommand=function()

		-- defined in ./Scripts/SL-Helpers.lua
		if not StepManiaVersionIsSupported() then
			SM( THEME:GetString("ScreenInit", "UnsupportedSMVersion"):format(ProductFamily(), ProductVersion(), MinimumVersionString()) )
			-- ScreenSystemOptions is the first choice in the operator menu
			-- players can set their game, theme, default NoteSkin, etc. from it
			SCREENMAN:SetNewScreen("ScreenSystemOptions")
		end

		-- also defined in ./Scripts/SL-Helpers.lua
		if not CurrentGameIsSupported() then
			-- Display a SystemMessage alerting the player that their current game is not playable in SL.
			-- We can display a SystemMessage here and it will persist into ScreenSelectGame, because SystemMessages
			-- are part of the always-present ScreenSystemLayer overlay.
			SM( THEME:GetString("ScreenInit", "UnsupportedGame"):format(GAMESTATE:GetCurrentGame():GetName()) )
			-- don't politely transition from ScreenInit to ScreenSystemOptions with fades; just get the player there now
			SCREENMAN:SetNewScreen("ScreenSystemOptions")
		end

		-- Simply Thonk relies heavily on ActorFrameTextures, and SM5's D3D VideoRenderer does not support
		-- render-to-texture.  Thonk mode in D3D is currently broken (read: blinding) enough that it merits
		-- a photosensitive epilepsy warning, so if SM5 starts up in this configuration, redirect to
		-- Simply Love Options, and tell the player to pick a different VisualStyle or change their VideoRenderer.
		if ThemePrefs.Get("VisualStyle") == "Thonk" and not SupportsRenderToTexture() then
			SM( THEME:GetString("ScreenThemeOptions", "ThonkRequiresRenderToTexture") )
			SCREENMAN:SetNewScreen("ScreenThemeOptions")
		end
	end
}
