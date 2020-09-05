local af = Def.ActorFrame{}

af[#af+1] = LoadActor("./bg.png")..{
	InitCommand=function(self) self:diffuse(0,0,0,0) end,
	ShowCommand=function(self) self:smooth(2):diffuse(1,1,1,1) end,
	FadeOutCommand=function(self) self:visible(false) end
}

af[#af+1] = LoadActor("./topbar.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(2):smooth(1):diffusealpha(1) end,
	FadeOutCommand=function(self) self:visible(false) end
}

-- bottom images
for i=1,3 do
	af[#af+1] = LoadActor("./bottom" .. i .. ".png")..{
		InitCommand=function(self) self:diffusealpha(0):valign(1):y(_screen.h+60) end,
		ShowCommand=function(self) self:sleep(3.5 + (3-i)*0.35):smooth(0.65):diffusealpha(1) end,
		FadeOutCommand=function(self) self:visible(false) end
	}
end

-- profile photos
for i=1,5 do
	af[#af+1] = Def.ActorFrame{
		InitCommand=function(self) self:zoom(1) end,
		ShowCommand=function(self) self:sleep(6 + i*0.15):bounceend(0.333):zoom(1) end,
		FadeOutCommand=function(self) self:visible(false) end,

		LoadActor("./profile" .. i .. ".png")..{
			InitCommand=function(self) self:diffusealpha(0) end,
			ShowCommand=function(self) self:sleep(6 + i*0.15):smooth(0.333):diffusealpha(1) end,
		}
	}
end


-- intense topbar
af[#af+1] = Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(19):smooth(2.5):diffusealpha(1) end,
	FadeOutCommand=function(self) self:visible(false) end,

	LoadActor("./intense-topbar.png")..{
		InitCommand=function(self) self:cropbottom(0.8) end,
		ShowCommand=function(self) self:sleep(20):smooth(6):cropbottom(0) end,
	}
}

af[#af+1] = LoadActor("./bright-blue-icon.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(2.75):smooth(1):diffusealpha(1) end,
	FadeOutCommand=function(self) self:visible(false) end
}

af[#af+1] = LoadActor("./pink-bubble.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(10):smooth(0.666):diffusealpha(1) end,
	FadeOutCommand=function(self) self:visible(false) end
}

af[#af+1] = LoadActor("./text.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(11):smooth(2):diffusealpha(1) end,
	FadeOutCommand=function(self) self:visible(false) end
}


af[#af+1] = LoadActor("./modal-bg.png")..{
	InitCommand=function(self) self:diffuse(1,1,1,0) end,
	ShowCommand=function(self) self:sleep(15):smooth(1.666):diffuse(0.8,0.8,0.8,0.8):sleep(11):smooth(1):diffuse(1,1,1,0) end,
	FadeOutCommand=function(self) self:visible(false) end
}

af[#af+1] = LoadActor("./modal.png")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(15.5):smooth(1.666):diffusealpha(1):sleep(10):smooth(1):diffusealpha(0) end,
	FadeOutCommand=function(self) self:visible(false) end
}


af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/work sans light/work sans light 40px.ini"),
	Text="I like what you wrote about how winter is your favorite season.\n\nWe don't get snow here, but I'd like to hear the sound of crunchy snow under my boots very much someday, too.",
	InitCommand=function(self)
		self:zoom(1.1)
			:align(0,0)
			:wrapwidthpixels(800/1.1)
			:diffuse(0,0,0,0)
			:xy(-400,-150)
	end,
	ShowCommand=function(self) self:sleep(17):smooth(1.666):diffusealpha(1):sleep(8):smooth(1):diffusealpha(0) end,
	FadeOutCommand=function(self) self:visible(false) end
}

af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w*10, _screen.h*10):diffuse(0,0,0,0) end,
	ShowCommand=function(self) self:sleep(32):smooth(1.666):diffusealpha(1) end
}

return af