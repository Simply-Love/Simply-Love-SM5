local slc = SL.Global.ActiveColorIndex

local af = Def.ActorFrame{}

af[#af+1] = Def.Quad{
	InitCommand=cmd(zoomto,_screen.w,0; diffuse, Color.Black; Center),
	OnCommand=cmd( accelerate,0.3; zoomtoheight,128; diffusealpha,0.9; sleep,2.5; linear,0.25),
	OffCommand=cmd(accelerate,0.3; zoomtoheight,0)
}

-- loop to add 7 SM5 arrows to the primary ActorFrame
for i=1,7 do
	af[#af+1] = Def.ActorFrame {
		InitCommand=function(self) self:Center() end,

		LoadActor("white_logo.png")..{
			InitCommand=cmd(zoom, 0.1; diffuse, GetHexColor(slc-i-3); diffusealpha,0; x, (i-4)*50 ),
			OnCommand=cmd(sleep, i*0.1 + 0.2; linear,0.75; diffusealpha,1; linear,0.75;diffusealpha,0)
		},
		LoadActor("highlight.png")..{
			InitCommand=cmd(zoom,0.1; diffusealpha,0; x, (i-4)*50),
			OnCommand=cmd(sleep, i*0.1 + 0.2; linear,0.75; diffusealpha,0.75; linear,0.75;diffusealpha,0)
		}
	}
end

af[#af+1] = Def.BitmapText{
	Font="_miso",
	Text=ScreenString("ThemeDesign"),
	InitCommand=cmd(diffuse,GetHexColor(slc); diffusealpha,0; Center),
	OnCommand=cmd(sleep,3;linear,0.25;diffusealpha,1),
	OffCommand=cmd(linear, 0.25; diffusealpha,0),
}

return af