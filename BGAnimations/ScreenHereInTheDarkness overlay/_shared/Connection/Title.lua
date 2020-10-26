local args = ...
local bgm_volume = 10

local af = Def.ActorFrame{}
af.InitCommand=function(self) args.scenes[1] = self end
af.OnCommand=function(self) self:queuecommand("StartScene") end

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/14/connection.ogg"),
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

local ec1 = {0.4,0.4,0.4,1}
local ec2 = {0.9,0.9,0.9,0.75}

for i=1, #args.img do
	af[#af+1] = LoadActor(args.img[i])..{
		InitCommand=function(self) self:Center():zoom(2/3):diffuse(0,0,0,1) end,
		OnCommand=function(self)
			self:sleep(2):smooth(3):diffuse(ec1):queuecommand("Pulse")
		end,
		PulseCommand=function(self) self:diffuseshift():effectperiod(5):effectcolor1(ec1):effectcolor2(ec2) end,
	}
end

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/typo slab serif/_typoslabserif-light 20px.ini"),
	Text="Connection: Chapter "..args.chapter,
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy-12):diffusealpha(0):zoom(1.5) end,
	OnCommand=function(self) self:sleep(1):smooth(2):diffusealpha(1) end,
	StartScene=function(self) self:hibernate(math.huge) end
}


return af