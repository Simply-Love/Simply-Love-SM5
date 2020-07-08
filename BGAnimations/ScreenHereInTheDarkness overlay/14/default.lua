-- Connection: Chapter 1

local scenes = {}
local duration = { 10, 8.5, 17, 49, 59 }

local scene2 = {
	{ author="Zoe", delay=0, words="hey Ben" },
	{ author="Zoe", delay=3, words="You don't know me, but I read your blog." },
	{ author="Zoe", delay=7, words="I really liked your recent entry.  The one about randomly meeting an old friend." },
	{ author="Zoe", delay=10, words="Just wanted to let you know." },
	{ author="Ben", startTyping=8.5, send=12, words="Thanks." },
	{ author="System", delay=12.3, words="Zoe did not receive the last message because they are currently offline." },
}
local scene3 = {
	delay=0.085,
	song_delay=2,
	width=420,
	song="14/monarchButterflies.ogg",
	header="FROM:  Zoe\nTO:  Ben\nDATE:  Jul-30-2008\nSUBJECT:  I wrote this out of words. A present. I miss you.\n---------------------------------------------------------",
	body="I would never feel\njustified to write\nthree lines of poem.\n\nEven for you, dear,\neven if you asked nicely.\nIt would seem like fraud.\n\nQuality info,\nit comes in graphs and tables.\nAnd in spreadsheets, too.\n\nBut haikus feel nice.\nAnd feeling nice is rare, now.\nMonarch butterflies.\n\nI wish I could show\nall the grotesque, beautiful\nthings to everyone.\n\nIn spreadsheets, or in\ncalico shopping bags or\njust out of my mouth,\n\nand into your head.\nWrote you a tonne of haikus\nin this email. Blargh.\n\nlove and love,\n-Zoe",
}

local scene4={
	delay=0.1075,
	song_delay=0,
	width=420,
	song="14/dear.ogg",
	header="FROM: Ben\nTO: Zoe\nDATE: Jul-30-2008\nSUBJECT: RE: I wrote this out of words. A present. I miss you.\n---------------------------------------------------------",
	body="Three lines of poem\nare justified word for word\nin reviving me.\n\nI smiled to read\nyour epic ballad haiku\nand lengthy heading.\n\nWriting my reply,\nI thought of things I wanted\nto convey to you.\n\nI miss you, was one.\nYou and I have yet to meet,\nyet still I miss you.\n\nBy geography\nwe may be separated;\ntoday I care not.\n\nAcross your three lines\nyou conveyed reassurance:\nyou are not alone.\n\nThree lines of poem\ncould be too much to work with\nwhen three words suffice."
}


local af = LoadActor(THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/Connection/Stage.lua"), {duration=duration, scenes=scenes})

-- scene 1: Chapter Title
af[#af+1] = LoadActor(THEME:GetPathB("ScreenHereInTheDarkness", "overlay/14/title.lua"), {chapter=1, img={}})..{
	InitCommand=function(self) scenes[1] = self end,
	OnCommand=function(self) self:queuecommand("StartScene") end
}

-- scene 2: Prelude
af[#af+1] = LoadActor("./prelude.lua")..{
	InitCommand=function(self)
		scenes[2] = self
		self:visible(false)
	end,
}

-- scene 3: hey Ben
af[#af+1] = LoadActor("./im-window.lua", scene2 )..{
	InitCommand=function(self)
		scenes[3] = self
		self:visible(false)
	end,
}

-- scene 4: monarch butterflies
af[#af+1] = LoadActor("./email.lua", scene3)..{
	InitCommand=function(self)
		scenes[4] = self
		self:visible(false)
	end,
}

-- scene 5: three lines of poem
af[#af+1] = LoadActor("./email.lua", scene4)..{
	InitCommand=function(self)
		scenes[5] = self
		self:visible(false)
	end,
}

af[#af+1] = LoadActor(THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/Connection/Proceed.lua"))

return af