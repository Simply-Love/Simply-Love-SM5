local fade_in_time = 0.1

local conversation = {
	{ author="Zoe", delay=fade_in_time, words="I miss you, Ben.  What's up with you?"},

	{ author="Ben", delay=4.0, words="Life is weird.  I work a lot.  Too much, probably." },
	{ author="Ben", delay=8.138, words="I miss you, too." },

	{ author="Zoe", delay=12.276, words="I'm glad we've stayed friends all this time. " },
	{ author="Zoe", delay=16.414, words="It's nice to be reminded I didn't just become worthy of love as I grew up, that I've always been an okay person." },
	{ author="Zoe", delay=20.522, words="I do wonder sometimes." },
	{ author="Ben", delay=24.689, words="You've always been good to me." },
	{ author="Zoe", delay=28.827, words="You're a good person too, you know?" },
	{ author="Ben", delay=32.965, words="Sigh." },

	{ author="Ben", delay=37.103, words="I miss you.  I don't even understand how I can miss someone I've never met." },
	{ author="Zoe", delay=41.339, words="It's maybe because we've known each other for such a long time now." },
	{ author="Zoe", delay=45.729, words="But I don't feel the same way about lots of other people I've known this long." },
	{ author="Zoe", delay=50.174, words="I am having a tough day today, so it's nice to feel you out there." },

	{ author="Zoe", delay=56.286, words="How are you, Ben?" },
	{ author="Ben", delay=59.286, words="4:14 in the am.  Haven't gone in to work yet.  Listening to harp music on YouTube." },

	{ author="Zoe", delay=63.787, words="Harp, eh?  Like this?  [YouTube]" },
	{ author="Ben", delay=67.787, words="Wow." },
	{ author="Ben", delay=69.787, words="That's..." },
	{ author="Ben", delay=71.787, words="That's beautiful." },
	{ author="Ben", delay=73.787, words="It feels like I'm flying." },
	{ author="Ben", delay=75.787, words="Kept aloft by its notes." },
	{ author="Ben", delay=77.787, words="I wish I could be so evocative with the things I create." },

	{ author="Ben", delay=81.832, words="But I wouldn't trade my time with you for technical prowess and Mozartian arpeggios." },
	{ author="Zoe", delay=85.923, words="No sensible human would make that trade with you anyway." },
	{ author="Ben", delay=90.014, words="Was sense ever on our side to begin with? 😅" },
	{ author="Zoe", delay=94.105, words="One of these days I'm gonna clobber you." },
	{ author="Zoe", delay=96.150, words="With a hug." },
	{ author="Ben", delay=98.268, words="I wouldn't miss it for the world." },

	{ author="Zoe", delay=102.503, words="I have to run now!  Until then!" },
	{ author="Ben", delay=106.738, words="Zoe..." },
	{ author="Ben", delay=110.974, words="Until then." },
}

local font_zoom = 0.55
local padding = 10
local bgm_volume = 10

local _phone = {
	Ben = {
		w = 500,
		h = 1000,
		zoom = 0.45,
		bar = 34,
		-- x = _screen.cx - 246,
		x = _screen.cx,
		aligns = { Ben=1, Zoe=0 },
		bubble = { Ben=color("#1ec34b"), Zoe=color("#e5e5ea") },
		text = { Ben=color("#ffffff"), Zoe=color("#333333") },
	},
	Zoe = {
		w = 500,
		h = 1000,
		zoom = 0.45,
		bar = 44,
		x = _screen.cx + 56,
		aligns = { Ben=0, Zoe=1 },
		bubble = { Ben=color("#f1580c"), Zoe=color("#ffffff") },
		text = { Ben=color("#ffffff"), Zoe=color("#333333") },
	}
}

local af = Def.ActorFrame{
	InitCommand=function(self) self:zoom(1.3):xy( WideScale(-100, -130), -72 ) end,
	StartSceneCommand=function(self) self:visible(true):smooth(1.5):diffuse(1,1,1,1) end
}

af[#af+1] = LoadActor("./the-long-walk-home.ogg")..{
	StartSceneCommand=function(self) self:play() end,
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

-- left mask to hide sms bubbles that have scrolled up in Ben's phone
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w, 1000):xy(0,106):align(0,1):MaskSource() end
}

