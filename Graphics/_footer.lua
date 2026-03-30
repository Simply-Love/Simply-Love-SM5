-- tables of rgba values
local dark  = {0,0,0,0.9}
local light = {0.65,0.65,0.65,1}
local green = {0.569, 0.816, 0.310,0.9}
local pink = {0.925, 0.333, 0.490, 0.9}

return Def.Quad{
	Name="Footer",
	InitCommand=function(self)
		self:draworder(90):zoomto(_screen.w, 32):vertalign(bottom):y(32)
		if ThemePrefs.Get("VisualStyle") == "SRPG9" then
			self:diffuse(GetCurrentColor(true))
		elseif DarkUI() then
			self:diffuse(dark)
		elseif ThemePrefs.Get("VisualStyle") == "Technique" then
			self:diffusealpha(0)
		else
			self:diffuse(light)
		end
	end,
	ScreenChangedMessageCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen():GetName()
		if topscreen == "ScreenSelectMusicCasual" then
			self:diffuse(dark)
		end

		if ThemePrefs.Get("VisualStyle") == "SRPG9" then
			self:diffuse(GetCurrentColor(true))
		end
		if ThemePrefs.Get("VisualStyle") == "Technique" then
			if topscreen == "ScreenSelectMusic" and not ThemePrefs.Get("RainbowMode") then
				self:diffuse(0, 0, 0, 0.5)
			else
				self:diffusealpha(0)
			end
		end
    	 if SL.Global.GameMode == "Casual" and topscreen == "ScreenSelectMusic" then
            self:diffuse(green)
        end
        if SL.Global.GameMode == "ITG" and topscreen == "ScreenSelectMusic" then
            self:diffuse(pink)
        end
	end,
	ColorSelectedMessageCommand=function(self)
		if ThemePrefs.Get("VisualStyle") == "SRPG9" then
			self:diffuse(GetCurrentColor(true))
		end
	end,
	VisualStyleSelectedMessageCommand=function(self)
		if ThemePrefs.Get("VisualStyle") == "Technique" then
			self:diffusealpha(0)
		end
	end,
}
