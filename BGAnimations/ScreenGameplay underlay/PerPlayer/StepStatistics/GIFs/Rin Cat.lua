t = Def.ActorFrame {}

t[#t+1] = Def.Sprite {
	
	Texture="Rin Cat 2x3.png",
	Frame0000=2,	Delay0000=0.3333333333333333,
	Frame0001=3,	Delay0001=0.3333333333333333,
	Frame0002=4,	Delay0002=0.3333333333333334,
	Frame0003=5,	Delay0003=0.3333333333333333,
	Frame0004=0,	Delay0004=0.3333333333333333,
	Frame0005=1,	Delay0005=0.3333333333333334,
	
	OnCommand=function(self)
		self:effectclock("bgm")
		-- self:cropright(0.02)
		-- self:cropleft(0.02)
		-- self:croptop(0.02)
		-- self:cropbottom(0.02)
		self:zoom(0.6)
	end
	
}

return t