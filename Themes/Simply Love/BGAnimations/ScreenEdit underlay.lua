local t = Def.ActorFrame{
	Name="Text",

	EditCommand=cmd(playcommand, "Show"),

	PlayingCommand=cmd(playcommand, "Hide"),
	RecordCommand=cmd(playcommand, "Hide"),
	RecordPausedCommand=cmd(playcommand, "Hide"),

	-- Info
	Def.ActorFrame{
		InitCommand=cmd(xy, _screen.w-60, 16),
		ShowCommand=cmd(decelerate, 0.1; x, _screen.w-60),
		HideCommand=cmd(accelerate, 0.1; x, _screen.w+60),

		LoadFont("_miso") .. {
			Name="InfoText",
			Text=THEME:GetString("ScreenEdit","Info"),
			InitCommand=cmd(zoom, 0.75)
		},
		Def.Quad{
			InitCommand=cmd(y,12; zoomto,120,1)
		}
	}
}

local sections = {
	NavigationHelp = 0,
	NoteWritingHelp = 106,
	MenuHelp = 254,
	RecordModeHelp = 332,
	KeyMappingHelp = 394,
	MiscHelp = 430
}

for section, offset in pairs(sections) do
	t[#t+1] = Def.ActorFrame{
		Name=section,
		InitCommand=cmd(xy, 0, offset; diffusealpha, 0),
		OnCommand=cmd(queuecommand, "Show"),
		ShowCommand=cmd(visible, true; decelerate, 0.2; diffusealpha, 1),
		HideCommand=cmd(diffusealpha, 0; visible, false),

		LoadFont("_wendy small")..{
			Text=THEME:GetString("ScreenEdit", section.."Label"),
			InitCommand=cmd(zoom, 0.265; horizalign, left; xy, 35, 10; diffuse, PlayerColor(PLAYER_1))
		},
		Def.Quad{
			InitCommand=cmd(y,10; zoomto,30,1; horizalign, left; diffusealpha,0.75 )
		},
		LoadFont("_miso")..{
			Text=THEME:GetString("ScreenEdit", section.."Text"),
			InitCommand=cmd(y, 14; zoom, 0.6; horizalign, left; xy, 10, 20; vertalign, top; vertspacing, -1 ),
		},
	}
end

return t