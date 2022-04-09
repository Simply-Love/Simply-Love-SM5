local TextColor = Color.White
LastSeenSong = nil
LastSeenCourse = nil
IsUntiedWR = false


local SongStats = SONGMAN:GetNumSongs() .. " songs in "
SongStats = SongStats .. SONGMAN:GetNumSongGroups() .. " groups, "
SongStats = SongStats .. #SONGMAN:GetAllCourses(PREFSMAN:GetPreference("AutogenGroupCourses")) .. " courses"

-- - - - - - - - - - - - - - - - - - - - -

local game = GAMESTATE:GetCurrentGame():GetName();
if game ~= "dance" and game ~= "pump" then
	game = "techno"
end

-- - - - - - - - - - - - - - - - - - - - -
local sm_version = ("%s %s"):format(ProductFamily(), ProductVersion())
local sl_version = GetThemeVersion()

-- - - - - - - - - - - - - - - - - - - - -

local af = Def.ActorFrame{
	InitCommand=function(self)
		--see: ./Scripts/SL_Initialize.lua
		InitializeSimplyLove()

		self:Center()
	end,
	OffCommand=cmd(linear,0.5; diffusealpha, 0),

	Def.ActorFrame{
		InitCommand=function(self) self:zoom(1):y(-220):diffusealpha(0) end,
		OnCommand=function(self) self:sleep(0.2):linear(0.4):diffusealpha(1) end,

		Def.BitmapText{
			Font="Miso/_miso",
			Text=sm_version,
			InitCommand=function(self) self:horizalign(left):x(_screen.cx - _screen.w/1.01):diffuse(TextColor) end,
		},
		Def.BitmapText{
			Font="Miso/_miso",
			Text=sl_version and ("Theme v"..sl_version) or "",
			InitCommand=function(self) self:horizalign(left):x(_screen.cx - _screen.w/1.01):y(20):diffuse(TextColor) end,
		},
		Def.BitmapText{
			Font="Miso/_miso",
			Text=SongStats,
			InitCommand=function(self) self:y(10):diffuse(TextColor) end,
		}
	},
}

return af