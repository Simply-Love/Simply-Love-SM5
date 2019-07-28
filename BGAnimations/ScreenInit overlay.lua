-- ScreenInit is the first screen to load, as defined in Metrics.ini under [Common]
--
-- we want to ensure that the current game (dance, pump, techno, kb7, etc.)
-- is actually supported by Simply Love and won't cause Lua errors that could result
-- in players getting stuck within the theme.
--
-- If the player is in the operator menu and tries to switch to, say, kickbox
-- the engine will change the game, the theme will reload, this screen will load
-- and we'll detect that kickbox isn't supported and bounce them right back to choosing a different game.
--
-- The same thing basically happens if StepMania starts up in an unsupported game
-- or if the player switches into Simply Love from another theme in an unsupported game.

return Def.Actor{
	OnCommand=function()
		-- defined in ./Scripts/SL-Helpers.lua
		if not CurrentGameIsSupported() then
			-- don't politely transition from ScreenInit to ScreenSelectGame
			-- just get the player there now
			SCREENMAN:SetNewScreen("ScreenSelectGame")
		end
	end
}