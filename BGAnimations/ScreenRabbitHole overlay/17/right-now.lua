-- And maybe you'll be there, too.

local args = ...
local delay = args.delay
local song = args.song
local body = args.body
local pause_duration = args.pauses
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

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/"..song),
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
		end
	end
}


af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
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
