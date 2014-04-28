return Def.ActorFrame {	
	Def.Quad {
		Name="CursorTop";
		InitCommand=cmd(zoomto,1,2; y,-12;);
	},
	Def.Quad {
		Name="CursorBottom";
		InitCommand=cmd(zoomto,1,2; y,12; );
	}
};
