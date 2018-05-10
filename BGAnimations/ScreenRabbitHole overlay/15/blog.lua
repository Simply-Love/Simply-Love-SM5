local args = ...
local date = args.date
local body = args.body
local song = args.song

local font_zoom = 0.675
local max_width = 420
local padding = 12

local af = Def.ActorFrame{
	InitCommand=function(self) self:diffuse( Color.Black ) end,
	StartSceneCommand=function(self) self:visible(true):smooth(1):diffuse(Color.White) end
}


if song then
	local bgm_volume = 10

	af[#af+1] = Def.Sound{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/"..song),
		StartSceneCommand=function(self) self:queuecommand("Play") end,
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
end

af[#af+1] = Def.Quad{
	Name="BG",
	InitCommand=function(self) self:FullScreen():Center():diffuse(color("#112233")) end
}

-- -----------------------------------
-- Blog Header

af[#af+1] = Def.Quad{
	Name="HeaderBG",
	InitCommand=function(self) self:valign(0):xy(_screen.cx,0):diffuse(color("#335577")):zoomto(max_width, 80) end
}

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/verdana/_verdana Bold 20px.ini"),
	Text="Ben is...",
	InitCommand=function(self)
		self:zoom(font_zoom*1.5)
			:align(0,0)
			:xy(_screen.cx - max_width/2 + padding, 20)
	end
}

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/verdana/_verdana Bold 20px.ini"),
	Text="...just another guy with a blog",
	InitCommand=function(self)
		self:zoom(font_zoom)
			:align(0,0)
			:xy(_screen.cx - max_width/2 + padding, 50)
	end
}


-- -----------------------------------
-- Blog Body

af[#af+1] = Def.Quad{
	Name="EntryBG",
	InitCommand=function(self) self:diffuse(color("#eeeecc")):valign(0):xy(_screen.cx, 100) end,
	OnCommand=function(self)
		local h = 0
		for i, kid in ipairs(self:GetParent():GetChild("")) do
			h = h + kid:GetHeight()
		end
		self:zoomto(max_width, h * font_zoom + padding*2)
	end
}

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/verdana/_verdana 20px.ini"),
	Text=date,
	InitCommand=function(self)
		self:zoom(font_zoom)
			:align(0,0)
			:diffuse(Color.Black)
			:xy(_screen.cx-max_width/2 + padding, 100+padding)
			:wrapwidthpixels((max_width-padding*2)/font_zoom)
	end
}

af[#af+1] = Def.Quad{
	Name="HorizontalRule",
	InitCommand=function(self) self:diffuse( Color.Black ):valign(0):xy(_screen.cx, 120+padding):zoomto( max_width-padding*2, 1 ) end,
}


af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/verdana/_verdana 20px.ini"),
	Text=body,
	InitCommand=function(self)
		self:zoom(font_zoom)
			:align(0,0)
			:diffuse(Color.Black)
			:xy(_screen.cx-max_width/2 + padding, 134+padding)
			:wrapwidthpixels((max_width-padding*2)/font_zoom)
	end
}


return af