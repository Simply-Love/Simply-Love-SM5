t = Def.ActorFrame {}

t[#t+1] = Def.Sprite {
	
	Texture="AmongUs 3x2.png",
	Frame0000=1,	Delay0000=0.125,
	Frame0001=2,	Delay0001=0.1875,
	Frame0002=3,	Delay0002=0.1875,
	Frame0003=4,	Delay0003=0.1875,
	Frame0004=5,	Delay0004=0.1875,
	Frame0005=0,	Delay0005=0.125,
	OnCommand=function(self)
		self:effectclock("bgm")
		self:cropright(0.02)
		self:cropleft(0.02)
		self:croptop(0.02)
		self:cropbottom(0.02)
		self:zoom(0.5)
	end
	
}

return t