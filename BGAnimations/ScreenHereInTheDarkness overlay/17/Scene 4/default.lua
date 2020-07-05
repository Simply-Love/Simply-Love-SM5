local header = { h=30, c=color("#4468b0") }
local post = { w=400, padding=20 }
local bgm_volume = 10

local af = Def.ActorFrame{
	StartSceneCommand=function(self) self:visible(true):sleep(0.5):smooth(1.5):diffuse(1,1,1,1) end,

	-- body background (grey/blue)
	Def.Quad{
		InitCommand=function(self) self:diffuse(color("#e9ebee")):FullScreen():Center() end
	},

	-- post background (white)
	Def.Quad{
		InitCommand=function(self) self:zoomto(post.w, _screen.h):valign(0):xy(_screen.cx, 0) end
	},

	-- header bar
	Def.Quad{
		InitCommand=function(self) self:diffuse(header.c):zoomto(_screen.w, header.h):valign(0):xy(_screen.cx, 0)  end,
	},

	-- searchbar
	LoadActor("./searchbar.png")..{
		InitCommand=function(self) self:zoom(0.4):valign(0):xy(_screen.cx-100, 2) end,
	},

	-- profile photo
	LoadActor("./profile-photo.png")..{
		InitCommand=function(self) self:zoom(0.175):valign(0):xy(_screen.cx+100, 6) end,
	},

	-- title
	Def.BitmapText{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text="Ben",
		InitCommand=function(self) self:align(0,0):xy(_screen.cx+120,8):zoom(0.85) end
	},

	-- like / comment / share
	LoadActor("./like-comment-share.png")..{
		InitCommand=function(self) self:zoom(0.4):valign(0):xy(_screen.cx, _screen.h - self:GetHeight()/1.85) end,
	},

	-- title
	Def.BitmapText{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text="smitten",
		InitCommand=function(self) self:diffuse(Color.Black):align(0,0):xy(_screen.cx-post.w/2 + post.padding/2, 44):zoom(1.05) end
	},

	-- date
	Def.BitmapText{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text="September 25, 2014 at 2:32am",
		InitCommand=function(self) self:diffuse(0.4,0.4,0.4,1):align(0,0):xy(_screen.cx-post.w/2 + post.padding/2, 70):zoom(0.6) end
	},

	-- note
	Def.BitmapText{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text="...And so, suddenly, after nearly five years of only emails and instant messages, we were able to Skype because the state of technology permitted it, and I had a voice and face to associate with a personality.  Our friendship expanded into new dimensions at that moment.\n\nIt strikes me now, years later, how patient we were, having exchanged words over the internet for years without ever asking to see or hear the person on the other end.  These days, people get angry with you for not having a Tinder photo demonstrably revealing your cup size.\n\n\"Were you instantly smitten by her beauty, being finally able to see her?\"\n\nI don't know.  I didn't really think of it like that at the time, because I'd already been smitten by her words long before that.  She'd demonstrated an utterly captivating command of language from the start, able to be playful and witty and deeply incisive all at once in a single sentence.  I swear, her words kept me alive some nights.",
		InitCommand=function(self)
			self:diffuse(0.2,0.2,0.2,1)
				:align(0,0)
				:xy(_screen.cx-post.w/2 + post.padding/2, 100)
				:zoom(0.65)
				:wrapwidthpixels((post.w - post.padding*2)/0.65)
				:vertspacing(1)
		end
	},

}

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/4/recalling.ogg"),
	StartSceneCommand=function(self) self:sleep(0):queuecommand("Play") end,
	PlayCommand=function(self) self:play() end,
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


return af