-- Gibberish, maybe.

local max_width = 395
local quote_bmts = {}
local count = 1

local quotes = {
	{
		text="I recall you saying, once, that silence was a thing you couldn't do without.",
		color={0.666, 0.666, 0.8, 0},
		y=70,
	},
	{
		text="I like silence in person. I like our frequencies to vibrate without any background noise.",
		color={0.8, 0.666, 0.666, 0},
		y=140,
	},
	{
		text="It would suggest an inherent harmony.",
		color={0.666, 0.666, 0.8, 0},
		y=70,
	},
	{
		text="...",
		color={0.666, 0.666, 0.8, 0},
		y=70,
	},
	{
		text="That is a nice thought. I got pleasantly lost in it for several moments, stirred back to reality only by the blinking cursor on my screen.",
		color={0.666, 0.666, 0.8, 0},
		y=70,
	},
	{
		text="That cursor is the path to communicating with you here and now, but maybe someday we can meet via thought.\n\nYou'll send some wonderful combination of words and derail me from my computer long enough to meet you in dreams, in silence, where words via technology aren't necessary.",
		color={0.666, 0.666, 0.8, 0},
		y=70,
	},
}

local af = Def.ActorFrame{
	InitCommand=function(self) self:x(_screen.cx):diffusealpha(0) end,
	OnCommand=function(self) self:smooth(1):diffusealpha(1) end,

	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back" or event.GameButton=="MenuRight") then
			quote_bmts[count]:playcommand("FadeOut")

			if quotes[count+1] then
				count = count + 1
				quote_bmts[count]:queuecommand("FadeIn")
			else
				self:sleep(1.5):queuecommand("Transition")
			end
		end
	end,
	TransitionCommand=function(self)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
}

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/4/recalling.ogg"),
	OnCommand=function(self) self:play() end,
	TransitionCommand=function(self) self:stop() end
}

for i=1, #quotes do

	af[#af+1] = Def.BitmapText{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text=quotes[i].text,
		InitCommand=function(self)
			quote_bmts[i] = self

			self:wrapwidthpixels(max_width)
				:align(0,0)
				:xy(-self:GetWidth()/2, 70)
				:diffuse(quotes[i].color):y( quotes[i].y )
				:visible(false)
				:playcommand("Refresh")
		end,
		FadeInCommand=function(self) self:visible(true):sleep(0.5):smooth(0.65):diffusealpha(1) end,
		FadeOutCommand=function(self) self:finishtweening():smooth(0.65):diffusealpha(0):queuecommand("Hide") end,
		HideCommand=function(self) self:visible(false) end
	}

	if i==1 then
		af[#af].OnCommand=function(self) self:visible(true):sleep(1.5):smooth(1):diffusealpha(1) end
	end
end

return af