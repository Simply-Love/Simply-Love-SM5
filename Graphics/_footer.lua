-- tables of rgba values
local dark  = {0,0,0,0.9}
local light = {0.65,0.65,0.65,1}

return Def.Quad{
	Name="Footer",
	InitCommand=function(self)
		self:draworder(90):zoomto(_screen.w, 32):vertalign(bottom):y(32)
		if ThemePrefs.Get("VisualStyle") == "SRPG7" then
			self:diffuse(GetCurrentColor(true))
		elseif DarkUI() then
			self:diffuse(dark)
		else
			self:diffuse(light)
		end
	end,
	ScreenChangedMessageCommand=function(self)
		if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectMusicCasual" then
			self:diffuse(dark)
		end
		if ThemePrefs.Get("VisualStyle") == "SRPG7" then
			self:diffuse(GetCurrentColor(true))
		end
	end,
	ColorSelectedMessageCommand=function(self)
		if ThemePrefs.Get("VisualStyle") == "SRPG7" then
			self:diffuse(GetCurrentColor(true))
		end
	end,
}
