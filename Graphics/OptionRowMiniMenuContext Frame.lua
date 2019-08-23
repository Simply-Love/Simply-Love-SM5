-- This is the background for a single row inside ScreenMiniMenuContext
-- which, so far in Simply Love, is only used for the faux-overlay menu
-- that pops up when editing local profiles.
--
-- The Quad is wrapped in an ActorFrame so that we can apply zoomto()
-- via OnCommand without having the engine say that the OnCommand for
-- the Frame is already defined in Metrics.ini
--
-- It is unclear why I once thought defining the height of a row in this menu
-- to be 1/20 of the screen's height was a good idea, but it works, so I
-- guess I'll just leave it alone for now...

return Def.ActorFrame{
	Def.Quad {
		OnCommand=function(self) self:zoomto(200,_screen.h*0.05) end
	}
}