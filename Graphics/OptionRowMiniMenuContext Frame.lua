-- This is the background for a single row inside ScreenMiniMenuContext
-- which, so far in Simply Love, is only used for the faux-overlay menu
-- that pops up when editing local profiles.
--
-- The Quad is wrapped in an ActorFrame so that we can apply zoomto()
-- via OnCommand without having the engine say that the OnCommand for
-- the Frame is already defined in Metrics.ini

local w = 236
local h = 24

return Def.ActorFrame{
	Def.Quad {
		OnCommand=function(self) self:zoomto(w,h) end
	}
}