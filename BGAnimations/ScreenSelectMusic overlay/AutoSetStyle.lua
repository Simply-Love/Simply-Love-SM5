-- if Metric.ini's [Common] has AutoSetStyle=true
-- this will allow stepcharts from disparate styles (single, double, routine, halfdouble, etc.)
-- to appear side-by-side in the same MusicWheel.  It's pretty cool.
--
-- But like most things in StepMania, the feature has some UX quirks
-- (probably oversights in the initial implementation that never saw further work)
-- that we'll address here in the theme's Lua.
--
-- The quirk here is that ScreenSelectMusic seems to only present all playable stepcharts
-- the first time it loads.  Let's say there are ten songs, and
--     all 10 of the songs have at least one singles stepchart
--     7 of the songs have at least one doubles stepchart
--     2 of the songs have at least one halfdoubles stepchart
--
-- When ScreenSelectMusic first loads, I'll see all ten songs.
-- If I choose and play a doubles stepchart as my first stage, the MusicWheel will
-- then only show 7 songs when I get back to choose my 2nd song, seemingly because the
-- SM engine now has "double" set as its current style.
-- If I then choose and play a halfdouble stepchart, the MusicWheel will
-- show 2 songs when I return to select my 3rd song. And if I play a singles
-- stepchart, the MusicWheel will return to show all 10 songs.
--
-- My workaround here is to set (or reset) the engine's style to either
-- "single" (if 1 player is joined) or "versus" (if 2 players are joined) every time
-- ScreenSelectMusic is about to load, before any of its actors have been processed yet.
--
-- I haven't dug into the engine's src, but it seems that having the style set to "single"
-- is how to get the most playable stepcharts to appear in AutoSetStyle.
--      -quietly

local actor = Def.Actor{}

if THEME:GetMetric("Common", "AutoSetStyle") == true then

	-- first, store the current steps for each player
	-- if this is the first time SSM is loading, GetCurrentSteps() will return nil
	-- otherwise, it will be a steps object
	local current_steps = {}
	for player in ivalues(PlayerNumber) do
		current_steps[player] = GAMESTATE:GetCurrentSteps(player)
	end

	-- next, force the engine's style to either "single" or "versus"
	-- this will allow AutoSetStyle to present the most playable stepcharts
	-- in the MusicWheel.
	-- This has the side-effect of changing the player's current stepchart
	-- to the first available singles stepchart, but we can counteract that next...
	local styles = { "single", "versus" }
	GAMESTATE:SetCurrentStyle( styles[GAMESTATE:GetNumSidesJoined()] )

	-- finally, set up this Actor's OnCommand to set each player's stepchart
	-- to whatever it was before we forcibly changed the engine's style.
	actor.OnCommand=function(self)
		for player in ivalues(PlayerNumber) do
			if current_steps[player] then
				GAMESTATE:SetCurrentSteps(player, current_steps[player])
			end
		end
	end
end

return actor