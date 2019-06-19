-- --------------------------------------------------------
-- non-RainbowMode (normal) background

local file = ...

local file_info = {
	ColorRGB = {0,1,1,0,0,0,1,1,1,1},
	diffusealpha = {0.05,0.2,0.1,0.1,0.1,0.1,0.1,0.05,0.1,0.1},
	xy = {0,40,80,120,200,280,360,400,480,560},
	texcoordvelocity = {{0.03,0.01},{0.03,0.02},{0.03,0.01},{0.02,0.02},{0.03,0.03},{0.02,0.02},{0.03,0.01},{-0.03,0.01},{0.05,0.03},{0.03,0.04}}
}

local t = Def.ActorFrame {
	InitCommand=function(self)
		if ThemePrefs.Get("RainbowMode") then
			self:visible(false)
		else
			self:diffusealpha(0)
		end
	end,
	OnCommand=cmd(accelerate,0.8; diffusealpha,1),
	BackgroundImageChangedMessageCommand=function(self)
		if not ThemePrefs.Get("RainbowMode") then
			self:visible(true):linear(0.6):diffusealpha(1)
		else
			self:linear(0.6):diffusealpha(0):queuecommand("Hide")
		end
	end,
	HideCommand=function(self) self:visible(false) end,
}

for i=1,10 do
	t[#t+1] = Def.Sprite {
		Texture=file,
		InitCommand=cmd(diffuse, ColorRGB( file_info.ColorRGB[i] ) ),
		ColorSelectedMessageCommand=cmd(linear, 0.5; diffuse, ColorRGB( file_info.ColorRGB[i] ); diffusealpha, file_info.diffusealpha[i] ),
		OnCommand=cmd(zoom,1.3; xy, file_info.xy[i], file_info.xy[i]; customtexturerect,0,0,1,1;
			texcoordvelocity, file_info.texcoordvelocity[i][1], file_info.texcoordvelocity[i][2]; diffusealpha, file_info.diffusealpha[i] ),
		BackgroundImageChangedMessageCommand=function(self)
			if not ThemePrefs.Get("RainbowMode") then
				local new_file = THEME:GetPathG("", "_VisualStyles/" .. ThemePrefs.Get("VisualTheme") .. "/SharedBackground.png")
				self:Load(new_file)
			end
		end
	}
end

return t