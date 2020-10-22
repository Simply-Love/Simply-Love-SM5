-- Gibberish, maybe.

local max_width = 350
local count = 1
local input_permitted = false

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
		text="I recall you saying, once,\nthat silence was a thing\nyou couldn't do without.",
		person="person2"
	},
	{
		text="I like silence in person.\nI like our frequencies to vibrate\nwithout any background noise.",
		person="person1"
	},
	{
		text="It would suggest inherent harmony.",
		person="person2"
	},
	{
		text="...",
		person="person2"
	},
	{
		text="That's a nice thought.\n\nI got lost in it for several moments,\nstirred back to reality only by the\nblinking cursor on my screen.",
		person="person2"
	},
	{
		text="That cursor is the path\nto communicating with you\nnow, but maybe someday\nwe can meet via thought.",
		person="person2"
	},
	{
		text="You'll send some wonderful\ncombination of words\nand derail me from\nthis computer\nto meet you\n\nin dreams,\nin silence,\nwhere words\non screens\naren't needed.",
		person="person2"
	}
}

local af = Def.ActorFrame{}
af.InitCommand=function(self) self:x(_screen.cx):diffusealpha(0) end
af.OnCommand=function(self) self:sleep(1):smooth(1):diffusealpha(1):queuecommand("ReadyForInput") end
af.ReadyForInputCommand=function() input_permitted = true end

af.InputEventCommand=function(self, event)
	if not input_permitted then return end

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
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/4/recalling.ogg"),
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