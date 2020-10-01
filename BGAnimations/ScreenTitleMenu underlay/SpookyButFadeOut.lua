local af = Def.ActorFrame{}
af.InitCommand=function(self) self:diffusealpha(0) end
af.OnCommand=function(self)   self:sleep(0.25):smooth(0.75):diffusealpha(1) end
af.OffCommand=function(self)  self:finishtweening() end

-- top left
af[#af+1] = LoadActor(THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/Cobweb (doubleres).png"))..{
	InitCommand=function(self)
		self:align(0,0):xy(_screen.w * -0.615, _screen.h * -0.65)
		self:rotationz(15):zoom(SL_WideScale(0.8,1))
	end
}

-- top right
af[#af+1] = LoadActor(THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/Cobweb (doubleres).png"))..{
	InitCommand=function(self)
		self:align(0,0):xy(_screen.w * 0.475, _screen.h * -0.71)
		self:rotationy(180):rotationx(180):rotationz(-120):zoom(SL_WideScale(0.8,1))
	end
}

return af