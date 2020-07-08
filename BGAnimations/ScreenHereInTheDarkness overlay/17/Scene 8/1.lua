local cursor
local typing = {
	delay = 0.04,
	text={
		"I had a dream last night.",
		"In it,",
		"we were both still young."
	}
}

return Def.ActorFrame{
	StartSceneCommand=function(self) self:sleep(13.607):queuecommand("FadeOut") end,
	FadeOutCommand=function(self)
		self:smooth(2):diffuse(0,0,0,0):queuecommand("Hide")
		cursor:diffuse(0,0,0,0)
	end,
	HideCommand=function(self) self:visible(false) end,

	-- cursor
	Def.Quad{
		InitCommand=function(self) self:Center():zoomto(_screen.w, _screen.w*40):diffuse(1,1,1,1); cursor=self end,
		StartSceneCommand=function(self) self:sleep(1):accelerate(4.143):zoomto(3,40):xy(100,92):queuecommand("Blink") end,
		BlinkCommand=function(self) self:diffuseblink():effectperiod(1):effectcolor1(0,0,0,1):effectcolor2(1,1,1,1) end,
		FadeOutAudioCommand=function(self) self:accelerate(1.75):diffuse(1,1,1,1) end
	},

	-- "I had a dream last night."
	Def.BitmapText{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/monaco/_monaco 20px.ini"),
		Text="",
		InitCommand=function(self) self:xy(100,100):halign(0):zoom(1.25) end,
		StartSceneCommand=function(self) self:sleep(7.286):queuecommand("Type") end,
		TypeCommand=function(self)
			if typing.text[1]:len() > self:GetText():len() then
				self:settext( typing.text[1]:sub(0,self:GetText():len()+1) ):sleep( typing.delay ):queuecommand("Type")
				cursor:addx(15)
			end
		end
	},

	-- "In it,"
	Def.BitmapText{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/monaco/_monaco 20px.ini"),
		Text="",
		InitCommand=function(self) self:xy(100,140):halign(0):zoom(1.25) end,
		StartSceneCommand=function(self)
			self:sleep(11.357):queuecommand("Type")
		end,
		TypeCommand=function(self)
			if self:GetText():len() == 0 then
				cursor:xy(100,132)
			end
			if typing.text[2]:len() > self:GetText():len() then
				self:settext( typing.text[2]:sub(0,self:GetText():len()+1) ):sleep( typing.delay ):queuecommand("Type")
				cursor:addx(15)
			end
		end
	},

	-- " we were both still young."
	Def.BitmapText{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/monaco/_monaco 20px.ini"),
		Text="",
		InitCommand=function(self) self:xy(205,140):halign(0):zoom(1.25) end,
		StartSceneCommand=function(self)
			self:sleep(12.536):queuecommand("Type")
		end,
		TypeCommand=function(self)
			if self:GetText():len() == 0 then
				cursor:xy(205,132)
			end
			if typing.text[3]:len() > self:GetText():len() then
				self:settext( typing.text[3]:sub(0,self:GetText():len()+1) ):sleep( typing.delay ):queuecommand("Type")
				cursor:addx(15)
			end
		end
	},
}