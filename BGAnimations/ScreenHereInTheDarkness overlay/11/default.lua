-- I wish my mind could keep track of all my parts all the time.
--
-- Maybe I'd interact with other people less destructively. Maybe
-- I'd ruminate and obsess less. Maybe I'd finally find the words
-- to describe the recurring moment in which I find my mind back
-- in my body.
--
-- Maybe it's this disconnect that helps others find rest in sleep.
-- It seems like most people can laugh and forget, or at least let
-- go.
--
-- My body rests but my mind is on high alert. Actual nightmares
-- are infrequent, but there's always the worry that I'll find
-- myself back there and spend my dream hours fighting.
--
-- There is no way to describe the hours that follow a nightmare.
-- The specific details wither upon waking, but the residue of
-- unconscious panic lingers invisibly on my body during those
-- hours I am expected to be in control.
--
-- There is a heaviness to this that cannot be conveyed with words,
-- like how math can only model gravity but never feel it.
-- ---------------------------------------------------------------

-- a troubled sea 🌊

local max_width = 400
local quote_bmts = {}
local quote_line
local font_zoom = 0.975
local count = 1
local bgm_volume = 1

local time_at_start, storm_audio
local storm_loops = 1

local onset, panic
local will_to_fight = 22.5

local update = function(af, dt)
	if count >= 7 then return end

	-- loop storm.ogg while needed
	if type(time_at_start) == "number" then
		if (GetTimeSinceStart() - time_at_start) > (120 * storm_loops) then
			storm_audio:queuecommand("On")
			storm_loops = storm_loops + 1
		end
	end

	if count == 6 then
		panic = GetTimeSinceStart() - onset
		local mag = 0

		if panic > will_to_fight then
			af:queuecommand("Next")

		-- squared ramp isn't quite right; this is awkward but good enough
		elseif panic < 17 then
			mag = scale(panic, 0, 17, 0, 1.25)
		elseif panic >= 16 and panic < 20 then
			mag = scale(panic, 17, will_to_fight, 1.25, 5)
		elseif panic >= 20 then
			mag = scale(panic, 20, will_to_fight, 5, 50)
		end

		quote_bmts[6]:vibrate():effectmagnitude(mag, mag, mag)
	end
end

local quotes = {
	"But the wicked are like a troubled sea\nthat knows no rest\nwhose waves cast up mire and mud.",
	"I always want to retroactively apply the question \"why,\" despite what actually occurs in the moment.\n\nAfter waking, I try to imagine myself asking why.\n\nWhy are you doing this?\nWhy can't I move?\nWhy are you holding me down? \nWhy are you putting your mouth on me? \nWhy can't I scream?\nWhy?",
	"The truth is that in the moment, I don't pause to ask why. Maybe there isn't time, or maybe I'm too taken by panic to reason. I don't know.\n\nThe reality is that there are only raw emotions and non-verbal feelings.",
	"It starts as recognition as I gain awareness that you are holding me down. It doesn't matter how I got here; I am here again.\n\nDread rapidly bubbles up as I understand that I cannot move a muscle.\n\nMy arms, my legs, my mouth–all unable to respond. It overwhelms me so quickly, as though I am being filled with a terrible ocean.",
	"Is it instantaneous? I don't even know. There is no sense of time here. The previous fear gives way to new panic.\n\nWhat was it that just happened? The moment before. The way I got here again.\n\nEverything is gone, again and again, this moment violently torn away by the furious storm as a new one is swept in to replace it.",
	"You are on top of me, sucking on me, pulling me as an undercurrent does, and it is now that language finally breaks through into my consciousness: no.\n\nno no no no no no NO\n\nI cannot speak it, I cannot control the muscles in my lips to scream it, but that is how it takes form in my mind. I am motionless. Powerless. My bodily autonomy is gone. I want to scream, but I cannot. I want to fight back, but I cannot.\n\nPanic is wholly consuming, and all I can comprehend. I understand that I'm going to die like this, drowning in the still-rising sea inside me, and I cannot bear any more.",
	"And I don't.\n\nI'm suddenly free.\n\nAwake, in bed, vaguely aware that I have just screamed, I take note of how wet my face is,\ndoused in a mixture of sweat and saliva.\n\nI am shaken, but alive.",
	"The effects of the adrenaline remain noticeable for ten to fifteen minutes,\nand I am aware of this passing of time.",
	"I am aware that I was just fighting for my survival.",
	"I am aware\nthat my life\nmust still\nmean something\nto me."
}

local af = Def.ActorFrame{}

af.InitCommand=function(self)
	self:SetUpdateFunction( update )
end
af.OnCommand=function()
	time_at_start = GetTimeSinceStart()
end

af.InputEventCommand=function(self, event)
	if event.type == "InputEventType_FirstPress"
	and (event.GameButton=="Start" or event.GameButton=="Back" or event.GameButton=="MenuRight")
	and count ~= 6 then
		self:queuecommand("Next")
	end
end

af.NextCommand=function(self)
	quote_line:playcommand("FadeOut")
	quote_bmts[count]:playcommand("FadeOut")

	if quotes[count+1] then
		count = count + 1
		quote_bmts[count]:queuecommand("FadeIn")
		if count == 6 then self:queuecommand("Fear") end
		if count == 7 then self:queuecommand("WakeUp") end
	else
		self:sleep(1.5):queuecommand("NextScreen")
	end
end

af.FearCommand=function()
	onset = GetTimeSinceStart()
end

af.NextScreenCommand=function(self)
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end


-- storm
af[#af+1] = LoadActor("./storm.ogg")..{
	InitCommand=function(self) storm_audio = self end,
	OnCommand=function(self) self:play() end,
	WakeUpCommand=function(self) self:stop() end
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

-- fear3
af[#af+1] = LoadActor("./fear3.ogg")..{
	FearCommand=function(self) self:play() end,
	WakeUpCommand=function(self) self:stop() end
}

-- thunder
af[#af+1] = LoadActor("./thunder.ogg")..{
	WakeUpCommand=function(self) self:play() end
}

-- background
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:FullScreen():Center():diffuse(0,0,0,1) end,
	FearCommand=function(self) self:sleep(18):accelerate(5):diffuse(1,0.1,0.12,1) end,
	WakeUpCommand=function(self) self:finishtweening():diffuse(0,0,0,1) end
}

for i=1, #quotes do

	af[#af+1] = Def.BitmapText{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
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
		FadeInCommand=function(self)
			self:stopeffect():finishtweening():visible(true):sleep(0.5):smooth(0.65):diffuse(1,1,1,1)
			if count == 6 then self:accelerate(will_to_fight):diffuse(0.85,0.15,0.175,1) end
		end,
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