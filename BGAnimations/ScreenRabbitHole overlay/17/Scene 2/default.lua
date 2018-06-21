local header = "To: Ben\nFrom: Zoe\nDate: July 10, 2010\nSubject: It's been a while."
local body = "I've been thinking a lot about you and the US recently. I hope everything is wonderful for you right now.\n\nI am exceedingly cheerful and motivated at uni and just in general. It's funny all the things I never thought I'd be able to do. I'm more than a sixth of the way to getting a degree, which amazes me.\n\nI'm studying logic, which made me think of you. Logic in words is so much harder than I thought it would be, but you might be a natural with your programming finesse.\n\nOtherwise, I'm pretty good.  I see a lot more people here and have made a few good friends.\n\nOne guy I think you would really like is an astronomy PhD, but also legally blind, which he thinks nothing of, but I find fascinating.  He is a little nerdy but completely sweet and joyous, which I like.  He makes me think of you sometimes.\n\nAnyway, write back when you get a chance and feel free to rant on about whatever you'd like. I hope you are happy and safe and warm where you are.\n\nLove,\nZ"
local delay = 0.0545
local song = "./wings.ogg"
local max_width = 520

local header_zoom = 0.55
local font_zoom = 0.585
local bgm_volume = 10

local af = Def.ActorFrame{
	StartSceneCommand=function(self) self:visible(true):smooth(1):diffuse(1,1,1,1) end,
	TransitionCommand=function(self) self:queuecommand("Hide") end
}

af[#af+1] = LoadActor(song)..{
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

-- grass texture
af[#af+1] = LoadActor("./grass.png")..{
	InitCommand=function(self) self:Center():zoom(0.9) end
}

-- laptop
af[#af+1] = Def.ActorFrame{

	InitCommand=function(self) self:fov(90):rotationx(-3):zoom(0.9):xy(30,WideScale(32, 36)) end,

	-- white background for email
	Def.Quad{
		InitCommand=function(self) self:xy(_screen.cx, _screen.h):zoomto(max_width+60, _screen.h-70):valign(1) end
	},

	-- email header
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

	-- <hr>
	Def.Quad{
		InitCommand=function(self) self:xy(_screen.cx, 150):zoomto(max_width, 1):diffuse(0.75, 0.75, 0.75, 1) end
	},

	-- email body
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

	-- laptop texture
	LoadActor("./laptop.png")..{
		InitCommand=function(self) self:valign(1):xy(_screen.cx, _screen.h):zoom(0.65) end
	}
}

return af