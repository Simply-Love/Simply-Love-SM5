-- There was one night, in particular, when it must have seemed unbearable.
-- She had asked me to hold her, and we spent an hour cuddling in her room,
-- two lonely children lost in sadness.
--
-- In the dream from this morning, when I apologized, she only smiled and
-- reassured me that everything was okay now.
--
-- I awoke with a start, and felt quite certain, quite suddenly, that if
-- there were a heaven, that would have been it.

local max_width = 350
local quote_bmts = {}
local count = 1
local quotes = {
	{
		text="What happens when we get there,\nthe place where the hallway ends?",
		color={0.8, 0.666, 0.666, 0},
		y=140,
	},
	{
		text="For me anyway, it's a combination of understanding and being understood, forgiving and being forgiven.\n\nThe people I harmed are okay and better than ever, I forgive the man who hurts me in my dreams, and we all laugh about how silly it was to have held onto to so much pain for so long.",
		color={0.666, 0.666, 0.8, 0},
		y=70,
	},
	{
		text="Will we find each other there?",
		color={0.8, 0.666, 0.666, 0},
		y=140,
	},
	{
		text="If I found you there, I'd smile to finally see you as you are–your mind, your physical form, you, all at once, in color and motion, with sound and texture.",
		color={0.666, 0.666, 0.8, 0},
		y=70,
	},
	{
		text="I look forward to it.",
		color={0.8, 0.666, 0.666, 0},
		y=140,
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

af[#af+1] = LoadActor("./I5.ogg")..{
	OnCommand=function(self) self:play() end,
	TransitionCommand=function(self) self:stop() end
}

for i=1, #quotes do

	af[#af+1] = Def.BitmapText{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
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