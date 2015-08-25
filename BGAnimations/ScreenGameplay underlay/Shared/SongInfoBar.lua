return Def.ActorFrame{

	-- Song Completion Meter
	Def.ActorFrame{
		Name="SongMeter",
		InitCommand=cmd(x,_screen.cx; y,20; diffusealpha,0),
		OnCommand=cmd(decelerate,0.2; diffusealpha,1),

		Def.SongMeterDisplay {
			StreamWidth=_screen.w/2-10,
			Stream=Def.Quad{ 
				InitCommand=cmd(zoomy,18; diffuse,DifficultyIndexColor(2))
			}
		},

		Border( _screen.w/2-10, 22, 2 ),
	},

	-- Song Title
	LoadFont("_miso")..{
		Name="SongTitle",
		InitCommand=cmd(zoom,0.8; shadowlength,0.6; maxwidth, _screen.w/2.5 - 10; xy, _screen.cx, 20 ),
		CurrentSongChangedMessageCommand=cmd(playcommand, "Update"),
		UpdateCommand=function(self)
			local song = GAMESTATE:GetCurrentSong()
			self:settext( song and song:GetDisplayFullTitle() )
		end
	}
}