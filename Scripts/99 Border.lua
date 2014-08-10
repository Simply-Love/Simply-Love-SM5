function Border(width, height, bw)
	return Def.ActorFrame {
		Def.Quad {
			InitCommand=cmd(zoomto,width-2*bw,height-2*bw;  MaskSource,true)
		},
		Def.Quad {
			InitCommand=cmd(zoomto,width,height;MaskDest)
		},
		Def.Quad {
			InitCommand=cmd(diffusealpha,0;clearzbuffer,true)
		},
	}
end