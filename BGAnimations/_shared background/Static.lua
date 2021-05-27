-- --------------------------------------------------------
-- static background image

local file = ...

-- We want the yellow BG to be used on the following screens.
local yellowSrpg = {
	["ScreenInit"] = true,
	["ScreenTitleMenu"] = true,
	["ScreenSelectProfile"] = true,
	["ScreenAfterSelectProfile"] = true, -- hidden screen
	["ScreenSelectColor"] = true,
	["ScreenSelectStyle"] = true,
	["ScreenSelectPlayMode"] = true,
	["ScreenSelectPlayMode2"] = true,
	["ScreenProfileLoad"] = true, -- hidden screen

	-- Operator Menu screens and sub screens.
	["ScreenOptionsService"] = true,
	["ScreenSystemOptions"] = true,
	["ScreenMapControllers"] = true,
	["ScreenTestInput"] = true,
	["ScreenInputOptions"] = true,
	["ScreenGraphicsSoundOptions"] = true,
	["ScreenVisualOptions"] = true,
	["ScreenAppearanceOptions"] = true,
	["ScreenSetBGFit"] = true,
	["ScreenOverscanConfig"] = true,
	["ScreenArcadeOptions"] = true,
	["ScreenAdvancedOptions"] = true,
	["ScreenMenuTimerOptions"] = true,
	["ScreenUSBProfileOptions"] = true,
	["ScreenOptionsManageProfiles"] = true,
	["ScreenThemeOptions"] = true,
}

local sprite = Def.Sprite {
	Texture=file,
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy):zoomto(_screen.w, _screen.h)
		self:diffusealpha(0)

		local style = ThemePrefs.Get("VisualStyle")
		self:visible(style == "SRPG5")
		-- Used to prevent unnecessary self:Loads()
		self.IsYellow = true
	end,
	OnCommand=function(self) self:accelerate(0.8):diffusealpha(1) end,
	ScreenChangedMessageCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		local style = ThemePrefs.Get("VisualStyle")
		if style == "SRPG5" then
			if screen and not yellowSrpg[screen:GetName()] and self.IsYellow then
				self:Load(THEME:GetPathG("", "_VisualStyles/" .. style .. "/Overlay-BG.png"))
				self.IsYellow = false
			end

			if screen and yellowSrpg[screen:GetName()] and not self.IsYellow then
				self:Load(THEME:GetPathG("", "_VisualStyles/" .. style .. "/SharedBackground.png"))
				self.IsYellow = true
			end
		end
	end,
	VisualStyleSelectedMessageCommand=function(self)
		local style = ThemePrefs.Get("VisualStyle")

		local new_file = THEME:GetPathG("", "_VisualStyles/" .. style .. "/SharedBackground.png")
		self:Load(new_file)
		self:zoomto(_screen.w, _screen.h)

		if style == "SRPG5" then
			self:visible(true)
		else
			self:visible(false)
		end
	end
}

return sprite
