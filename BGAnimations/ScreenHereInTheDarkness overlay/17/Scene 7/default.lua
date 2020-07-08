-- And maybe you'll be there, too.

local delay = 0.068
local song = "./and-maybe-you'll-be-there-too.ogg"
local body = { "So.\n\n", "Right NOW I've just got back from work. I'm lying in bed.\nIt's satisfying.\n\n", "I love that part before sleep where your mind just\nstretches and moans, waiting to fall apart.\n\nI put off those amazing moments of lost thought, so I can\nread, watch TV on my laptop, whatever. I wish I could just\ngo to sleep, but something in me doesn't want to let me\nuntil the desire is uncontrollable. Until I have no choice.\n\n", "So I'm awake, cold, half-dressed. And rambling. I wrote\nyou THIS because you messaged me, and I wasn't there.\nSo I missed you again. Vicious cycle. Anyway, in about\ntwenty minutes I think I might try and get to that weird\npre-sleep head-space.\n\n", "And maybe you'll be there, too." }
local pause_duration = 2.75
local paragraph = 1

local full_body = ""
local pause_points = {}
local temp = 0
for i, paragraph in ipairs(body) do
	pause_points[i] = temp + paragraph:len()
	temp = temp + paragraph:len()
	full_body = full_body .. paragraph
end

local bgm_volume = 10
local max_width = 450
local font_zoom = 0.9

local af = Def.ActorFrame{ StartSceneCommand=function(self) self:visible(true):diffuse(1,1,1,1) end }

af[#af+1] = Def.Quad{
	InitCommand=function(self) self:Center():FullScreen():diffuse(0,0,0,1) end,
	FadeOutAudioCommand=function(self) self:accelerate(1.75):diffuse(1,1,1,1) end
}

af[#af+1] = LoadActor(song)..{
	StartSceneCommand=function(self) self:sleep(0.5):queuecommand("Play") end,
	PlayCommand=function(self)
		self:play()
	end,
	FadeOutAudioCommand=function(self)
		if bgm_volume >= 0 then
			local ragesound = self:get()
			bgm_volume = bgm_volume-1
			ragesound:volume(bgm_volume*0.1)
			self:sleep(0.1):queuecommand("FadeOutAudio")
		else
			self:stop()
		end
	end
}


af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	InitCommand=function(self)
		self:align(0,0):xy(_screen.cx - max_width/2, 25)
			:diffuse(1,1,1,1)
			:zoom(font_zoom)
			:wrapwidthpixels(max_width/font_zoom)
	end,
	StartSceneCommand=function(self)
		self:sleep(3):queuecommand("Type")
	end,
	TypeCommand=function(self)
		if full_body:len() > self:GetText():len() then

			self:settext( full_body:sub(1, self:GetText():len()+1) )
			if self:GetText():len() == pause_points[paragraph] then
				paragraph = paragraph + 1
				if body[paragraph] then
					self:sleep(pause_duration):queuecommand("Type")
				end
			else
				self:sleep( delay ):queuecommand("Type")
			end
		end
	end
}

return af
