-- --------------------------------------------------------
-- static background image

local function Brighten(color, intensity)
	color[1] = math.min(1, color[1] * intensity)
	color[2] = math.min(1, color[2] * intensity)
	color[3] = math.min(1, color[3] * intensity)
	return color
end

local af = Def.ActorFrame {
	Name="_shared background/Static",
	InitCommand=function(self)
		self:diffusealpha(0)
	end,
	OnCommand=function(self)
		self:accelerate(0.8):diffusealpha(1)
	end,
	Def.Sprite {
		Name="Background",
		InitCommand= function(self)
			local video_allowed = ThemePrefs.Get("AllowThemeVideos")
			if video_allowed then
				self:Load(THEME:GetPathG("", "_VisualStyles/SRPG9/BackgroundVideo.mp4"))
			else
				self:Load(THEME:GetPathG("", "_VisualStyles/SRPG9/SharedBackground.png"))
			end
			self:xy(_screen.cx, _screen.cy)
			    :zoomto(_screen.h * 16 / 9, _screen.h)
				:diffuse(Brighten(GetCurrentColor(true), 3))
			self:visible(true)
		end,
		ColorSelectedMessageCommand=function(self)
			self:diffuse(Brighten(GetCurrentColor(true), 3))
		end,
		AllowThemeVideoChangedMessageCommand=function(self)
			local video_allowed = ThemePrefs.Get("AllowThemeVideos")
			if video_allowed then
				self:Load(THEME:GetPathG("", "_VisualStyles/SRPG9/BackgroundVideo.mp4"))
			else
				self:Load(THEME:GetPathG("", "_VisualStyles/SRPG9/SharedBackground.png"))
			end
			self:xy(_screen.cx, _screen.cy)
			    :zoomto(_screen.h * 16 / 9, _screen.h)
				:diffuse(Brighten(GetCurrentColor(true), 3))
		end,
	},
	Def.Quad{
		InitCommand=function(self)
			self:FullScreen()
			 :diffuse(Color.Black)
			 :diffusealpha(0.5)
		end,
	}
}

return af
