local conversation = ...

local sounds = { sent=nil, received=nil }
local im = { w=300, h=400, topbar=20, icon=12 }
local h = 0
local font_zoom = 0.75
local padding = 10

local chat_aligns = { Ben=1, Zoe=0 }
local chat_colors = { Ben=color("#1ec34b"), Zoe=color("#e5e5ea") }
local chat_text = { Ben=color("#ffffff"), Zoe=color("#333333") }

local af = Def.ActorFrame{ StartSceneCommand=function(self) self:visible(true):smooth(1.5):diffuse(1,1,1,1) end }

local im_af = Def.ActorFrame{
	InitCommand=function(self) self:xy(im.w/2+10, 10) end,

	-- mask to hide chat-bubbles that have scrolled up
	Def.Quad{
		InitCommand=function(self) self:zoomto(im.w*2, 1000):y(im.topbar+4):valign(1):MaskSource() end
	},

	Def.Sound{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/14/sent.ogg"),
		InitCommand=function(self) sounds.sent = self end,
		PlayCommand=function(self) self:stop():play() end
	},
	Def.Sound{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/14/received.ogg"),
		InitCommand=function(self) sounds.received = self end,
		PlayCommand=function(self) self:stop():play() end
	},
}

-- chat is the ActorFrame that contains all the chat bubbles and sent conversation
-- it is separate from im_af so that we can tween all the chat bubbles simultaneously
-- without tweening the the entire IM window
local chat = Def.ActorFrame{ InitCommand=function(self) self:MaskDest() end }

for i=1, #conversation do

	chat[#chat+1] = Def.ActorFrame{
		InitCommand=function(self)
			self:x(-im.w/2):diffusealpha(0)
		end,
		StartSceneCommand=function(self)
			if conversation[i].delay then
				self:sleep(conversation[i].delay):queuecommand("Show")
				if i > 1 then
					if conversation[i].author == "Zoe" then
						self:queuecommand("Receive")
					else
						self:queuecommand("Send")
					end
				end
			end
		end,
		ShowCommand=function(self)

			local chat_bubble = self:GetChild("chat-bubble")
			local over = (im.h*0.8 - im.topbar) - (chat_bubble:GetY()+chat_bubble:GetZoomY()+(i*padding)) - padding

			if (over < 0) then
				self:GetParent():y( over )
			end

			self:linear(0.1):diffusealpha(1)
		end,
		SendCommand=function(self) sounds.sent:queuecommand("Play") end,
		ReceiveCommand=function(self) sounds.received:queuecommand("Play") end,

		-- "chat-bubble" behind each set of words
		Def.Quad{
			Name="chat-bubble",
			InitCommand=function(self)
				self:valign(0)
					:halign( chat_aligns[conversation[i].author] )
					:diffuse( chat_colors[conversation[i].author] )
			end,
			OnCommand=function(self)
				if conversation[i].startDeleting then self:hibernate(math.huge); return end

				local words = self:GetParent():GetChild("")

				self:zoomto(im.w-padding, words:GetHeight()*font_zoom + padding*2)
					:x(conversation[i].author=="Ben" and im.w+padding or padding)
					:y(h)

				self:GetParent():y(i*padding + im.topbar)
			end
		},

		-- BitmapText for words
		Def.BitmapText{
			File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
			Text=conversation[i].words,
			InitCommand=function(self)
				self:zoom(font_zoom):wrapwidthpixels((im.w-padding*3)/font_zoom)
					:halign(0):valign(0)
					:x(conversation[i].author=="Ben" and padding*3 or padding*2)
					:diffuse( chat_text[conversation[i].author] )
			end,
			OnCommand=function(self)
				if conversation[i].startDeleting then self:hibernate(math.huge); return end

				self:y(h + padding * 0.75)
				h = h + self:GetHeight() * font_zoom + padding*2
			end
		},
	}

end

im_af[#im_af+1] = chat
af[#af+1] = im_af

return af