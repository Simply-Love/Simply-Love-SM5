-- --------------------------------------------------------
-- non-RainbowMode (normal) background

local file = ...

local anim_data = {
	color_add = {0,1,1,0,0,0,1,1,1,1},
	diffusealpha = {0.05,0.2,0.1,0.1,0.1,0.1,0.1,0.05,0.1,0.1},
	xy = {0,40,80,120,200,280,360,400,480,560},
	texcoordvelocity = {{0.03,0.01},{0.03,0.02},{0.03,0.01},{0.02,0.02},{0.03,0.03},{0.02,0.02},{0.03,0.01},{-0.03,0.01},{0.05,0.03},{0.03,0.04}}
}

local t = Def.ActorFrame {
	InitCommand=function(self)
		self:visible(not ThemePrefs.Get("RainbowMode"))
	end,
	OnCommand=function(self) self:accelerate(0.8):diffusealpha(1) end,
	HideCommand=function(self) self:visible(false) end,

	BackgroundImageChangedMessageCommand=function(self)
		if not ThemePrefs.Get("RainbowMode") then
			self:visible(true):linear(0.6):diffusealpha(1)

			local new_file = THEME:GetPathG("", "_VisualStyles/" .. ThemePrefs.Get("VisualTheme") .. "/SharedBackground.png")
			self:RunCommandsOnChildren(function(child) child:Load(new_file) end)
		else
			self:linear(0.6):diffusealpha(0):queuecommand("Hide")
		end
	end
}

for i=1,10 do
	t[#t+1] = Def.Sprite {
		Texture=file,
		InitCommand=function(self)
			self:diffuse(GetHexColor(SL.Global.ActiveColorIndex+anim_data.color_add[i], true))
		end,
		OnCommand=function(self)
			self:zoom(1.3):xy(anim_data.xy[i], anim_data.xy[i])
			:customtexturerect(0,0,1,1):texcoordvelocity(anim_data.texcoordvelocity[i][1], anim_data.texcoordvelocity[i][2])
			:diffusealpha(anim_data.diffusealpha[i])
		end,

		ColorSelectedMessageCommand=function(self)
			self:linear(0.5)
			:diffuse(GetHexColor(SL.Global.ActiveColorIndex+anim_data.color_add[i], true))
			:diffusealpha(anim_data.diffusealpha[i])
		end
	}
end

return t