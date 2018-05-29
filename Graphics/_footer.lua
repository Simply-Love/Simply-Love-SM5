return Def.Quad{
	Name="Footer",
	InitCommand=function(self)
		self:draworder(90):zoomto(_screen.w, 32):vertalign(bottom):y(32)
		
		if SL.Global.GameMode == "Casual" or ThemePrefs.Get("RainbowMode") then
			self:diffuse(0,0,0,0.9)
		else
			self:diffuse(0.65,0.65,0.65,1)
		end
	end
}