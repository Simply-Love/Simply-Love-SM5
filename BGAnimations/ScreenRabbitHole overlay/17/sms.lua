-- I miss you, Ben.

local bgm_volume = 10
local count, max = 1, 4
local _phone = { w=225, h=400 }

local af = Def.ActorFrame{ StartSceneCommand=function(self) self:visible(true):diffuse(1,1,1,1) end }

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

-- phone
af[#af+1] = Def.ActorFrame{
	InitCommand=function(self) self:diffuse(0,0,0,1) end,
	StartSceneCommand=function(self) self:sleep(6):smooth(0.75):diffuse(1,1,1,1) end,

	-- screen
	Def.Quad{
		InitCommand=function(self) self:Center():zoomto(_phone.w*0.9,_phone.h*0.9):diffuse(color("#576274")) end,
	},

	-- wallpaper
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/17/chobi.png"),
		InitCommand=function(self) self:zoom(0.35):xy(_screen.cx, _screen.cy+40) end,
	},

	-- shell
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/17/phone.png"),
		InitCommand=function(self) self:Center():zoom(0.45) end
	},

	-- time
	Def.BitmapText{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text="2:09",
		InitCommand=function(self) self:diffuse(0.1,0.1,0.1,1):xy(_screen.cx, _screen.cy-130):zoom(1.5) end
	},


	Def.ActorFrame{
		InitCommand=function(self) self:xy(_screen.cx+4, _screen.cy-85):valign(0) end,
		-- notification bg
		Def.Quad{
			InitCommand=function(self) self:zoomto(500*0.45-48, 42):diffuse(0.8,0.8,0.8,0.925) end,
		},
		-- notification text
		Def.BitmapText{
			File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
			Text="Zoe: I miss you, Ben.  What's up with you?",
			InitCommand=function(self) self:diffuse(Color.Black):zoom(0.725):wrapwidthpixels((500*0.45-48)/0.725):halign(0):addx(-_phone.w/2+30) end
		},
	}
}

return af
