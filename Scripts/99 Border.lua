function Border(width, height, bw)
	return Def.ActorFrame {
		Def.Quad {
			--diffusing color("0,0,0,0.01") is a(n unfortunately) necessary workaround
			--because normal masking is broken in Mac OS builds of SM5 as of OS X 10.9
			InitCommand=cmd(zoomto,width-2*bw,height-2*bw; diffuse,color("0,0,0,0.01"); MaskSource,true);
		},
		Def.Quad {
			InitCommand=cmd(zoomto,width,height;MaskDest);
		},
		Def.Quad {
			InitCommand=cmd(diffusealpha,0;clearzbuffer,true);
		},
	}
end