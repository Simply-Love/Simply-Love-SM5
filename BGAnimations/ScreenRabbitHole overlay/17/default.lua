-- Connection: Chapter 4

local scenes = {}
local scene = 1

local scene2 = {
	delay=0.071,
	filename="3.txt",
	initial_text="",
	song="17/love-letters.ogg",
	body="Starting in the late morning, it snowed here all day - light, fluffy, wet snowflakes eventually accumulating to a few inches. There was a gentle breeze as I walked back to my apartment after class, as the snow silently covered everything, making tired sights new again.\n\nI am just now back from a brisk run through it, around town and up a steep hill, running as hard as I could until my legs felt like deadweight, my skin stung from the wind, and my heart rate raised to a point where I could feel it in my neck.\n\nAnd I found my thoughts were with you today and tonight. That is to say:\n\nI love you as I love standing amidst a silent snowfall, being gently covered by it until my hair is white and I appear old.\n\nI love you as I love running fiercely through a sharp, stinging wind, understanding that I am still human and alive.\n\nBen"
}

local scene3 = {
	delay=0.0545,
	width=520,
	song="17/Wings.ogg",
	header="To: Ben\nFrom: Zoe\nDate: July 10, 2010\nSubject: It's been a while.",
	body="I've been thinking a lot about you and the US recently. I hope everything is wonderful for you right now.\n\nI am exceedingly cheerful and motivated at uni and just in general. It's funny all the things I never thought I'd be able to do. I'm more than a sixth of the way to getting a degree, which amazes me.\n\nI'm studying logic, which made me think of you. Logic in words is so much harder than I thought it would be, but you might be a natural with your programming finesse.\n\nOtherwise, I'm pretty good.  I see a lot more people here and have made a few good friends.\n\nOne guy I think you would really like is an astronomy PhD, but also legally blind, which he thinks nothing of, but I find fascinating.  He is a little nerdy but completely sweet and joyous, which I like.  He makes me think of you sometimes.\n\nAnyway, write back when you get a chance and feel free to rant on about whatever you'd like. I hope you are happy and safe and warm where you are.\n\nLove,\nZ",
}

local scene4 = {
	delay=0.08,
	filename="28.txt",
	initial_text="echo \"hi zoe\"\ncurl somesortofurl.com > ./smitten.txt\n",
	song="17/love-letters.ogg",
	body="The heavy snowfall today consumes the sounds, sights, and feelings that would otherwise cue spring's anticipated approach. With the snow comes peace in the middle of the night during a long walk to nowhere, but I have walked alone so many times this winter. It is spring that carries the hope of something new.\n\nGazing out my ice-crusted window into the remote distance, far beyond the confines of this apartment, or this city, or my mind, I wished to convey that my thoughts are with you; that I am with you.\n\nI love you as I love the anticipation of warm breezes gently kissing the skin of my arms.\n\nI love you as I love a months's worth of of love letters.\n\nThank you for being my friend.\n\nBen"
}

local scene8 = {
	{ author="Zoe", delay=0, words="I miss you, Ben.  What's up with you?"},

	{ author="Ben", delay=5, words="Life is weird.  I work a lot.  Too much, probably." },
	{ author="Ben", delay=9, words="I miss you, too." },

	{ author="Zoe", delay=13, words="I'm glad we've stayed friends all this time. " },
	{ author="Zoe", delay=19, words="It's nice to be reminded I didn't just become worthy of love as I grew up, that I've always been an okay person." },
	{ author="Zoe", delay=24, words="I do wonder sometimes." },
	{ author="Ben", delay=27, words="You've always been good to me." },

	{ author="Ben", delay=31, words="I miss you.  I don't even understand how I can miss someone I've never met." },
	{ author="Zoe", delay=36.5, words="It's maybe because we've known each other for such a long time now." },
	{ author="Zoe", delay=42, words="But I don't feel the same way about lots of other people I've known this long." },
	{ author="Ben", delay=46, words="I know what you mean." },
	{ author="Zoe", delay=53, words="I am having a tough day today, so it's nice to feel you out there." },
}


local af = Def.ActorFrame{
	InputEventCommand=function(self, event)
		if not event.PlayerNumber or not event.button then return false end
		if scene == 4 then
			scenes[4]:playcommand("Ch4Sc4InputEvent", event)
		else
			if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
				self:queuecommand("TransitionScene")
			end
		end
	end,
	TransitionSceneCommand=function(self)
		scenes[scene]:queuecommand("FadeOutAudio"):smooth(1):diffuse( Color.Black )
		self:sleep(1):queuecommand("SwitchScene")
	end,
	SwitchSceneCommand=function(self)
		scenes[scene]:hibernate(math.huge)

		if scenes[scene+1] then
			scene = scene + 1
			scenes[scene]:queuecommand("StartScene")
		else
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
}

-- scene 1: Chapter Title
af[#af+1] = LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/14/title.lua"), 4)..{
	InitCommand=function(self) scenes[1] = self end,
	OnCommand=function(self) self:queuecommand("StartScene") end
}

-- scene 2: love letters
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/love-letters.lua"), scene2 )..{
	InitCommand=function(self)
		scenes[2] = self
		self:visible(false):diffuse(0,0,0,1)
	end,
}

-- scene 3: It's funny all the things I never thought I'd be able to do.
af[#af+1] = LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/17/newer-email.lua"), scene3)..{
	InitCommand=function(self)
		scenes[3] = self
		self:visible(false):diffuse(0,0,0,1)
	end,
}

-- scene 4: love letters, continued
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/love-letters.lua"), scene4 )..{
	InitCommand=function(self)
		scenes[4] = self
		self:visible(false):diffuse(0,0,0,1)
	end,
}

-- scene 5: I've known her now, what, the last four or five years?
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/stargazing.lua") )..{
	InitCommand=function(self)
		scenes[5] = self
		self:visible(false):diffuse(0,0,0,1)
	end,
}

-- scene 6: I miss you, Ben.
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/sms.lua") )..{
	InitCommand=function(self)
		scenes[6] = self
		self:visible(false):diffuse(0,0,0,1)
	end,
}


-- scene 7: the speed of life
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/17/stargazing.lua"), scene7 )..{
	InitCommand=function(self)
		scenes[7] = self
		self:visible(false):diffuse(0,0,0,1)
	end,
}


-- scene 8: epilogue



return af