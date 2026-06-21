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
-- ScreenSelectMusic
-- =======================================================================
Positions.ScreenSelectMusic = {}

-- Banner zoom. Banner art is 418x164; in portrait we shrink it so
-- 418 * zoom fits within the ~270-wide canvas (418 * 0.6 ~= 251).
Positions.ScreenSelectMusic.BannerZoom = function()
	if IsVerticalScreen() then return 0.6 end
	return IsUsingWideScreen() and 0.7655 or 0.75
end

-- Banner center position. Portrait centers it horizontally near the top.
Positions.ScreenSelectMusic.BannerX = function()
	if IsVerticalScreen() then return _screen.cx end
	return _screen.cx - (IsUsingWideScreen() and 170 or 166)
end

Positions.ScreenSelectMusic.BannerY = function()
	if IsVerticalScreen() then return 70 end
	return 96
end

-- SongDescription panel background width. Portrait fits the panel to ~258.
Positions.ScreenSelectMusic.SongDescriptionWidth = function()
	if IsVerticalScreen() then return 258 end
	return IsUsingWideScreen() and 320 or 310
end

-- DensityGraph width. Portrait fits to ~258.
Positions.ScreenSelectMusic.DensityGraphWidth = function()
	if IsVerticalScreen() then return 258 end
	return IsUsingWideScreen() and 286 or 276
end

-- Leaderboard single-player pane width. Portrait reduces to ~258 to fit.
Positions.ScreenSelectMusic.LeaderboardWidth1Player = function()
	if IsVerticalScreen() then return 258 end
	return 330
end

-- =======================================================================
-- ScreenEvaluation
-- =======================================================================
Positions.ScreenEvaluation = {}

-- Per-player horizontal offset for panes / upper content. In portrait we
-- center the active single player at _screen.cx.
Positions.ScreenEvaluation.PaneOffset = function(player)
	if IsVerticalScreen() then return _screen.cx end
	return _screen.cx + (player == PLAYER_2 and 155 or -155)
end

-- Banner zoom on ScreenEvaluation. Banner is 418 wide; portrait shrinks it
-- to fit the ~270-wide canvas (418 * 0.6 ~= 251).
Positions.ScreenEvaluation.BannerZoom = function()
	if IsVerticalScreen() then return 0.6 end
	return 0.7
end
