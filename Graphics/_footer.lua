return Def.Quad{
	Name="Footer",
	InitCommand=function(self)
		self:draworder(90):zoomto(_screen.w, 32):vertalign(bottom):y(32)
		
		if ThemePrefs.Get("RainbowMode") then
			self:diffuse(color("#000000dd"))
		else
			self:diffuse(0.65,0.65,0.65,1)
		end
	end
}