local player = ...
local pn = ToEnumShortString(player)

-- if the conditions aren't right, don't bother
if SL[pn].ActiveModifiers.DataVisualizations ~= "Step Statistics"
or GAMESTATE:GetCurrentStyle():GetName() ~= "single"
or SL.Global.GameMode == "Casual"
or (PREFSMAN:GetPreference("Center1Player") and not IsUsingWideScreen())
then
	return
end

local af = Def.ActorFrame{}

af[#af+1] = Def.ActorFrame{
	InitCommand=function(self)

		if (PREFSMAN:GetPreference("Center1Player") and IsUsingWideScreen()) then
			-- 16:9 aspect ratio (approximately 1.7778)
			if GetScreenAspectRatio() > 1.7 then
				self:x( _screen.w/4 * (player==PLAYER_1 and 3 or 1) + (70 * (player==PLAYER_1 and 1 or -1) ))
				self:zoom(0.925)

			-- if 16:10 aspect ratio
			else
				self:x( _screen.w/4 * (player==PLAYER_1 and 3 or 1) + (64 * (player==PLAYER_1 and 1 or -1) ))
				self:zoom(0.825)
			end
		else
			self:x( _screen.w/4 * (player==PLAYER_1 and 3 or 1) )
		end

		self:y(_screen.cy + 80)
	end,

	LoadActor("./BackgroundAndBanner.lua", player),
	LoadActor("./JudgmentLabels.lua", player),
	LoadActor("./JudgmentNumbers.lua", player),
	LoadActor("./DensityGraph.lua", player),
}

-- The density histogram will scroll horizontally for sufficiently long songs
-- (see comments in DensityGraph.lua). We want to hide the scrolling histogram
-- past a certain point so that it doesn't, for example, scroll underneath the
-- player's notefield.
--
-- Masking the histogram to not display beyond the bounds of the StepStats pane
-- won't work.  Too many ITG NoteSkins use masking internally to keep their
-- scrolling textures kept inside the 3D model.  Using a mask here would interfere
-- there and many NoteSkins would not render as desired.
--
-- A previous strategy here was to use a half-width Quad that was drawn over the
-- histogram, but under everything else in Gameplay so that the histogram could
-- scroll under it as needed.  A side-effect was that the Quad then blocked the
-- background art from view, and many players reported this as a bug.
--
-- The current solution to this problem is to load a copy of the CurrentSong's
-- background into a Sprite, and crop and position that appropriately, similar
-- to the Quad I was using before.

af[#af+1] = LoadActor("./SongBackground.lua", player)

return af