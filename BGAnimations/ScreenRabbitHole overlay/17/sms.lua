-- I miss you, Ben.

local bgm_volume = 10
local count, max = 1, 4
local _phone = { w=225, h=400 }

local af = Def.ActorFrame{ StartSceneCommand=function(self) self:visible(true) end }

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/17/buzz.ogg"),
	StartSceneCommand=function(self) self:sleep(0.5):queuecommand("Play") end,
	PlayCommand=function(self)
		self:play()
		if count < max then
			count = count + 1
			self:sleep(1.5):queuecommand("Play")
		end
	end,
	FadeOutAudioCommand=function(self)
		if bgm_volume >= 0 then
			local ragesound = self:get()
			bgm_volume = bgm_volume-1
			ragesound:volume(bgm_volume*0.1)
			self:sleep(0.1):queuecommand("FadeOutAudio")
		end
	end
}

af[#af+1] = Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0) end,
	StartSceneCommand=function(self) self:sleep(3.5):smooth(1.5):diffusealpha(1) end,

	-- shell
	Def.Quad{
		InitCommand=function(self) self:Center():zoomto(_phone.w,_phone.h):diffuse(0.25,0.25,0.25,1) end,
	},

	-- wallpaper
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/17/wallpaper.png"),
		InitCommand=function(self) self:Center():zoomto(_phone.w-10,_phone.h-20):diffusetopedge(0,0.4,0.8,1):diffusebottomedge(0,0.3,0.6,1) end,
	},

	-- bottom bar
	Def.Quad{
		InitCommand=function(self) self:xy(_screen.cx, _screen.cy+_phone.w-40):valign(0):zoomto(_phone.w, _phone.h*0.1):diffuse(0.25,0.25,0.25,1) end,
	},
	-- home button
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/17/circle.png"),
		InitCommand=function(self) self:zoomto(_screen.h*0.1 - 12,_screen.h*0.1 - 12):xy(_screen.cx, _phone.h+28):valign(0):diffuse(0.15,0.15,0.15,1) end
	},
	-- time
	Def.BitmapText{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text="2:09",
		InitCommand=function(self) self:diffuse(Color.White):xy(_screen.cx, _screen.cy-150):zoom(1.4) end
	},

	-- notification
	Def.Quad{
		InitCommand=function(self) self:xy(_screen.cx, _screen.cy-100):valign(0):zoomto(_phone.w-20, 40):diffuse(1,1,1,0.85) end,
	},
	Def.BitmapText{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text="Zoe: I miss you, Ben.  What's up with you?",
		InitCommand=function(self) self:diffuse(Color.Black):xy(_screen.cx - _phone.w/2 + 15, _screen.cy-100+5):zoom(0.7):wrapwidthpixels((_phone.w-20)/0.7):align(0,0) end
	},
}

return af
