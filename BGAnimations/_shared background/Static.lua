-- --------------------------------------------------------
-- static background image

local file = ...

local sprite = Def.Sprite {
	Texture=file,
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy):zoomto(_screen.w, _screen.h)
		self:diffusealpha(0)

		local style = ThemePrefs.Get("VisualStyle")
		self:visible(style == "SRPG5")
	end,
	OnCommand=function(self) self:accelerate(0.8):diffusealpha(1) end,
	VisualStyleSelectedMessageCommand=function(self)
		local style = ThemePrefs.Get("VisualStyle")

		local new_file = THEME:GetPathG("", "_VisualStyles/" .. style .. "/SharedBackground.png")
		self:Load(new_file)

		if style == "SRPG5" then
			self:visible(true)
		else
			self:visible(false)
		end
	end
}

return sprite
