-- -----------------------------------------------------------------------
-- SL-Positions.lua
--
-- Central tuning surface for PORTRAIT (vertical / 9:16) layout overrides.
--
-- Simply Love is designed for landscape displays. Rather than fork every
-- screen, the portrait build branches on IsVerticalScreen() (see
-- Scripts/SL-Helpers.lua) and pulls element positions/sizes from the
-- functions below. Each function returns a PORTRAIT value when the screen is
-- vertical and otherwise returns the exact value mainline Simply Love would
-- have used, so landscape behavior is unchanged and no features are removed.
--
-- This file is the primary place to adjust numbers during the
-- write -> run -> screenshot -> tune iteration loop. Keep all portrait magic
-- numbers here where practical so tuning happens in one place.
--
-- Target reference resolution: 1080x1920 (9:16), single player, dance pad.
-- -----------------------------------------------------------------------

-- Define top level table.
if not Positions then Positions = {} end

-- =======================================================================
-- ScreenGameplay
-- =======================================================================
Positions.ScreenGameplay = {}

-- Notefield horizontal position. In portrait we always center the notefield
-- (single player). In landscape, replicate mainline's metrics.ini values so
-- the default left/right placement is preserved.
Positions.ScreenGameplay.P1SideX = function()
	if IsVerticalScreen() then return _screen.cx end
	return _screen.cx - (clamp(_screen.w, 640, 854) * 0.25)
end

Positions.ScreenGameplay.P2SideX = function()
	if IsVerticalScreen() then return _screen.cx end
	return _screen.cx + (clamp(_screen.w, 640, 854) * 0.25)
end

-- Score (big white number / percentage). In portrait it moves to the top-right
-- and shrinks so it does not collide with the centered notefield.
Positions.ScreenGameplay.ScoreZoom = function()
	if IsVerticalScreen() then return 0.35 end
	return 0.5
end

-- DifficultyMeter (the small colored square with the meter number).
-- Portrait: top-right corner.
Positions.ScreenGameplay.DifficultyMeterX = function(player)
	if IsVerticalScreen() then return _screen.w - 25 end
	-- landscape: mainline places it just outside the notefield, per player
	return _screen.cx + (player == PLAYER_1 and -1 or 1) * SL_WideScale(292.5, 342.5)
end

Positions.ScreenGameplay.DifficultyMeterY = function()
	if IsVerticalScreen() then return 20 end
	return 56
end

-- =======================================================================
-- ScreenSelectMusic  (filled in during the song-select pass)
-- =======================================================================
Positions.ScreenSelectMusic = {}

-- =======================================================================
-- ScreenEvaluation  (filled in during the evaluation pass)
-- =======================================================================
Positions.ScreenEvaluation = {}
