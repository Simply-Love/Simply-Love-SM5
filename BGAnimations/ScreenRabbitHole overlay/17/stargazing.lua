local max_stars = 60
local bgm_volume = 10

local af = Def.ActorFrame{ StartSceneCommand=function(self) self:visible(true):smooth(1.5):diffuse(1,1,1,1) end }

for i=1, max_stars do
	local x = math.random(1, _screen.w)
	local y = math.random(1, _screen.h)
	local w = math.random(1,3)

	af[#af+1]=Def.Sprite{
		Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/14/circle.png"),
		InitCommand=function(self) self:xy(x,y):zoomto(w,w):diffusealpha(0):visible(false) end,
		StartSceneCommand=function(self) self:sleep(i*1.25):visible(true):smooth(1):diffusealpha(1):queuecommand("Pulse") end,
		PulseCommand=function(self) self:pulse():effectmagnitude(1.75,1,1):effectperiod(3) end
	}
end


af[#af+1]=Def.Sprite{
	Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/17/ben.png"),
	InitCommand=function(self) self:align(1,1):xy(_screen.w, _screen.h):zoom(0.6) end,
}

af[#af+1]=Def.Sprite{
	Texture=THEME:GetPathB("ScreenRabbitHole", "overlay/17/glow.png"),
	InitCommand=function(self) self:align(1,1):xy(_screen.w, _screen.h):zoom(0.6) end,
	StartSceneCommand=function(self) self:diffuseshift():effectcolor1(1,1,1,0.1):effectcolor2(1,1,1,1):effectperiod(4) end
}

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/17/since.ogg"),
	StartSceneCommand=function(self) self:sleep(0.5):queuecommand("Play") end,
	PlayCommand=function(self) self:play() end,
	FadeOutAudioCommand=function(self)
		if bgm_volume >= 0 then
			local ragesound = self:get()
			bgm_volume = bgm_volume-1
			ragesound:volume(bgm_volume*0.1)
			self:sleep(0.1):queuecommand("FadeOutAudio")
		end
	end
}

-- -------------
--
-- local conversation = ...
--
-- local sounds = { sent=nil, received=nil }
-- local im = { w=300, h=400, topbar=20, icon=12 }
-- local h = 0
-- local font_zoom = 0.75
-- local padding = 10
--
-- local typing_delay = 0.065
-- local deleting_delay = 0.0125
--
-- local chat_aligns = { Ben=1, Zoe=0 }
-- local chat_colors = { Ben=color("#1ec34b"), Zoe=color("#e5e5ea") }
-- local chat_text = { Ben=color("#ffffff"), Zoe=color("#333333") }
--
--
-- local im_af = Def.ActorFrame{
-- 	InitCommand=function(self) self:xy(im.w/2+10, 10) end,
--
-- 	-- mask to hide chat-bubbles that have scrolled up
-- 	Def.Quad{
-- 		InitCommand=function(self) self:zoomto(im.w*2, 1000):y(im.topbar+4):valign(1):MaskSource() end
-- 	},
--
-- 	Def.Sound{
-- 		File=THEME:GetPathB("ScreenRabbitHole", "overlay/14/sent.ogg"),
-- 		InitCommand=function(self) sounds.sent = self end,
-- 		PlayCommand=function(self) self:stop():play() end
-- 	},
-- 	Def.Sound{
-- 		File=THEME:GetPathB("ScreenRabbitHole", "overlay/14/received.ogg"),
-- 		InitCommand=function(self) sounds.received = self end,
-- 		PlayCommand=function(self) self:stop():play() end
-- 	},
-- }
--
-- -- chat is the ActorFrame that contains all the chat bubbles and sent conversation
-- -- it is separate from im_af so that we can tween all the chat bubbles simultaneously
-- -- without tweening the the entire IM window
-- local chat = Def.ActorFrame{ InitCommand=function(self) self:MaskDest() end }
--
-- for i=1, #conversation do
--
-- 	chat[#chat+1] = Def.ActorFrame{
-- 		InitCommand=function(self)
-- 			self:x(-im.w/2):diffusealpha(0)
-- 		end,
-- 		StartSceneCommand=function(self)
-- 			if conversation[i].delay then
-- 				self:sleep(conversation[i].delay):queuecommand("Show")
-- 				if i > 1 then
-- 					if conversation[i].author == "Zoe" then
-- 						self:queuecommand("Receive")
-- 					else
-- 						self:queuecommand("Send")
-- 					end
-- 				end
-- 			end
-- 		end,
-- 		ShowCommand=function(self)
--
-- 			local chat_bubble = self:GetChild("chat-bubble")
-- 			local over = (im.h*0.8 - im.topbar) - (chat_bubble:GetY()+chat_bubble:GetZoomY()+(i*padding)) - padding
--
-- 			if (over < 0) then
-- 				self:GetParent():y( over )
-- 			end
--
-- 			self:linear(0.1):diffusealpha(1)
-- 		end,
-- 		SendCommand=function(self) sounds.sent:queuecommand("Play") end,
-- 		ReceiveCommand=function(self) sounds.received:queuecommand("Play") end,
--
-- 		-- "chat-bubble" behind each set of words
-- 		Def.Quad{
-- 			Name="chat-bubble",
-- 			InitCommand=function(self)
-- 				self:valign(0)
-- 					:halign( chat_aligns[conversation[i].author] )
-- 					:diffuse( chat_colors[conversation[i].author] )
-- 			end,
-- 			OnCommand=function(self)
-- 				if conversation[i].startDeleting then self:hibernate(math.huge); return end
--
-- 				local words = self:GetParent():GetChild("")
--
-- 				self:zoomto(im.w-padding, words:GetHeight()*font_zoom + padding*2)
-- 					:x(conversation[i].author=="Ben" and im.w+padding or padding)
-- 					:y(h)
--
-- 				self:GetParent():y(i*padding + im.topbar)
-- 			end
-- 		},
--
-- 		-- BitmapText for words
-- 		Def.BitmapText{
-- 			File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
-- 			Text=conversation[i].words,
-- 			InitCommand=function(self)
-- 				self:zoom(font_zoom):wrapwidthpixels((im.w-padding*3)/font_zoom)
-- 					:halign(0):valign(0)
-- 					:x(conversation[i].author=="Ben" and padding*3 or padding*2)
-- 					:diffuse( chat_text[conversation[i].author] )
-- 			end,
-- 			OnCommand=function(self)
-- 				if conversation[i].startDeleting then self:hibernate(math.huge); return end
--
-- 				self:y(h + padding * 0.75)
-- 				h = h + self:GetHeight() * font_zoom + padding*2
-- 			end
-- 		},
-- 	}
--
-- end
--
-- im_af[#im_af+1] = chat
-- af[#af+1] = im_af


return af