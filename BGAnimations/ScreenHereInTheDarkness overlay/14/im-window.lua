local conversation = ...

local sounds = { sent=nil, received=nil }
local im = { w=300, h=400, topbar=20, icon=12 }
local h = 0
local font_zoom = 0.65
local padding = 10

local typing_data = {}
local currently_typing = 1
local typing_delay = 0.065
local deleting_delay = 0.0125

-- preprocess Ben's data to create a table of sequential tweens
for i=1, #conversation do
	if conversation[i].author == "Ben" then

		local time = conversation[i].startTyping - (#typing_data>1 and (typing_data[#typing_data].send or (typing_data[#typing_data].startDeleting+typing_data[#typing_data].words:len()*deleting_delay)) or 0)
		typing_data[#typing_data+1] = {startTyping=conversation[i].startTyping, sleep=time, kind="Type", words=conversation[i].words}

		if conversation[i].send then
			time = conversation[i].send - conversation[i].startTyping - (conversation[i].words:len() * typing_delay)
			typing_data[#typing_data+1] = {startTyping=conversation[i].startTyping, send=conversation[i].send, sleep=time, kind="Send", words=conversation[i].words}

		elseif conversation[i].startDeleting then
			time = conversation[i].startDeleting - (conversation[i].startTyping + conversation[i].words:len()*typing_delay)
			typing_data[#typing_data+1] = {startTyping=conversation[i].startTyping, startDeleting=conversation[i].startDeleting, sleep=time, kind="Delete", words=conversation[i].words}

		end
	end
end

local af = Def.ActorFrame{
	InitCommand=function(self) self:visible(false):diffuse(Color.Black) end,
	StartSceneCommand=function(self) self:visible(true):linear(1):diffuse(Color.White) end,
}

-- wallpaper
af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/14/tiger.png"),
	InitCommand=function(self) self:Center():FullScreen() end,
}

local im_af = Def.ActorFrame{
	InitCommand=function(self) self:xy(_screen.cx, 40) end,

	-- mask to hide chat-bubbles that have scrolled up
	Def.Quad{
		InitCommand=function(self) self:zoomto(im.w, 1000):y(im.topbar+4):valign(1):MaskSource() end
	},

	Def.Sound{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/14/sent.ogg"),
		InitCommand=function(self) sounds.sent = self end,
		PlayCommand=function(self) self:stop():play() end
	},
	Def.Sound{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/14/received.ogg"),
		InitCommand=function(self) sounds.received = self end,
		PlayCommand=function(self) self:stop():play() end
	},

	-- border around entire window
	Def.Quad{
		InitCommand=function(self) self:zoomto(im.w+2, im.h+2):diffuse(color("#444444")):y(im.h/2) end
	},

	-- background blue color
	Def.Quad{
		InitCommand=function(self) self:zoomto(im.w, im.h):diffuse(color("#ccccff")):valign(0) end
	},

	-- dragbar ActorFrame
	Def.ActorFrame{
		InitCommand=function(self) self:xy(-im.w/2, im.topbar/2 + 2) end,

		-- dragbar texture
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/14/dragbar.png"),
			InitCommand=function(self) self:zoomtowidth(im.w):halign(0) end
		},
		-- close
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/14/circle.png"),
			InitCommand=function(self) self:zoomto(im.icon,im.icon):diffuse(Color.Red):x(im.icon+4):halign(1) end
		},
		-- minimize
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/14/circle.png"),
			InitCommand=function(self) self:zoomto(im.icon,im.icon):diffuse(Color.Yellow):x((im.icon+4)*2):halign(1) end
		},
		-- maximize
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/14/circle.png"),
			InitCommand=function(self) self:zoomto(im.icon,im.icon):diffuse(Color.Green):x((im.icon+4)*3):halign(1) end
		},
	},

	-- border between typing area and chat area
	Def.Quad{
		InitCommand=function(self) self:zoomto(im.w, 1):diffuse(color("#444444")):valign(1):y(im.h*0.8) end
	},

	-- typing area
	Def.Quad{
		InitCommand=function(self) self:zoomto(im.w, im.h/5):valign(1):y(im.h) end
	},
}

