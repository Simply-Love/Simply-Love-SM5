t = Def.ActorFrame {}

t[#t+1] = Def.Sprite {
	
	Texture="DonChan 2x2.png",
	Frame0000=0,	Delay0000=0.5,
	Frame0001=1,	Delay0001=0.5,
	Frame0002=0,	Delay0002=0.5,
	Frame0003=1,	Delay0003=0.5,
	Frame0004=0,	Delay0004=0.5,
	Frame0005=1,	Delay0005=0.5,
	Frame0006=0,	Delay0006=0.5,
	Frame0007=1,	Delay0007=0.5,
	Frame0008=0,	Delay0008=0.5,
	Frame0009=1,	Delay0009=0.5,
	Frame0010=0,	Delay0010=0.5,
	Frame0011=1,	Delay0011=0.5,
	Frame0012=0,	Delay0012=0.5,
	Frame0013=1,	Delay0013=0.5,
	Frame0014=2,	Delay0014=0.5,
	Frame0015=3,	Delay0015=0.5,

	OnCommand=function(self)
		self:effectclock("bgm")
		self:cropright(0.02)
		self:cropleft(0.02)
		self:croptop(0.02)
		self:cropbottom(0.02)
	end
	
}

return t