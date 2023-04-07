local t = Def.ActorFrame{
	Name="Text",
	OnCommand=function(self) self:queuecommand("Show") end,
	EditCommand=function(self) self:playcommand("Show") end,

	PlayingCommand=function(self) self:playcommand("Hide") end,
	RecordCommand=function(self) self:playcommand("Hide") end,
	RecordPausedCommand=function(self) self:playcommand("Hide") end,

	-- Info
	Def.ActorFrame{
		InitCommand=function(self) self:xy(_screen.w, 10) end,
		ShowCommand=function(self) self:visible(true) end,
		HideCommand=function(self) self:visible(false) end,

		Def.Quad{ InitCommand=function(self) self:zoomto(30,1):horizalign(right) end },

		LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold") .. {
			Name="InfoText",
			Text=THEME:GetString("ScreenEdit", "Info"),
			InitCommand=function(self) self:zoom(0.265):horizalign(right):x(-35):diffuse(PlayerColor(PLAYER_1)) end,
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
		InitCommand=function(self) self:xy(0, offset) end,
		ShowCommand=function(self) self:visible(true) end,
		HideCommand=function(self) self:visible(false) end,

		LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
			Text=THEME:GetString("ScreenEdit", section.."Label"),
			InitCommand=function(self) self:zoom(0.265):horizalign(left):xy(35, 10):diffuse(PlayerColor(PLAYER_1)) end
		},
		Def.Quad{
			InitCommand=function(self) self:y(10):zoomto(30,1):horizalign(left):diffusealpha(0.75) end
		},
		LoadFont("Common Normal")..{
			Text=THEME:GetString("ScreenEdit", section.."Text"),
			InitCommand=function(self) self:xy(10, 20):zoom(0.6):horizalign(left):vertalign(top):vertspacing(-1) end,
		},
	}
end

return t