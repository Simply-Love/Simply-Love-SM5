-- humor keeps me going

local max_width = 440
local font_zoom = 0.9
local quote_bmt1, quote_bmt2
local count = 1

local quotes = {
	{
		text="How was your day?",
		color={0.8, 0.666, 0.666, 1}
	},
	{
		text="It snowed all day here.  I ended up staying in and losing hours to a Wikipedia rabbit-hole.",
		color={0.666, 0.666, 0.8, 1},
	},
	{
		text="What'd you read about?",
		color={0.8, 0.666, 0.666, 1}
	},
	{
		{
			text="Well, I started with Unix Timestamps:",
			color={0.666, 0.666, 0.8, 1},
		},
		{
			text="At 15:30:08 UTC on Sun, 4 December 292277026596, 64-bit versions of the Unix time stamp will cease to work, as it will overflow the largest value that can be held in a signed 64-bit number.\n\nThis is not anticipated to pose a problem, as it is considerably longer than the time it would take the Sun to theoretically expand to a red giant and swallow the Earth.",
			color={1,1,1,1},
		}
	},
	{
		{
			text="By 10pm, I'd wound my way to the heat death of the universe.",
			color={0.666,0.666,0.8,1}
		},
		{
			text="The Degenrate Era\nGalaxies no longer exist. Stars flung out of orbit or consumed by black holes.\n\nThe Black Hole Era\nAll protons decay. The matter that stars and life were built of no longer exists.\nA black hole with the mass of the Sun has evaporated.\n\nThe Dark Era.\n\nHeat death.",
			color={1,1,1,1}
		}
	},
	{
		text="I didn't know whether to feel happy because we'd been intelligent enough to design something that will surely outsurvive us, or sad because we don't get that much time in the grand scheme of things.\n\nIt felt like a building the most elaborate snowcastle knowing that summer is coming.",
		color={0.666, 0.666, 0.8, 1},
	},
	{
		text="Sounds intense.",
		color={0.8, 0.666, 0.666, 1}
	},
	{
		text="You know me.",
		color={0.666, 0.666, 0.8, 1},
	},
}


local af = Def.ActorFrame{
	InitCommand=function(self) self:x(_screen.cx):diffusealpha(0) end,
	OnCommand=function(self) self:smooth(1):diffusealpha(1) end,

	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back" or event.GameButton=="MenuRight") then
			if quotes[count+1] then
				count = count + 1
				self:finishtweening():smooth(0.25):diffusealpha(0):queuecommand("Refresh"):smooth(0.25):diffusealpha(1)
			else
				self:finishtweening():smooth(0.25):diffusealpha(0):queuecommand("Transition")
			end
		end
	end,
	TransitionCommand=function(self)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
}

-- quote
af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	Text=quotes[1].text,
	InitCommand=function(self)
		quote_bmt = self
		self:wrapwidthpixels(max_width)
			:align(0,0)
			:xy(-max_width/2, 60)
			:diffusealpha(0)
			:playcommand("Refresh")
	end,
	RefreshCommand=function(self)
		if quotes[count].text then
			self:settext(quotes[count].text):diffuse(quotes[count].color)
		else
			self:settext(quotes[count][1].text):diffuse(quotes[count][1].color)
		end
		self:x(-max_width/2)
	end,
}

-- wikipedia quote
af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	Text="",
	InitCommand=function(self)
		quote_bmt2 = self
		self:wrapwidthpixels(max_width)
			:align(0,0)
			:xy(-max_width/2, 120)
			:diffusealpha(0)
			:playcommand("Refresh")
	end,
	RefreshCommand=function(self)
		if quotes[count].text then
			self:settext("")
		else
			self:settext(quotes[count][2].text):diffuse(quotes[count][2].color):y(quote_bmt:GetHeight() + 100)
		end
		self:x(-max_width/2)
	end,
}


af[#af+1] = Def.Quad{
	InitCommand=function(self) self:diffuse(0.5, 0.5, 0.5, 1):valign(0) end,
	RefreshCommand=function(self)
		self:visible( quotes[count].text == nil )
		self:zoomto(2, quote_bmt2:GetHeight()):xy( quote_bmt2:GetX() - 14, quote_bmt2:GetY())
	end
}

return af
