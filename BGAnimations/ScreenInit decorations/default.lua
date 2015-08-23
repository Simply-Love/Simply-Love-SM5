local slc = SL.Global.ActiveColorIndex
local arrowData = {
	sleep = {0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9},
	xPos = {-150, -100, -50, 0, 50, 100, 150},
	color = {slc-3, slc-2, slc-1, slc, slc+1, slc+2, slc+3}
}

local function RainbowArrows( x )

	return Def.ActorFrame {
		InitCommand=cmd(Center),

		LoadActor("white_logo.png")..{
			InitCommand=cmd(zoom,0.1; diffuse, GetHexColor(arrowData.color[x]%12+1); diffusealpha,0; x, arrowData.xPos[x] ),
			OnCommand=cmd(sleep,arrowData.sleep[x]; linear,0.75; diffusealpha,1; linear,0.75;diffusealpha,0)
		},
		LoadActor("highlight.png")..{
			InitCommand=cmd(zoom,0.1; diffusealpha,0; x, arrowData.xPos[x]),
			OnCommand=cmd(sleep,arrowData.sleep[x]; linear,0.75; diffusealpha,0.75; linear,0.75;diffusealpha,0)
		}
	}
end

local t = Def.ActorFrame {}

t[#t+1] = Def.ActorFrame {
	InitCommand=cmd(Center),

	Def.Quad {
		InitCommand=cmd(zoomto,_screen.w,0; diffuse, Color.Black),
		OnCommand=cmd( accelerate,0.3; zoomtoheight,128; diffusealpha,0.9; sleep,2.5; linear,0.25),
		OffCommand=cmd(accelerate,0.3; zoomtoheight,0)
	},

	LoadFont("_miso")..{
		Text="theme by " .. THEME:GetThemeAuthor(),
		InitCommand=cmd(diffuse,GetCurrentColor(); diffusealpha,0;),
		OnCommand=cmd(sleep,3;linear,0.25;diffusealpha,1),
		OffCommand=cmd(linear, 0.25; diffusealpha,0)
	}
}

for i=1,7 do
	t[#t+1] = RainbowArrows(i)
end

return t