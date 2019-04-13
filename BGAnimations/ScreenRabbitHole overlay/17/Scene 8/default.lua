-- epilogue

local song = "./Connection.ogg"
local bgm_volume = 10

local af = Def.ActorFrame{ StartSceneCommand=function(self) self:visible(true):diffuse(1,1,1,1) end }

af[#af+1] = LoadActor(song)..{
	StartSceneCommand=function(self) self:play() end,
	FadeOutAudioCommand=function(self)
		if bgm_volume >= 0 then
			local ragesound = self:get()
			bgm_volume = bgm_volume-1
			ragesound:volume(bgm_volume*0.1)
			self:sleep(0.1):queuecommand("FadeOutAudio")
		end
	end
}

local sleep_time = { 0, 15.6, 20.34, 25.632, 29.660, 39, 45, 52.125, 58.352 }

for i=1, #sleep_time do
	af[#af+1] = LoadActor("./".. i ..".lua", sleep_time[i])
end

return af