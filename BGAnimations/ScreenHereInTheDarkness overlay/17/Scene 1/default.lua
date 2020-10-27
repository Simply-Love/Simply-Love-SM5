local af = Def.ActorFrame{}
local bgm_volume = 10

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/17/Scene 1/Chapter 4.ogg"),
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

-- background
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:Center():FullScreen():diffuse(1,1,1,0) end,
	FadeToWhiteCommand=function(self) self:smooth(1):diffusealpha(1) end
}

-- text behind
af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/typo slab serif/_typoslabserif-light 20px.ini"),
	Text="4",
	InitCommand=function(self) self:xy(_screen.cx+134, _screen.cy-12):diffusealpha(0):zoom(1.5) end,
	OnCommand=function(self) self:sleep(1):smooth(2):diffusealpha(1) end,
	FadeToWhiteCommand=function(self) self:sleep(1):linear(0.5):diffusealpha(0) end,
	StartScene=function(self) self:hibernate(math.huge) end
}

-- monarch butterfly
af[#af+1] = LoadActor(THEME:GetPathB("ScreenHereInTheDarkness", "overlay/17/Scene 1/monarch 2x1.png"))..{
	InitCommand=function(self) self:zoom(0.275):xy(_screen.cx+126, _screen.cy-30):diffuse(0,0,0,0):SetAllStateDelays(0.145) end,
	OnCommand=function(self)
		self:animate(false)
		self:sleep(2.4):smooth(1.6):diffuse(0.8,0.8,0.8,1)
		self:aux(1)
		self:queuecommand("Wings1")
	end,
	Wings1Command=function(self) self:animate(true):sleep(0.3):queuecommand("Wings2") end,
	Wings2Command=function(self) self:animate(false):sleep(4.5):queuecommand("Wings3") end,
	Wings3Command=function(self) self:animate(true):sleep(0.3):queuecommand("Wings1") end,
	FadeToWhiteCommand=function(self)
		self:finishtweening()
		self:diffusealpha(0):aux( clamp(self:getaux()-0.25, 0, 1) )
		self:setstate( (self:GetState()+1) % 2 ):addx(_screen.w*0.075):addy( -_screen.h*0.1 ):zoom( self:GetZoom() * 0.8 )
		self:sleep(0.3):diffusealpha( self:getaux() ):accelerate(0.3):diffusealpha(0):queuecommand("FadeToWhite")
	end
}

-- text in front
af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/typo slab serif/_typoslabserif-light 20px.ini"),
	Text="Connection: Chapter",
	InitCommand=function(self) self:xy(_screen.cx-13, _screen.cy-12):diffusealpha(0):zoom(1.5) end,
	OnCommand=function(self) self:sleep(1):smooth(2):diffusealpha(1) end,
	FadeToWhiteCommand=function(self) self:sleep(1):linear(0.5):diffusealpha(0) end,
	StartScene=function(self) self:hibernate(math.huge) end
}

-- foreground fade
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:Center():FullScreen():diffuse(1,1,1,0) end,
	FadeToWhiteCommand=function(self) self:sleep(1):smooth(1):diffusealpha(1):sleep(0.2):smooth(1):diffuse(0,0,0,1) end
}


return af