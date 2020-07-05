-- Connection: Chapter 2

local scenes = {}
local duration = { 10, 18, 26, 22, 49 }

local scene2 = { date="March 25, 2008", body="When the Intro to Networking assignment started with the phrase \"Imagine two households...\" and proceeded to develop a TCP metaphor involving packets and pipes and three-way handshakes, the only thing that came to my mind was:\n\nTwo households, both alike in dignity,\nIn fair Verona, where we lay our scene\n\nI do often worry I'm not cut out to be a programmer.  I see such innate brilliance in my peers while I struggle with the most simple concepts daily.  I fear I'm more taken by code as a means rather than an end.\n\n// Lost in nested loops\n// I write haiku in the grey\n// comments of my code..." }
local scene3 = { song="15/dreams.ogg", date="August 3, 2008", body="I had another dream about her last night.\n\nWhen I first entered, she smiled and gave me a hug.  I could see the corners of her lips curling upward in a sign of affection and feel her arms pressing into my back, holding me close to her body for the embrace.  I could sense the warmth from her torso diffusing into mine.  I could smell the fragrance from her shampoo in her hair.\n\nWhen she kissed me, I could taste the flavor of her lip gloss and feel the warmth of her lips pressed against my own.  And when she whispered \"I love you\" into my ear, I not only heard it, but felt the words tickling the inner recesses of my ear.\n\nBeing there with her, in that moment, I believed it." }

local scene4 = {
	{ author="Ben", startTyping=0.4, send=9.4, words="You said, once, to me that you live for the next good thing." },
	{ author="Ben", startTyping=10, send=12.8, words="What if nothing good were to come?" },
	{ author="Zoe", delay=16, words="We'll see." },
	{ author="Zoe", delay=18.8, words="The track record favors it, though." },
}
local scene5 = {
	delay=0.095,
	width=355,
	song_delay=2,
	song="14/monarchButterflies.ogg",
	header="FROM: Zoe\nTO: Ben\nDATE: Jan-05-2006\nSUBJECT: get to know you\n---------------------------------------------------------",
	body="Ben,\nIt's me, Zoe.  I IMed you the other day about your blog.\n\nI'm interested in learning about you, Ben.\nAbout why you write,\nabout your depression,\nabout your time in a psych ward.\n\nThen we can move to more general topics, like books or movies.\nI like to start friendships backwards, you know?\n\nI won't ask you questions, just tell me whatever you want\nand maybe later I'll discreetly prod you to further\nexplain certain areas.\n\nYou should come online more often.\n-Zoe"
}


local af = LoadActor(THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/Connection/Stage.lua"), {duration=duration, scenes=scenes})

local title = {
	chapter=2,
	img={
		LoadActor(THEME:GetPathB("ScreenHereInTheDarkness", "overlay/17/Scene 8/2.png"))..{
			InitCommand=function(self) self:Center():zoom(2/3):diffuse(0,0,0,1) end,
			OnCommand=function(self)
				self:sleep(2):smooth(3):diffuse(0.8,0.8,0.8,1):queuecommand("Pulse")
			end,
			PulseCommand=function(self) self:diffuseshift():effectperiod(5):effectcolor1(0.8,0.8,0.8,1):effectcolor2(0.4,0.4,0.4,1) end
		},
	}
}

af[#af+1] = LoadActor(THEME:GetPathB("ScreenHereInTheDarkness", "overlay/14/title.lua"), title)..{
	InitCommand=function(self) scenes[1] = self end,
	OnCommand=function(self) self:queuecommand("StartScene") end
}


-- scene 2: Two households
af[#af+1] = LoadActor("./blog.lua", scene2)..{
	InitCommand=function(self)
		scenes[2] = self
		self:visible(false)
	end,
}

-- scene 3: I had another dream about her last night
af[#af+1] = LoadActor("./blog.lua", scene3)..{
	InitCommand=function(self)
		scenes[3] = self
		self:visible(false)
	end,
}

-- scene 4: what if nothing good were to come?
af[#af+1] = LoadActor( THEME:GetPathB("ScreenHereInTheDarkness", "overlay/14/im-window.lua"), scene4 )..{
	InitCommand=function(self)
		scenes[4] = self
		self:visible(false)
	end,
}

-- scene 5: I'm interested in learning about you
af[#af+1] = LoadActor(THEME:GetPathB("ScreenHereInTheDarkness", "overlay/14/email.lua"), scene5 )..{
	InitCommand=function(self)
		scenes[5] = self
		self:visible(false)
	end,
}

af[#af+1] = LoadActor(THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/Connection/Proceed.lua"))

return af