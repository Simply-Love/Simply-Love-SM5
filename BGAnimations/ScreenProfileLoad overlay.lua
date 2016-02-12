local tweentime = 0.325

return Def.ActorFrame{
	InitCommand=function(self)
		self:Center():draworder(101)
	end,

	Def.Quad{
		Name="FadeToBlack",
		InitCommand=function(self)
			self:horizalign(right):vertalign(bottom)
			self:diffuse(0,0,0,0):FullScreen()
		end,
		OnCommand=function(self)
			self:sleep(tweentime):linear(tweentime):diffusealpha(1)
		end
	},

	Def.Quad{
		Name="HorizontalWhiteSwoosh",
		InitCommand=function(self)
			self:horizalign(center):vertalign(middle)
			self:zoomto(_screen.w + 100,50):faderight(0.1):fadeleft(0.1):cropright(1)
		end,
		OnCommand=function(self)
			self:linear(tweentime):cropright(0):sleep(tweentime)
			self:linear(tweentime):cropleft(1)
			self:sleep(0.1):queuecommand("Load")
		end,
		LoadCommand=function(self)
			SCREENMAN:GetTopScreen():Continue()
		end
	},

	Def.BitmapText{
		Font="_wendy small",
		Text=THEME:GetString("ScreenProfileLoad","Loading Profiles..."),
		InitCommand=function(self)
			self:diffuse(Color.Black):zoom(0.6)
		end
	}
}