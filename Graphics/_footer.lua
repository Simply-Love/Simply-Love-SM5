local dark = {0,0,0,0.9}
local light = {0.65,0.65,0.65,1}

return Def.Quad{
	Name="Footer",
	InitCommand=function(self)
		self:draworder(90):zoomto(_screen.w, 32):vertalign(bottom):y(32)
		
		if ThemePrefs.Get("RainbowMode") then
			self:diffuse(dark)
		else
			self:diffuse(light)
		end
	end,
	ScreenChangedMessageCommand=function(self)
		if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectMusicCasual" then
			self:diffuse(dark)
		end	
	end
}