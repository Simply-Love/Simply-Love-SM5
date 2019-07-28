local args = ...
local af = Def.ActorFrame{}
local bgm_volume = 10

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/14/connection.ogg"),
	OnCommand=function(self) self:sleep(0.5):queuecommand("Play") end,
	PlayCommand=function(self) self:stop():play() end,
	FadeOutAudioCommand=function(self)
		if bgm_volume >= 0 then
			local ragesound = self:get()
			bgm_volume = bgm_volume-1
			ragesound:volume(bgm_volume*0.1)
			self:sleep(0.1):queuecommand("FadeOutAudio")
		end
	end,
	SwitchSceneCommand=function(self) self:stop() end
}

for i=1, #args.img do
	af[#af+1] = args.img[i]
end

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/typo slab serif/_typoslabserif-light 20px.ini"),
	Text="Connection: Chapter "..args.chapter,
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy-12):diffusealpha(0):zoom(1.5) end,
	OnCommand=function(self) self:sleep(1):smooth(2):diffusealpha(1) end,
	StartScene=function(self) self:hibernate(math.huge) end
}


return af