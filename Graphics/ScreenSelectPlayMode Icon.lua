local gc = Var("GameCommand")
local index = gc:GetIndex()
local text = gc:GetName()

-- text description of each mode ("casual", "competitive", "stomperz", "marathon")
return LoadFont("_wendy small")..{
	Name="ModeName"..index,
	InitCommand=cmd( halign,1; maxwidth, 256 ),
	Text=THEME:GetString("ScreenSelectPlayMode", text),
	
	GainFocusCommand=cmd(stoptweening; linear,0.1; zoom,0.75; diffuse, PlayerColor(PLAYER_1) ),
	LoseFocusCommand=cmd(stoptweening; linear,0.1; zoom,0.3; diffuse, color("#888888")),
	OffCommand=function(self)
		self:linear(0.2):diffusealpha(0)
	end
}