-- Ben's phone
af[#af+1] = Def.ActorFrame{
	InitCommand=function(self) self:xy(_phone.Ben.x, _screen.cy) end,

	-- screen
	Def.Quad{
		InitCommand=function(self) self:zoomto((_phone.Ben.w*_phone.Ben.zoom)*0.875,(_phone.Ben.h*_phone.Ben.zoom)*0.85):diffuse(color("#576274")) end,
	},
	-- topbar
	Def.Quad{
		InitCommand=function(self) self:zoomto((_phone.Ben.w*_phone.Ben.zoom)*0.875, _phone.Ben.bar):y(-_phone.Ben.h/2*_phone.Ben.zoom + 74):diffuse(1,1,1,0.75) end,
	},
	-- wifi bars
	LoadActor("./wifi-bars.png")..{
		InitCommand=function(self) self:xy(-74, -_phone.Ben.h/2*_phone.Ben.zoom + 68):zoom(0.1) end
	},
	-- time
	Def.BitmapText{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text="4:14 AM",
		InitCommand=function(self) self:y(-_phone.Ben.h/2*_phone.Ben.zoom + 68):zoom(0.55):diffuse(0,0,0,1) end
	},
	-- Ben is chatting with Zoe
	Def.BitmapText{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text="Zoe",
		InitCommand=function(self) self:y(-_phone.Ben.h/2*_phone.Ben.zoom + 82):zoom(0.65):diffuse(0,0,0,1) end
	},

	-- shell
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/17/Scene 5/phone.png"),
		InitCommand=function(self) self:zoom(_phone.Ben.zoom) end
	},
}

for human in ivalues({"Ben"}) do

	-- chat is the ActorFrame that contains all the chat bubbles and sent conversation
	-- it is separate from im_af so that we can tween all the chat bubbles simultaneously
	-- without tweening the the entire IM window
	local chat = Def.ActorFrame{ InitCommand=function(self) self:MaskDest():y(50+_phone[human].bar) end }
	local h = 0

	for i=1, #conversation do

		chat[#chat+1] = Def.ActorFrame{
			InitCommand=function(self)
				self:x( _phone[human].x - _phone[human].w/2 * _phone[human].zoom + padding*2 )
					:diffusealpha(0)
			end,
			StartSceneCommand=function(self)
				if conversation[i].delay then
					self:sleep(conversation[i].delay-fade_in_time):queuecommand("Show")
				end
			end,
			ShowCommand=function(self)

				local chat_bubble = self:GetChild("chat-bubble")
				local over = (_phone[human].h*_phone[human].zoom - 64) - (chat_bubble:GetY()+chat_bubble:GetZoomY()+(i*padding)) - padding

				if (over < self:GetParent():GetY()) then
					self:GetParent():y( over )
				end

				self:linear(fade_in_time):diffusealpha(1)
			end,

			-- "chat-bubble" behind each set of words
			Def.Quad{
				Name="chat-bubble",
				InitCommand=function(self)
					self:valign(0)
						:halign( _phone[human].aligns[conversation[i].author] )
						:diffuse( _phone[human].bubble[conversation[i].author] )
				end,
				OnCommand=function(self)
					local words = self:GetParent():GetChild("")

					self:zoomto(_phone[human].w*_phone[human].zoom-60, words:GetHeight()*font_zoom + padding*2)
						:x(conversation[i].author==human and self:GetZoomX()+padding*2 or padding)
						:y(h)

					self:GetParent():y(i*(padding) + padding*2)
				end
			},

			-- BitmapText for words
			Def.BitmapText{
				File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
				Text=conversation[i].words,
				InitCommand=function(self)
					self:zoom(font_zoom)
						:wrapwidthpixels((_phone[human].w*_phone[human].zoom-60-padding*1.5)/font_zoom)
						:halign(0):valign(0)
						:x(conversation[i].author==human and padding*2.5 or padding*1.5)
						:diffuse( _phone[human].text[conversation[i].author] )
				end,
				OnCommand=function(self)
					self:y(h + padding * 0.75)
					h = h + self:GetHeight() * font_zoom + padding*2
				end
			},
		}

	end
	af[#af+1] = chat
end

return af