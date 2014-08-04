local SongStats = SONGMAN:GetNumSongs() .. " songs in "
SongStats = SongStats .. SONGMAN:GetNumSongGroups() .. " groups, "
SongStats = SongStats .. SONGMAN:GetNumCourses() .. " courses"

local game = GAMESTATE:GetCurrentGame():GetName();
if game == "popn" or game == "beat" or game == "kb7" or game == "para" then
	game = "techno"
end

local t = Def.ActorFrame{
	InitCommand=function(self)
		--see: ./Scripts/SL_Initialize.lua
		InitializeSimplyLove()
	end,
	OnCommand=cmd(Center),
	OffCommand=cmd(linear,0.5; diffusealpha, 0)
}
	
t[#t+1] = LoadFont("_misoreg hires")..{
	Text=SongStats,
	InitCommand=cmd(zoom,0.8; y, -120; diffusealpha,0),
	OnCommand=cmd(linear,0.4; diffusealpha,1)
}	
	
t[#t+1] = LoadActor(THEME:GetPathG("", "_logos/" .. game))

t[#t+1] = LoadActor("SimplyLove.png") .. {
	InitCommand=cmd(zoom, 0.333)
}

return t