local index = Var("GameCommand"):GetIndex()

local t = Def.ActorFrame{}


t[#t+1] = LoadFont("_edit undo brk")..{
	Name="Choice"..index,
	Text=THEME:GetString( 'ScreenTitleMenu', Var("GameCommand"):GetText() ),

	OnCommand=cmd(diffusealpha,0; sleep,index * 0.075; linear,0.2; diffusealpha,1),
	OffCommand=cmd(sleep,index * 0.075; linear,0.18; diffusealpha, 0),

	GainFocusCommand=cmd(stoptweening; zoom,0.4; x,1; y,1; accelerate,0.1; diffuse, color("#000000"); glow,{1,1,1,0.5}; decelerate,0.05; glow,{1,1,1,0.0}; shadowlength,0.5),
	LoseFocusCommand=cmd(stoptweening; zoom,0.3; x,1; y,1; accelerate,0.1; diffuse, color("#000000"); glow,{1,1,1,0}; shadowlength,0)
}

t[#t+1] = LoadFont("_edit undo brk")..{
	Name="Choice"..index,
	Text=THEME:GetString( 'ScreenTitleMenu', Var("GameCommand"):GetText() ),

	OnCommand=cmd(diffusealpha,0; sleep,index * 0.075; linear,0.2; diffusealpha,1),
	OffCommand=cmd(sleep,index * 0.075; linear,0.18; diffusealpha, 0),

	GainFocusCommand=cmd(stoptweening; zoom,0.4; x,-1; y,1; accelerate,0.1; diffuse, color("#000000"); glow,{1,1,1,0.5}; decelerate,0.05; glow,{1,1,1,0.0}; shadowlength,0.5),
	LoseFocusCommand=cmd(stoptweening; zoom,0.3; x,-1; y,1; accelerate,0.1; diffuse, color("#000000"); glow,{1,1,1,0}; shadowlength,0)
}

t[#t+1] = LoadFont("_edit undo brk")..{
	Name="Choice"..index,
	Text=THEME:GetString( 'ScreenTitleMenu', Var("GameCommand"):GetText() ),

	OnCommand=cmd(diffusealpha,0; sleep,index * 0.075; linear,0.2; diffusealpha,1),
	OffCommand=cmd(sleep,index * 0.075; linear,0.18; diffusealpha, 0),

	GainFocusCommand=cmd(stoptweening; zoom,0.4; x,1; y,-1; accelerate,0.1; diffuse, color("#000000"); glow,{1,1,1,0.5}; decelerate,0.05; glow,{1,1,1,0.0}; shadowlength,0.5),
	LoseFocusCommand=cmd(stoptweening; zoom,0.3; x,1; y,-1; accelerate,0.1; diffuse, color("#000000"); glow,{1,1,1,0}; shadowlength,0)
}

t[#t+1] = LoadFont("_edit undo brk")..{
	Name="Choice"..index,
	Text=THEME:GetString( 'ScreenTitleMenu', Var("GameCommand"):GetText() ),

	OnCommand=cmd(diffusealpha,0; sleep,index * 0.075; linear,0.2; diffusealpha,1),
	OffCommand=cmd(sleep,index * 0.075; linear,0.18; diffusealpha, 0),

	GainFocusCommand=cmd(stoptweening; zoom,0.4; x,-1; y,-1; accelerate,0.1; diffuse, color("#000000"); glow,{1,1,1,0.5}; decelerate,0.05; glow,{1,1,1,0.0}; shadowlength,0.5),
	LoseFocusCommand=cmd(stoptweening; zoom,0.3; x,-1; y,-1; accelerate,0.1; diffuse, color("#000000"); glow,{1,1,1,0}; shadowlength,0)
}

t[#t+1] = LoadFont("_edit undo brk")..{
	Name="Choice"..index,
	Text=THEME:GetString( 'ScreenTitleMenu', Var("GameCommand"):GetText() ),

	OnCommand=cmd(diffusealpha,0; sleep,index * 0.075; linear,0.2; diffusealpha,1),
	OffCommand=cmd(sleep,index * 0.075; linear,0.18; diffusealpha, 0),

	GainFocusCommand=cmd(stoptweening; zoom,0.4; accelerate,0.1; diffuse, color("#ff51b9"); glow,{1,1,1,0.5}; decelerate,0.05; glow,{1,1,1,0.0}; shadowlength,0.5),
	LoseFocusCommand=cmd(stoptweening; zoom,0.3; accelerate,0.1; diffuse, color("#afafaf"); glow,{1,1,1,0}; shadowlength,0)
}

return t