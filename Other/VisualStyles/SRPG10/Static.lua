-- SRPG10 background.
local function Brighten(c, intensity)
	return { math.min(1, c[1] * intensity), math.min(1, c[2] * intensity), math.min(1, c[3] * intensity), c[4] }
end

return Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0) end,
	OnCommand=function(self) self:accelerate(0.8):diffusealpha(1) end,
	Def.Sprite{
		Name="Background",
		InitCommand=function(self) self:playcommand("LoadBackground") end,
		LoadBackgroundCommand=function(self)
			local file = ThemePrefs.Get("AllowThemeVideos") and "BackgroundVideo.mp4" or "SharedBackground.png"
			self:Load(VisualStyles.Asset("SRPG10", file))
			self:xy(_screen.cx, _screen.cy):zoomto(_screen.h * 16 / 9, _screen.h)
			self:diffuse(Brighten(GetCurrentColor(true), 3))
		end,
		ColorSelectedMessageCommand=function(self) self:diffuse(Brighten(GetCurrentColor(true), 3)) end,
		AllowThemeVideoChangedMessageCommand=function(self) self:playcommand("LoadBackground") end,
	},
	Def.Quad{
		InitCommand=function(self) self:FullScreen():diffuse(Color.Black):diffusealpha(0.5) end,
	},
}
