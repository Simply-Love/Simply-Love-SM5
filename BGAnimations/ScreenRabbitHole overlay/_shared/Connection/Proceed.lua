return Def.BitmapText{
	Font="Common Normal",
	Text="&START;",
	Name="Proceed",
	InitCommand=function(self)
		self:align(1,0):xy(_screen.w - 10, 10):zoom(1.5)
			:diffuseshift():effectperiod(2.5)
			:effectcolor1(0.85,0.85,0.85,0.85):effectcolor2(0.5,0.5,0.5,0.5)
			:diffusealpha(0)
	end,
	HideCommand=function(self) self:linear(0.5):diffusealpha(0) end,
	Ch4Sc3HideCommand=function(self) self:diffusealpha(0):sleep(9):queuecommand("Show") end,
	ShowCommand=function(self) self:linear(0.75):diffusealpha(1) end,
}