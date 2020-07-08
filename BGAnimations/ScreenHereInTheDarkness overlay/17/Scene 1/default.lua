local af = Def.ActorFrame{}
local bgm_volume = 10

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/14/connection.ogg"),
	OnCommand=function(self) self:sleep(0.5):queuecommand("Play") end,
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

-- text behind
af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/typo slab serif/_typoslabserif-light 20px.ini"),
	Text="4",
	InitCommand=function(self) self:xy(_screen.cx+134, _screen.cy-12):diffusealpha(0):zoom(1.5) end,
	OnCommand=function(self) self:sleep(1):smooth(2):diffusealpha(1) end,
	StartScene=function(self) self:hibernate(math.huge) end
}

-- monarch butterfly
af[#af+1] = LoadActor(THEME:GetPathB("ScreenHereInTheDarkness", "overlay/17/Scene 8/monarch 2x1.png"))..{
	InitCommand=function(self) self:zoom(0.275):xy(_screen.cx+126, _screen.cy-30):diffuse(0,0,0,0):SetAllStateDelays(0.145) end,
	OnCommand=function(self)
		self:animate(false)
			:sleep(2):smooth(3):diffuse(0.8,0.8,0.8,1):queuecommand("Wings1")
	end,
	Wings1Command=function(self) self:animate(true):sleep(0.3):queuecommand("Wings2") end,
	Wings2Command=function(self) self:animate(false):sleep(4.5):queuecommand("Wings3") end,
	Wings3Command=function(self) self:animate(true):sleep(0.3):queuecommand("Wings1") end,
}

-- text in front
af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/typo slab serif/_typoslabserif-light 20px.ini"),
	Text="Connection: Chapter",
	InitCommand=function(self) self:xy(_screen.cx-13, _screen.cy-12):diffusealpha(0):zoom(1.5) end,
	OnCommand=function(self) self:sleep(1):smooth(2):diffusealpha(1) end,
	StartScene=function(self) self:hibernate(math.huge) end
}

return af