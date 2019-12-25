return Def.ActorFrame{
	InitCommand=function(self) self:x(26) end,

	Def.Quad{
		InitCommand=function(self)
			self:diffuse(0, 10/255, 17/255, 0.5) -- #000a11
			:zoomto(_screen.w/2.1675, _screen.h/15)
		end
	},
	Def.Quad{
		InitCommand=function(self)
			if ThemePrefs.Get("RainbowMode") then
				self:diffuse(1,1,1,0.5)
			else
				self:diffuse(10/255, 20/255, 27/255, 1) -- #0a141b
			end
			self:zoomto(_screen.w/2.1675, _screen.h/15 - 1)
		end
	}
}