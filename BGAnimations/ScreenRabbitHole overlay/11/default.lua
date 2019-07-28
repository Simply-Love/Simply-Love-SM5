-- A troubled sea.

local max_width = 450
local quote_bmts = {}
local quote_line
local font_zoom = 0.975
local count = 1
local bgm_volume = 1

local quotes = {
	"But the wicked are like a troubled sea\nthat knows no rest\nwhose waves cast up mire and mud.",
	"I always want to retroactively apply the question \"why,\" despite what actually occurs in the moment. After waking, I try to re-imagine myself asking why.\n\nWhy are you doing this?\nWhy can't I move?\nWhy are you holding me down? \nWhy are you putting your mouth on me? \nWhy can't I scream?\nWhy?",
	"The truth is that in the moment, I don't pause to ask why. Maybe there isn't time, or maybe I'm too taken by panic to reason. I don't know.\n\nThe reality is that there are only raw emotions and non-verbal feelings.",
	"It starts as discomfort as I gain awareness that you are holding me down. It doesn't matter how I got here; I am here again.\n\nThe discomfort quickly rises within me, transforming to fear as I understand that I cannot move a muscle. My arms, my legs, my mouth–all unable to respond. Fear overwhelms me so quickly, as though I am a drinking glass being filled with a terrible ocean.",
	"Is it instantaneous? The question is meaningless. There is no understanding of time here. The previous fear gives way to new terror. What was the previous thing that happened? The previous feeling I experienced? They are gone, one moment violently torn away by the furious storm as a new one is swept in to replace it.",
	"You are on me, sucking on me, pulling me as an undercurrent does, and it is now that language finally breaks through into my consciousness: no.\n\nNo no no no no no NO.\n\nI cannot speak it, I cannot control the muscles in my lips to scream it, but that is how it takes form in my mind. I am motionless, powerless, I lack bodily autonomy. I want to scream, but I cannot. I want to fight back, but I cannot.\n\nFear is now wholly consuming, and all I can comprehend. I understand that I'm going to die like this, drowning in the still-rising sea inside me, and I cannot bear any more.",
	"And I don't.\n\nI am suddenly free.\n\nAwake, in bed, vaguely aware that I have just screamed, I take note of how wet my face is, doused in a mixture of sweat and saliva.\n\nI am shaken, but alive.",
	"The effects of the adrenaline remain noticeable for ten to fifteen minutes, and I am aware of this passing of time.",
	"I am aware that I was just fighting for my survival.",
	"I am aware\nthat my life\nmust still\nmean something\nto me."
}

local af = Def.ActorFrame{
	InputEventCommand=function(self, event)
		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back" or event.GameButton=="MenuRight") then
			quote_line:playcommand("FadeOut")
			quote_bmts[count]:playcommand("FadeOut")

			if quotes[count+1] then
				count = count + 1
				quote_bmts[count]:queuecommand("FadeIn")
				if count == 6 then self:queuecommand("Fear") end
				if count == 7 then self:queuecommand("WakeUp") end
			else
				self:sleep(1.5):queuecommand("Transition")
			end
		end
	end,
	TransitionCommand=function(self)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
}

-- storm
af[#af+1] = LoadActor("./storm.ogg")..{
	OnCommand=function(self) self:play() end,
	WakeUpCommand=function(self) self:queuecommand("FadeOutAudio") end,
	FadeOutAudioCommand=function(self)
		if bgm_volume >= 0 then
			local ragesound = self:get()
			bgm_volume = bgm_volume-0.1
			if bgm_volume < 0 then bgm_volume = 0 end
			ragesound:volume(bgm_volume)
			self:sleep(0.1):queuecommand("FadeOutAudio")
		end
	end,
}

-- fear
af[#af+1] = LoadActor("./fear.ogg")..{
	FearCommand=function(self) self:play() end,
	WakeUpCommand=function(self) self:stop() end
}

-- fear2
af[#af+1] = LoadActor("./fear2.ogg")..{
	FearCommand=function(self) self:play() end,
	WakeUpCommand=function(self) self:stop() end
}

-- thunder
af[#af+1] = LoadActor("./thunder.ogg")..{
	WakeUpCommand=function(self) self:play() end
}

for i=1, #quotes do

	af[#af+1] = Def.BitmapText{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text=quotes[i],
		InitCommand=function(self)
			quote_bmts[i] = self

			self:zoom(font_zoom)
				:wrapwidthpixels(max_width/font_zoom)
				:align(0,0)
				:xy((_screen.w-max_width)/2, i==1 and 130 or 60)
				:diffuse(1,1,1,0)
				:visible(false)
				:playcommand("Refresh")
		end,
		FadeInCommand=function(self) self:visible(true):sleep(0.5):smooth(0.65):diffusealpha(1) end,
		FadeOutCommand=function(self) self:finishtweening():smooth(0.65):diffusealpha(0):queuecommand("Hide") end,
		HideCommand=function(self) self:visible(false) end
	}

	if i==1 then
		af[#af].OnCommand=function(self) self:visible(true):sleep(0.5):smooth(1):diffusealpha(1) end
	end
end

-- blockquote line
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:diffuse(0.5, 0.5, 0.5, 0):valign(0); quote_line = self end,
	OnCommand=function(self)
		self:zoomto(2, quote_bmts[1]:GetHeight())
			:xy( quote_bmts[1]:GetX() - 14, quote_bmts[1]:GetY())
			:sleep(0.5):smooth(0.65):diffusealpha(1)
	end,
	FadeOutCommand=function(self) self:finishtweening():smooth(0.65):diffusealpha(0) end,
}

-- lightning
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:FullScreen():Center():diffuse(1,1,1,0) end,
	WakeUpCommand=function(self) self:diffusealpha(1):sleep(0.25):decelerate(10):diffusealpha(0) end
}

return af