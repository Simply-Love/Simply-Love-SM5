-- where the hallway ends
local max_width = 350
local quote_bmt
local count = 1
local quotes = {
	{
		text="What happens when we get there, the place where the hallway ends?",
		color={0.8, 0.666, 0.666, 1},
	},
	{
		text="For me anyway, it's a combination of understanding and being understood, forgiving and being forgiven.\n\nThe people I hurt are okay and better than ever, I forgive the man who rapes me in my dreams, and we all laugh about how silly it was to have held onto to so much pain for so long.",
		color={0.666, 0.666, 0.8, 1},
	},
	{
		text="Will we find each other there?",
		color={0.8, 0.666, 0.666, 1}
	},
	{
		text="If I found you there, I'd smile to finally see you as you are - your mind, your physical form, you, all at once, in color and motion, with sound and texture.",
		color={0.666, 0.666, 0.8, 1},
	},
	{
		text="I look forward to seeing you there.",
		color={0.8, 0.666, 0.666, 1}
	},
}

local af = Def.ActorFrame{
	InitCommand=function(self) self:x(_screen.cx):diffusealpha(0) end,
	OnCommand=function(self) self:smooth(1):diffusealpha(1) end,

	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back" or event.GameButton=="MenuRight") then
			if quotes[count+1] then
				count = count + 1
				self:finishtweening():smooth(0.6):diffusealpha(0):queuecommand("Refresh"):smooth(0.6):diffusealpha(1)
			else
				self:finishtweening():smooth(0.6):diffusealpha(0):queuecommand("Transition")
			end
		end
	end,
	TransitionCommand=function(self)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
}

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/12/I5.ogg"),
	OnCommand=function(self) self:play() end,
	TransitionCommand=function(self) self:stop() end
}


af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	Text=quotes[1].text,
	InitCommand=function(self)
		quote_bmt = self
		self:wrapwidthpixels(max_width)
			:align(0,0)
			:xy(-self:GetWidth()/2, 70)
			:diffusealpha(0)
			:playcommand("Refresh")
	end,
	RefreshCommand=function(self)
		self:settext(quotes[count].text):diffuse(quotes[count].color)
		if quotes[count].color[1] == 0.8 then
			self:y(140)
		else
			self:y(70)
		end
	end,
}

return af