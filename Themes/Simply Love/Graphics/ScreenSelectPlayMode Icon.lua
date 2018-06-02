local gc = Var("GameCommand")
local index = gc:GetIndex()
local text = gc:GetName()

-- text description of each mode ("Casual", "Competitive", "ECFA", "StomperZ")
return LoadFont("_wendy small")..{
	Name="ModeName"..index,
	InitCommand=function(self) self:halign(1):maxwidth(256) end,
	Text=ScreenString(text),

	GainFocusCommand=cmd(stoptweening; linear,0.1; zoom,0.75; diffuse, PlayerColor(PLAYER_1) ),
	LoseFocusCommand=cmd(stoptweening; linear,0.1; zoom,0.3; diffuse, color("#888888")),
	OffCommand=function(self)
		self:linear(0.2):diffusealpha(0)
	end
}