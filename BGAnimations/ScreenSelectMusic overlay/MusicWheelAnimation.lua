local NumWheelItems = THEME:GetMetric("MusicWheel", "NumWheelItems")
local t = Def.ActorFrame{}

-- Each MusicWheelItem has two Quads drawn in front of it, blocking it from view.
-- Each of these Quads is half the height of the MusicWheelItem, and their y-coordinates
-- are such that there is an "upper" and a "lower" Quad.
-- The upper Quad has cropbottom applied while the lower Quad has croptop applied
-- resulting in a visual effect where the MusicWheelItems appear to "grow" out of the center to full-height.

-- Since the background of this screen is Black, we can get away with drawing Black Quads on top
-- of each MusicWheelItem and it looks fine.  If the background had been visually busy, these Quads
-- would need to be Masks.

for i=1,NumWheelItems-1 do
	-- upper
	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy, _screen.cx+_screen.w/4, 9 + (_screen.h/(NumWheelItems+1))*i; zoomto, _screen.w/2, (_screen.h/(NumWheelItems))/2; diffuse, ThemePrefs.Get("RainbowMode") and Color.White or Color.Black),
		OnCommand=cmd(sleep, i*0.057; linear,0.125; cropbottom,1; diffusealpha, 0.5; queuecommand, "Hide"),
		HideCommand=function(self) self:visible(false) end
	}
	-- lower
	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy, _screen.cx+_screen.w/4, 25 + (_screen.h/(NumWheelItems+1))*i; zoomto, _screen.w/2, (_screen.h/(NumWheelItems))/2; diffuse, ThemePrefs.Get("RainbowMode") and Color.White or Color.Black),
		OnCommand=cmd(sleep, i*0.057; linear,0.125; croptop,1; diffusealpha, 0.5; queuecommand, "Hide"),
		HideCommand=function(self) self:visible(false) end
	}
end

return t