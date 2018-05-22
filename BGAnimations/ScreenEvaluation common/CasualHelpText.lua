if SL.Global.GameMode ~= "Casual" then return end

return Def.ActorFrame{
	InitCommand=function(self)
		self:diffusealpha(0):sleep(3):diffusealpha(1)
			:diffuseshift():effectperiod(3)
			:effectcolor1(0,0,0,0):effectcolor2(1,1,1,1)
	end,

	Def.BitmapText{
		Font="_wendy small",
		Text=THEME:GetString("ScreenEvaluation", "PressStartToContinue"),
		InitCommand=function(self)
			self:xy(_screen.cx, _screen.cy + 170):zoom(0.55)
		end,
	},
	Def.BitmapText{
		Font="_miso",
		Text="&START;",
		InitCommand=function(self)
			self:xy(_screen.cx-35, _screen.cy + 170):zoom(1)
		end,
	},
}