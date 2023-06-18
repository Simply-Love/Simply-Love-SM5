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
	["ScreenSelectColor"] = true,
	["ScreenSelectStyle"] = true,
	["ScreenSelectPlayMode"] = true,
	["ScreenSelectPlayMode2"] = true,
	["ScreenProfileLoad"] = true, -- hidden screen	

	-- false until Technique is selected
	["ScreenSelectMusic"] = false,
	["ScreenEvaluation"] = false,

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

-- Show shared background on more screens if Technique visual style is selected
if ThemePrefs.Get("VisualStyle") == "Technique" then
	SharedBackground["ScreenSelectMusic"] = true
	SharedBackground["ScreenEvaluation"] = true
end

local shared_alpha = 0.6
local static_alpha = 1
local style = ThemePrefs.Get("VisualStyle")

local af = Def.ActorFrame {
	InitCommand=function(self)
		self:diffusealpha(0)
		self:visible(style == "SRPG7")
	end,
	OnCommand=function(self)
		self:accelerate(0.8):diffusealpha(1)
	end,
	VisualStyleSelectedMessageCommand=function(self)
		local style = ThemePrefs.Get("VisualStyle")
		if style == "SRPG7" then
			self:visible(true)
		else
			self:visible(false)
		end
	end,
	Def.Sprite {
		Name="Background",
		InitCommand= function(self)
			if style ~= "SRPG7" then self:Load(nil) return end

			local video_allowed = ThemePrefs.Get("AllowThemeVideos")
			if video_allowed then
				self:Load(THEME:GetPathG("", "_VisualStyles/SRPG7/BackgroundVideo.mp4"))
			else
				self:Load(THEME:GetPathG("", "_VisualStyles/SRPG7/SharedBackground.png"))
			end
			self:xy(_screen.cx, _screen.cy)
			    :zoomto(_screen.h * 16 / 9, _screen.h)
					:blend("BlendMode_Add")
					:diffusealpha(0.8)
					:diffuse(GetCurrentColor(true))
			self:visible(style == "SRPG7")
		end,
		ColorSelectedMessageCommand=function(self)
			self:diffuse(GetCurrentColor(true))
		end,
		VisualStyleSelectedMessageCommand=function(self)
			if style ~= "SRPG7" then self:Load(nil) return end

			local video_allowed = ThemePrefs.Get("AllowThemeVideos")
			if video_allowed then
				self:Load(THEME:GetPathG("", "_VisualStyles/SRPG7/BackgroundVideo.mp4"))
			else
				self:Load(THEME:GetPathG("", "_VisualStyles/SRPG7/SharedBackground.png"))
			end
			self:xy(_screen.cx, _screen.cy)
			    :zoomto(_screen.h * 16 / 9, _screen.h)
					:blend("BlendMode_Add")
					:diffusealpha(0.8)
					:diffuse(GetCurrentColor(true))
		end,
		AllowThemeVideoChangedMessageCommand=function(self)
			if style ~= "SRPG7" then self:Load(nil) return end

			local video_allowed = ThemePrefs.Get("AllowThemeVideos")
			if video_allowed then
				self:Load(THEME:GetPathG("", "_VisualStyles/SRPG7/BackgroundVideo.mp4"))
			else
				self:Load(THEME:GetPathG("", "_VisualStyles/SRPG7/SharedBackground.png"))
			end
			self:xy(_screen.cx, _screen.cy)
			    :zoomto(_screen.h * 16 / 9, _screen.h)
					:blend("BlendMode_Add")
					:diffusealpha(0.8)
					:diffuse(GetCurrentColor(true))
		end,
	}
}

return af
