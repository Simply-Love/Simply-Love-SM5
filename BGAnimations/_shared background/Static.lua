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

local StaticBackgroundVideos = {
	["Unaffiliated"] = THEME:GetPathG("", "_VisualStyles/SRPG6/Fog.mp4"),
	["Democratic People's Republic of Timing"] = THEME:GetPathG("", "_VisualStyles/SRPG6/Ranni.mp4"),
	["Footspeed Empire"] = THEME:GetPathG("", "_VisualStyles/SRPG6/Malenia.mp4"),
	["Stamina Nation"] = THEME:GetPathG("", "_VisualStyles/SRPG6/Melina.mp4"),
}

-- Show shared background on more screens if Technique visual style is selected
if ThemePrefs.Get("VisualStyle") == "Technique" then
	SharedBackground["ScreenSelectMusic"] = true
	SharedBackground["ScreenEvaluation"] = true
end

local shared_alpha = 0.6
local static_alpha = 1

local af = Def.ActorFrame {
	InitCommand=function(self)
		self:diffusealpha(0)
		local style = ThemePrefs.Get("VisualStyle")
		self:visible(style == "SRPG6")
		self.IsShared = true
	end,
	OnCommand=function(self)
		self:accelerate(0.8):diffusealpha(1)
	end,
	ScreenChangedMessageCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		local style = ThemePrefs.Get("VisualStyle")
		if screen and style == "SRPG6" then
			local static = self:GetChild("Static")
			local video = self:GetChild("Video")
			if SharedBackground[screen:GetName()] and not self.IsShared then
				static:visible(true)
				video:Load(THEME:GetPathG("", "_VisualStyles/SRPG6/Fog.mp4"))
				video:rotationx(180):blend("BlendMode_Add"):diffusealpha(shared_alpha):diffuse(color("#ffffff"))
				self.IsShared = true
			end
			if not SharedBackground[screen:GetName()] and self.IsShared then
				local faction = SL.SRPG6.GetFactionName(SL.Global.ActiveColorIndex)
				-- No need to change anything for Unaffiliated.
				-- We want to keep using the SharedBackground.
				if faction ~= "Unaffiliated" then
					static:visible(false)
					video:Load(StaticBackgroundVideos[faction])
					video:rotationx(0):blend("BlendMode_Normal"):diffusealpha(static_alpha):diffuse(GetCurrentColor(true))
					self.IsShared = false
				end
			end
		end
	end,
	VisualStyleSelectedMessageCommand=function(self)
		local style = ThemePrefs.Get("VisualStyle")
		if style == "SRPG6" then
			self:visible(true)
		else
			self:visible(false)
		end
	end,
	Def.Sprite {
		Name="Static",
		Texture=THEME:GetPathG("", "_VisualStyles/SRPG6/SharedBackground.png"),
		InitCommand=function(self)
			self:xy(_screen.cx, _screen.cy):zoomto(_screen.w, _screen.h):diffusealpha(shared_alpha)
		end,
	},
	Def.Sprite {
		Name="Video",
		Texture=THEME:GetPathG("", "_VisualStyles/SRPG6/Fog.mp4"),
		InitCommand= function(self)
			self:xy(_screen.cx, _screen.cy):zoomto(_screen.w, _screen.h):rotationx(180):blend("BlendMode_Add"):diffusealpha(shared_alpha)
		end,
	},
}

return af
