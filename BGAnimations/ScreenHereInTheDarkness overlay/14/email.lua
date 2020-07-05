local args = ...
local header = args.header
local body = args.body
local delay = args.delay
local song_delay = args.song_delay
local song = args.song
local max_width = args.width

local font_zoom = 0.55
local bgm_volume = 10

local af = Def.ActorFrame{
	StartSceneCommand=function(self) self:visible(true) end,
	TransitionCommand=function(self) self:queuecommand("Hide") end
}

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/" .. song),
	StartSceneCommand=function(self) self:sleep(song_delay):queuecommand("Play") end,
	PlayCommand=function(self) self:stop():play() end,
	FadeOutAudioCommand=function(self)
		if bgm_volume >= 0 then
			local ragesound = self:get()
			bgm_volume = bgm_volume-1
			ragesound:volume(bgm_volume*0.1)
			self:sleep(0.1):queuecommand("FadeOutAudio")
		end
	end,
	SwitchSceneCommand=function(self) self:stop() end
}

af[#af+1] = Def.Quad{
	InitCommand=function(self) self:FullScreen():Center():diffusealpha(0) end,
	StartSceneCommand=function(self) self:linear(1):diffusealpha(1) end
}

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/typo slab serif/_typoslabserif-light 20px.ini"),
	Text=header,
	InitCommand=function(self)
		self:zoom(font_zoom)
			:align(0,0):xy(_screen.cx - max_width/2, 10)
			:diffuse(Color.Black):diffusealpha(0)
			:wrapwidthpixels(max_width/font_zoom)
	end,
	StartSceneCommand=function(self) self:linear(1):diffusealpha(1) end
}

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/typo slab serif/_typoslabserif-light 20px.ini"),
	InitCommand=function(self)
		self:zoom(font_zoom)
			:align(0,0):xy(_screen.cx - max_width/2, 74)
			:diffuse(Color.Black)
			:wrapwidthpixels(max_width/font_zoom)
	end,
	StartSceneCommand=function(self)
		self:sleep(3):queuecommand("Type")
	end,
	TypeCommand=function(self)
		if body:len() > self:GetText():len() then
			self:settext( body:sub(0,self:GetText():len()+1) ):sleep( delay ):queuecommand("Type")
		end
	end
}

return af