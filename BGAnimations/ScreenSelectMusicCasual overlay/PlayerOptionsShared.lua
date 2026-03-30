local args = ...
local row = args[1]
local col = args[2]
local Input = args[3]

local bg_color = {0,0,0,0.9}
local divider_color = {1,1,1,0.75}

local af = Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0) end,
	SwitchFocusToSongsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
	SwitchFocusToGroupsMessageCommand=function(self) self:linear(0.1):diffusealpha(0) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:sleep(0.3):linear(0.1):diffusealpha(1) end,

	Def.Quad{
		Name="SongInfoBG",
		InitCommand=function(self) self:diffuse(bg_color):zoomto(_screen.w/WideScale(1.15,1.5), row.h) end,
		OnCommand=function(self) self:xy(_screen.cx, _screen.cy - row.h/1.6 ) end,
	},

	Def.Quad{
		Name="PlayerOptionsBG",
		InitCommand=function(self) self:diffuse(bg_color):zoomto(_screen.w/WideScale(1.15,1.5), row.h*1.5) end,
		OnCommand=function(self) self:xy(_screen.cx, _screen.cy + row.h/1.5 ) end,
	},

	Def.Quad{
		Name="PlayerOptionsDivider",
		InitCommand=function(self) self:diffuse(divider_color):zoomto(2, row.h*1.25) end,
		OnCommand=function(self) self:xy(_screen.cx, _screen.cy + row.h/1.5 ) end,
	},
}

for player in ivalues( PlayerNumber ) do
	if not GAMESTATE:IsSideJoined(player) and Input.AllowLateJoin() then
		af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
			Text=THEME:GetString("ScreenSelectMusicCasual", "PressStartToLateJoin"),
			InitCommand=function(self)
				self:xy( _screen.cx + 150 * (player==PLAYER_1 and -1 or 1), _screen.cy + 80 )
					:diffuseshift():effectcolor1(1,1,1,1):effectcolor1(1,1,1,0.5)
			end,
			PlayerJoinedMessageCommand=function(self, params)
				if params.Player == player then
					self:smooth(0.15):zoom(1.4):smooth(0.15):zoom(0)
				end
			end
		}
	end
end

return af