-- humor keeps me going

local max_width = 390
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
	},
	wikipedia = {
		diffuse = {0.9,  0.9,  0.9, 1},
		y = 95,
		halign = 0
	}
}

local quotes = {
	{
		text="How was your day?",
		person="person1",
	},
	{
		text="It snowed all day here.\n\nI ended up staying in and losing\nhours to a Wikipedia rabbit-hole.",
		person="person2",
	},
	{
		text="What'd you read about?",
		person="person1",
	},
	{
		text="Well, I started with Unix Timestamps.",
		person="person2",
	},
	{
		text="At 15:30:08 UTC on Sun, 4 December 292277026596, 64-bit versions of the Unix timestamp will cease to work, as it will\noverflow the largest value that can be held in a signed 64-bit number.\n\nThis is not anticipated to pose a problem, as it is considerably longer than the time it would take the Sun to theoretically expand to a red giant and swallow the Earth.",
		person="wikipedia",
	},

	{
		text="By 10pm, I'd wound my way\nto the heat death of the universe.",
		person="person2",
	},
	{
		text="The Degenerate Era\nGalaxies no longer exist. Stars flung\nout of orbit or consumed by black holes.\n\nThe Black Hole Era\nAll protons decay. The matter that stars\nand life were built of no longer exists.\nA black hole with the mass of the Sun\nhas evaporated.\n\nThe Dark Era.\n\nHeat death.",
		person="wikipedia",
	},
	{
		text="I didn't know whether to feel happy we'd\nhad the intelligence to design something that will surely out-survive us,\n\nor sad because we don't get that much time\nin the grand scheme of things before everything falls apart.",
		person="person2",
	},
	{
		text="Sometimes I worry about\nnot having enough time.\n\nTo see all the things I want to see,\nexperience all the things I want to experience.\n\nTo describe all the thoughts\nin my mind with adequate detail.\n\nI worry I'm building the most elaborate\nsnow sculpture with summer\njust around the corner.",
		person="person2",

	},
	{
		text="Sounds intense.",
		person="person1",
	},
	{
		text="You know me.",
		person="person2",
	},
}


local af = Def.ActorFrame{}
af.InitCommand=function(self) self:x(_screen.cx):diffusealpha(0) end
af.OnCommand=function(self) self:smooth(1):diffusealpha(1) :queuecommand("ReadyForInput") end
af.ReadyForInputCommand=function() input_permitted = true end

af.InputEventCommand=function(self, event)
	if not input_permitted then return end

	if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back" or event.GameButton=="MenuRight") then
		if quotes[count+1] then
			count = count + 1
			self:finishtweening():smooth(0.25):diffusealpha(0):queuecommand("Refresh"):smooth(0.25):diffusealpha(1)
		else
			self:finishtweening():smooth(0.25):diffusealpha(0):queuecommand("NextScreen")
		end
	end
end
af.NextScreenCommand=function(self)
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end


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

-- blockquote border-left
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:diffuse(0.5, 0.5, 0.5, 1):valign(0) end,
	RefreshCommand=function(self)
		self:visible( quotes[count].person == "wikipedia" )
		self:zoomto(2, quote_bmt:GetHeight()):xy( quote_bmt:GetX() - 14, quote_bmt:GetY())
	end
}

return af
