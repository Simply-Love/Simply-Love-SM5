local SongStats = SONGMAN:GetNumSongs() .. " songs in "
SongStats = SongStats .. SONGMAN:GetNumSongGroups() .. " groups, "
SongStats = SongStats .. SONGMAN:GetNumCourses() .. " courses"

local game = GAMESTATE:GetCurrentGame():GetName();
if game ~= "dance" and game ~= "pump" then
	game = "techno"
end

return Def.ActorFrame{
	InitCommand=function(self)
		--see: ./Scripts/SL_Initialize.lua
		InitializeSimplyLove()
	end,
	OnCommand=cmd(Center),
	OffCommand=cmd(linear,0.5; diffusealpha, 0),

	LoadFont("_miso")..{
		Text=SongStats,
		InitCommand=function(self)
			self:zoom(0.8):y(-120):diffusealpha(0)
		end,
		OnCommand=function(self)
			self:sleep(0.2):linear(0.4):diffusealpha(1)
		end,
	},

	LoadActor(THEME:GetPathG("", "_logos/" .. game))..{
		InitCommand=function(self)
			self:y(-16):zoom( game=="pump" and 0.2 or 0.205 )
		end
	},

	LoadActor("SimplyLove (doubleres).png") .. {
		InitCommand=cmd(x,2; zoom, 0.7)
	}
}