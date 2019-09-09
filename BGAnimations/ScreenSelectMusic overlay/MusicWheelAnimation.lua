local t = Def.ActorFrame{}

-- NumWheelItems under [MusicWheel] in Metrics.ini needs to be 17.
-- Only 15 can be seen onscreen at once, but we use 1 extra on top and
-- 1 extra at bottom so that MusicWheelItems don't visually
-- appear/disappear too suddenly while quickly scrolling through the wheel.

-- For this file just use a hardcoded 15, for the sake of animating the
-- "downward cascade" effect that occurs when SelectMusic first appears.
local NumWheelItems = 15

-- Each MusicWheelItem has two Quads drawn in front of it, blocking it from view.
-- Each of these Quads is half the height of the MusicWheelItem, and their y-coordinates
-- are such that there is an "upper" and a "lower" Quad.

-- The upper Quad has cropbottom applied while the lower Quad has croptop applied
-- resulting in a visual effect where the MusicWheelItems appear to "grow" out of the center to full-height.

for i=1,NumWheelItems-2 do
	-- upper
	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:x( _screen.cx+_screen.w/4 )
				:y( 9 + (_screen.h/NumWheelItems)*i )
				:zoomto(_screen.w/2, (_screen.h/NumWheelItems)/2)
				:diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
		end,
		OnCommand=function(self) self:sleep(i*0.05):linear(0.1):cropbottom(1):diffusealpha(0.25):queuecommand("Hide") end,
		HideCommand=function(self) self:visible(false) end
	}
	-- lower
	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:x( _screen.cx+_screen.w/4 )
				:y( 25 + (_screen.h/NumWheelItems)*i )
				:zoomto(_screen.w/2, (_screen.h/NumWheelItems)/2)
				:diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
		end,
		OnCommand=function(self) self:sleep(i*0.05):linear(0.1):croptop(1):diffusealpha(0.25):queuecommand("Hide") end,
		HideCommand=function(self) self:visible(false) end
	}
end

return t