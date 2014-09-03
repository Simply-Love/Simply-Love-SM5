local index = Var("GameCommand"):GetIndex()

local t = Def.ActorFrame{}

-- this renders the text of a single choice in the scroller
t[#t+1] = LoadFont("_wendy small")..{
	Name="Choice"..index,
	Text=THEME:GetString( 'ScreenTitleMenu', Var("GameCommand"):GetText() ),

	InitCommand=cmd(zoom,0.3),
	OnCommand=cmd(diffusealpha,0; sleep,tonumber(index) * 0.075; linear,0.2;diffusealpha,1),
	OffCommand=cmd(sleep,tonumber(index) * 0.075; linear,0.18; diffusealpha, 0),

	GainFocusCommand=cmd(stoptweening; zoom,0.5; accelerate,0.15; diffuse, PlayerColor(PLAYER_2); glow,color("1,1,1,0.5");decelerate,0.05;glow,color("1,1,1,0.0")),
	LoseFocusCommand=cmd(stoptweening; zoom,0.4; accelerate,0.2; diffuse,color("#888888"); glow,color("1,1,1,0.0"))

}

return t