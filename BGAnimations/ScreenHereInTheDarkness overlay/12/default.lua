-- There was one night, in particular, when it must have seemed unbearable.
-- She had asked me to hold her, and we spent an hour cuddling in her room,
-- two lonely children lost in sadness.
--
-- In the dream from this morning, when I apologized, she only smiled and
-- reassured me that everything was okay now.
--
-- I awoke with a start, and felt quite certain, quite suddenly, that if
-- there were a heaven, that would have been it.

local max_width = 450
local quote_bmts = {}
local count = 1

local people = {
	person1 = {
		diffuse = {0.8,   0.666, 0.666, 1},
		y = 150,
		halign = 0
	},
	person2 = {
		diffuse = {0.666, 0.666, 0.8, 1},
		y = 100,
		halign = 1,
	}
}

local quotes = {
	{
		text="What happens when we get there,\nthe place where the hallway ends?",
		person="person1"
	},
	{
		text="For me anyway, it's a combination\nof understanding and being understood,\nforgiving and being forgiven.\n\nThe people I hurt are okay and better than ever,\nI forgive the man who rapes me in my dreams,\nand we all laugh about how silly it was\nto have held on to so much pain\nfor so long.",
		person="person2"
	},
	{
		text="Will we find each other there?",
		person="person1"
	},
	{
		text="If I found you there, I'd smile\nto finally see you as you are—\n\nyour mind, your physical form, you,\nall at once, in color and motion,\nwith sound and texture.",
		person="person2"
	},
	{
		text="I look forward to it.",
		person="person1"
	},
}

local af = Def.ActorFrame{}
af.InitCommand=function(self) self:x(_screen.cx):diffusealpha(0) end
af.OnCommand=function(self) self:sleep(1):smooth(1):diffusealpha(1) end

af.InputEventCommand=function(self, event)
	if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back" or event.GameButton=="MenuRight") then
		self:finishtweening():smooth(0.5):diffusealpha(0)

		if quotes[count+1] then
			count = count + 1
			self:queuecommand("Refresh"):smooth(0.5):diffusealpha(1)
		else
			self:queuecommand("NextScreen")
		end
	end
end
af.NextScreenCommand=function(self)
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end


af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/12/I5.ogg"),
	OnCommand=function(self) self:play() end,
	NextScreenCommand=function(self) self:stop() end
}

-- quote
af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	Text=quotes[1].text,
	InitCommand=function(self)
		quote_bmt = self
		self:wrapwidthpixels(max_width):diffusealpha(0)
		self:align(people[quotes[1].person].y,0)
		self:xy(-max_width/2, people[quotes[1].person].y)
		self:playcommand("Refresh")
	end,
	RefreshCommand=function(self)
		self:settext(quotes[count].text)
		self:diffuse(people[quotes[count].person].diffuse)
		self:halign(people[quotes[count].person].halign)
		self:y(people[quotes[count].person].y)
		self:x(max_width/2 * (people[quotes[count].person].halign==0 and -1 or 1))
	end,
}

return af