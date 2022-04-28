-- --------------------------------------------------------
-- static background image

local file = ...

-- We want the Shared BG to be used on the following screens.
local SharedBackground = {
	["ScreenInit"] = true,
	["ScreenLogo"] = true,
	["ScreenTitleMenu"] = true,
	["ScreenTitleJoin"] = true,
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

local shared_alpha = 0.6
local overlay_alpha = 1

local sprite = Def.Sprite {
	Texture=file,
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy):zoomto(_screen.w, _screen.h)
		self:diffusealpha(0)

		local style = ThemePrefs.Get("VisualStyle")
		self:visible(style == "SRPG6")
		-- Used to prevent unnecessary self:Loads()
		self.IsShared = true
	end,
	OnCommand=function(self)
		self:accelerate(0.8):diffusealpha(self.IsShared and shared_alpha or overlay_alpha)
	end,
	ScreenChangedMessageCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		local style = ThemePrefs.Get("VisualStyle")
		if style == "SRPG6" then
			if screen and not SharedBackground[screen:GetName()] and self.IsShared then
				self:Load(THEME:GetPathG("", "_VisualStyles/" .. style .. "/Overlay-BG.png"))
				self.IsShared = false
				self:diffusealpha(overlay_alpha)
			end

			if screen and SharedBackground[screen:GetName()] and not self.IsShared then
				self:Load(THEME:GetPathG("", "_VisualStyles/" .. style .. "/SharedBackground.png"))
				self.IsShared = true
				self:diffusealpha(shared_alpha)
			end
		end
	end,
	VisualStyleSelectedMessageCommand=function(self)
		local style = ThemePrefs.Get("VisualStyle")

		local new_file = THEME:GetPathG("", "_VisualStyles/" .. style .. "/SharedBackground.png")
		self:Load(new_file)
		self:zoomto(_screen.w, _screen.h)
		self:diffusealpha(shared_alpha)

		if style == "SRPG6" then
			self:visible(true)
		else
			self:visible(false)
		end
	end
}

return sprite
