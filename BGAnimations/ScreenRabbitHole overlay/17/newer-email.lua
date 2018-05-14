local args = ...
local header = args.header
local body = args.body
local delay = args.delay
local song = args.song
local max_width = args.width

local header_zoom = 0.55
local font_zoom = 0.585
local bgm_volume = 10

local af = Def.ActorFrame{
	StartSceneCommand=function(self) self:visible(true) end,
	TransitionCommand=function(self) self:queuecommand("Hide") end
}

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/" .. song),
	StartSceneCommand=function(self) self:sleep(2):queuecommand("Play") end,
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
	InitCommand=function(self) self:FullScreen():Center():diffuse(0.7,0.9,1,0) end,
	StartSceneCommand=function(self) self:linear(1):diffusealpha(1) end
}

af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/17/grass.png"),
	InitCommand=function(self) self:Center():zoom(0.9) end
}


af[#af+1] = Def.ActorFrame{

	InitCommand=function(self) self:fov(90):rotationx(-3):zoom(0.9):xy(30,WideScale(32, 36)) end,

	-- white background for email
	Def.Quad{
		InitCommand=function(self) self:xy(_screen.cx, _screen.h):zoomto(max_width+60, _screen.h-70):valign(1) end
	},

	Def.BitmapText{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text=header,
		InitCommand=function(self)
			self:zoom(header_zoom)
				:align(0,0):xy(_screen.cx - max_width/2, 92)
				:diffuse(Color.Black):diffusealpha(0)
				:wrapwidthpixels(max_width/header_zoom)
		end,
		StartSceneCommand=function(self) self:linear(1):diffusealpha(1) end
	},

	Def.Quad{
		InitCommand=function(self) self:xy(_screen.cx, 150):zoomto(max_width, 1):diffuse(0.75, 0.75, 0.75, 1) end
	},

	Def.BitmapText{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		InitCommand=function(self)
			self:zoom(font_zoom)
				:align(0,0):xy(_screen.cx - max_width/2, 160)
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
	},

	Def.Sprite{
		Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/17/laptop.png"),
		InitCommand=function(self) self:valign(1):xy(_screen.cx, _screen.h):zoom(0.65) end
	}
}

return af