-- BitmapText for things Ben is typing and has not yet sent
local t = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/verdana/_verdana 20px.ini"),
	Name="Typing",
	InitCommand=function(self)
		self:zoom(font_zoom):wrapwidthpixels((im.w-padding*2)/font_zoom)
			:halign(0):valign(0)
			:diffuse( Color.Black )
			:xy(-im.w/2+padding, im.h*0.8+padding)
	end,
	StartSceneCommand=function(self) self:sleep( 2 ):queuecommand("Sleep") end,
	SleepCommand=function(self)
		if not typing_data[currently_typing] then return end

		self:sleep( typing_data[currently_typing].sleep ):queuecommand( typing_data[currently_typing].kind )
	end,
	TypeCommand=function(self)
		local s = typing_data[currently_typing].words

		if s:len() > self:GetText():len() then
			self:settext( s:sub(0,self:GetText():len()+1) ):sleep( typing_delay ):queuecommand("Type")
		else
			currently_typing = currently_typing+1
			self:queuecommand("Sleep")
		end
	end,
	SendCommand=function(self)
		currently_typing = currently_typing + 1
		self:settext(""):queuecommand("Sleep")
	end,
	DeleteCommand=function(self)
		if self:GetText():len() > 0 then
			self:settext( self:GetText():sub(0,self:GetText():len()-1) ):sleep( deleting_delay ):queuecommand("Delete")
		else
			currently_typing = currently_typing+1
			self:queuecommand("Sleep")
		end
	end
}

-- chat is the ActorFrame that contains all the chat bubbles and sent conversation
-- it is separate from im_af so that we can tween all the chat bubbles simultaneously
-- without tweening the the entire IM window
local chat = Def.ActorFrame{ InitCommand=function(self) self:MaskDest() end }

for i=1, #conversation do

	chat[#chat+1] = Def.ActorFrame{
		InitCommand=function(self)
			self:x(-im.w/2):visible(false)
			if conversation[i].startDeleting then self:hibernate(math.huge) end
		end,
		StartSceneCommand=function(self) self:sleep(2):queuecommand("Transition") end,
		TransitionCommand=function(self)
			if conversation[i].delay then
				self:sleep(conversation[i].delay):queuecommand("Show"):queuecommand("Receive")
			elseif conversation[i].send then
				self:sleep(conversation[i].send):queuecommand("Show"):queuecommand("Send")
			end
		end,
		ShowCommand=function(self)

			local chat_bubble = self:GetChild("chat-bubble")
			local over = (im.h*0.8 - im.topbar) - (chat_bubble:GetY()+chat_bubble:GetZoomY()+(i*padding)) - padding

			if (over < 0) then
				self:GetParent():y( over )
			end

			self:visible(true)
		end,
		SendCommand=function(self) sounds.sent:queuecommand("Play") end,
		ReceiveCommand=function(self) sounds.received:queuecommand("Play") end,

		-- white "chat-bubble" behind each set of words
		Def.Quad{
			Name="chat-bubble",
			InitCommand=function(self)
				self:valign(0)
				if conversation[i].author == "System" then self:visible(false) end
			end,
			OnCommand=function(self)
				if conversation[i].startDeleting then self:hibernate(math.huge); return end

				local kids = self:GetParent():GetChild("")

				self:zoomto(im.w-padding, kids[1]:GetHeight()*font_zoom + kids[2]:GetHeight()*font_zoom + padding*2)
					:xy(im.w/2, h)

				self:GetParent():y(i*padding + im.topbar)
			end
		},

		-- BitmapText for author
		Def.BitmapText{
			File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/verdana/_verdana Bold 20px.ini"),
			Text=conversation[i].author .. ":",
			InitCommand=function(self)
				self:zoom(font_zoom):wrapwidthpixels((im.w-padding)/font_zoom)
					:halign(0):valign(0)
					:x(padding)
				if conversation[i].author == "Ben" then
					self:diffuse( color("#0000aa") )
				elseif conversation[i].author == "Zoe" then
					self:diffuse( color("#aa0000") )
				else
					self:diffuse(Color.Black)
				end
			end,
			OnCommand=function(self)
				if conversation[i].startDeleting then self:hibernate(math.huge); return end

				self:y(h + padding/2)
				h = h + self:GetHeight() * font_zoom + padding/2
			end
		},

		-- BitmapText for words
		Def.BitmapText{
			File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/verdana/_verdana" .. (conversation[i].author=="System" and " Bold" or "") .. " 20px.ini"),
			Text=conversation[i].words,
			InitCommand=function(self)
				self:zoom(font_zoom):wrapwidthpixels((im.w-padding*2)/font_zoom)
					:halign(0):valign(0)
					:x(padding)
					:diffuse(Color.Black)
			end,
			OnCommand=function(self)
				if conversation[i].startDeleting then self:hibernate(math.huge); return end

				self:y(h + padding * 0.75)
				h = h + self:GetHeight() * font_zoom + padding
			end
		},
	}

end

im_af[#im_af+1] = chat
im_af[#im_af+1] = t
af[#af+1] = im_af


return af