local slc = SL.Global.ActiveColorIndex

local RainbowArrows = function( x )

	return Def.ActorFrame {
		InitCommand=function(self) self:Center() end,

		LoadActor("white_logo.png")..{
			InitCommand=cmd(zoom, 0.1; diffuse, GetHexColor(slc-x-3); diffusealpha,0; x, (x-4)*50 ),
			OnCommand=cmd(sleep, x*0.1 + 0.2; linear,0.75; diffusealpha,1; linear,0.75;diffusealpha,0)
		},
		LoadActor("highlight.png")..{
			InitCommand=cmd(zoom,0.1; diffusealpha,0; x, (x-4)*50),
			OnCommand=cmd(sleep, x*0.1 + 0.2; linear,0.75; diffusealpha,0.75; linear,0.75;diffusealpha,0)
		}
	}
end

local af = Def.ActorFrame{}

af[#af+1] = Def.Quad{
	InitCommand=cmd(zoomto,_screen.w,0; diffuse, Color.Black; Center),
	OnCommand=cmd( accelerate,0.3; zoomtoheight,128; diffusealpha,0.9; sleep,2.5; linear,0.25),
	OffCommand=cmd(accelerate,0.3; zoomtoheight,0)
}

af[#af+1] = LoadFont("_miso")..{
	Text="theme by " .. THEME:GetThemeAuthor(),
	InitCommand=cmd(diffuse,GetHexColor(slc); diffusealpha,0; Center),
	OnCommand=cmd(sleep,3;linear,0.25;diffusealpha,1),
	OffCommand=cmd(linear, 0.25; diffusealpha,0)
}

-- loop to add 7 SM5 arrows to the primary ActorFrame
for i=1,7 do
	af[#af+1] = RainbowArrows(i)
end

return af