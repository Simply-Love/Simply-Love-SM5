-- Connection: Chapter 2

local scenes = {}
local scene = 1

local scene1 = {
	delay=0.0625,
	width=400,
	song="14/dear.ogg",
	header="FROM: Ben\nTO: Zoe\nDATE: Jan-07-2006\nSUBJECT: RE: get to know you\n---------------------------------------------------------",
	body="Hi Zoe,\n\nI wasn't expecting to receive an email like that, but it was certainly a pleasant surprise. How did you find my blog?  I'm curious, because no one I didn't already know \"in real life\" has ever contacted me because of it.\n\nSo.\n\nAre you asking why I write, or why I write my private thoughts in a public blog on the internet?\n\nThis is my mind posing a question where you asked none. It does this constantly.\nPose questions, that is.\n\nThere's satisfaction, I think, to be found in getting my thoughts down in writing from time to time. It's lasting.  Even if I were to now disagree with something I wrote a year earlier, it's there in writing, a definitive testament to a thought I once held valuable enough to write about.\n\nI guess you could say that I write in a public blog because I hoped someone like you would read it.\n\nBen"
}
local scene2 = {
	delay=0.085,
	width=400,
	song="16/without_strings_short.ogg",
	header="FROM: Zoe\nTO: Ben\nDATE: Oct-22-2006\nSUBJECT: (no subject)\n---------------------------------------------------------",
	body="I wish you hadn't signed off so suddenly.  I worry about you, Ben.\n\nYou're the only person on my buddy list whom I talk to regularly, and if I wasn't talking to you it'd be a waste of... something. Time. Energy.  That thing on my computer that gets angry when I have too many programs open simultaneously.\n\nThe question now is, do I really want to stay up this morning wondering if you'll come back online?\nProbably.\n\nBut you won't.\nSo I won't.\n\nYours,\nZoe"
}
local scene3 = {
	delay=0.0675,
	width=400,
	song="16/sunrise.ogg",
	header="FROM: Zoe\nTO: Ben\nDATE: Jan-08-2006\nSUBJECT: RE:RE: get to know you\n---------------------------------------------------------",
	body="You wrote back!  This is me responding. I'll do this constantly.\nAs long as you keep writing.\n\nI know I said I wouldn't ask you any questions, but...\n\nWhat was the first thing that made you smile today?\n\nYou say you pose a lot of questions, but I'll disagree - you didn't ask me anything in your email.  Anything!  You could have asked anything.  Anything!  What is your favorite movie?  Do you like to read books?  Can you define time?\n\nVoices of a Distant Star, yes, I do, and it has something to do with distance and energy, but physics never was my strong point.\n\nConversations can be a pretty neat back-and-forth balance.  \nOr so I'm told.\nFruitbats.\n\nI'm glad that you write, regardless of the reason.  I guess you could say that I wrote to you because I hoped you would respond.\n\nZoe"
}
local scene4 = {
	{ author="Zoe", delay=0.5, words="When was the last time you read something that wasn't on the internet?" },
	{ author="Ben", startTyping=4, send=11, words="A few weeks ago, I read Faulkner's As I Lay Dying from cover to cover in one sitting." },
	{ author="Zoe", delay=15.5, words="That's a lot of stream of consciousness for one sitting." },
	{ author="Ben", startTyping=18, send=24, words="I downloaded it as a PDF, though, so I guess that doesn't count." },
	{ author="Ben", startTyping=26, send=27.9, words="Hmm." },
	{ author="Ben", startTyping=30, send=35, words="I recently read through my old blog entries." },
	{ author="Ben", startTyping=36.2, startDeleting=40.25, words="The ones I deleted from the internet" },
	{ author="Zoe", delay=38.5, words="You still have them?" },
	{ author="Ben", startTyping=42.8, send=44, words="Yeah." },
	{ author="Zoe", delay=47.5, words="That would have taken a while." },
	{ author="Ben", startTyping=49.5, send=50.8, words="It did." },
	{ author="Zoe", delay=55, words="Hmmm. I wish I could only put things into the internet. It's so easy to just find things online. But it never feels right for me." },
	{ author="Zoe", delay=62, words="Not... substantial enough." },
	{ author="Zoe", delay=70, words="Sometimes I find something I enjoy reading, then afterwards, I don't know, it just doesn't feel real enough." },
	{ author="Ben", startTyping=72, send=80, words="\"To separate oneself from the computer, the TV, the iPod and mobile phone, and to instead face the world head on.\"" },
	{ author="Zoe", delay=84, words="I rarely get quoted back to myself, and enjoy it. :)" },
	{ author="Zoe", delay=89, words="But at the end of the day, the computer ends up coming to bed with me because it glows and it's warm." },
	{ author="Zoe", delay=93, words="Isn't that crazy?" },
	{ author="Zoe", delay=95.5, words="Stupid computer." },
}


local af = Def.ActorFrame{
	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
			self:queuecommand("TransitionScene")
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

-- scene 1: a pleasant surprise
af[#af+1] = LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/14/email.lua"), scene1)..{
	InitCommand=function(self)
		scenes[1] = self
	end,
	OnCommand=function(self) self:queuecommand("StartScene") end,
}

-- scene 2: I wish you hadn't signed off so suddenly
af[#af+1] = LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/14/email.lua"), scene2)..{
	InitCommand=function(self)
		scenes[2] = self
		self:visible(false)
	end,
}

-- scene 3: As long as you keep writing
af[#af+1] = LoadActor( THEME:GetPathB("ScreenRabbitHole", "overlay/14/email.lua"), scene3 )..{
	InitCommand=function(self)
		scenes[3] = self
		self:visible(false)
	end,
}

-- scene 4: When was the last time you read something that wasn't on the Internet?
af[#af+1] = LoadActor(THEME:GetPathB("ScreenRabbitHole", "overlay/14/im-window.lua"), scene4 )..{
	InitCommand=function(self)
		scenes[4] = self
		self:visible(false)
	end,
}

return af