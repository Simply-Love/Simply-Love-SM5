local SongStats = SONGMAN:GetNumSongs() .. " songs in ";
SongStats = SongStats .. SONGMAN:GetNumSongGroups() .. " groups, ";
SongStats = SongStats .. SONGMAN:GetNumCourses() .. " courses";


local t = Def.ActorFrame{
	InitCommand=function(self)
		--see: ./Scripts/SL-CustomProfiles.lua
		ResetPlayerCustomPrefs(PLAYER_1);
		ResetPlayerCustomPrefs(PLAYER_2);
	end;
	OnCommand=cmd(Center);
	OffCommand=cmd(linear,0.5; diffusealpha, 0;);
};
	
t[#t+1] = LoadFont("_misoreg hires")..{
	Text=SongStats;
	InitCommand=cmd(zoom,0.8; y, -120; diffusealpha,0);
	OnCommand=cmd(linear,0.4; diffusealpha,1);	
}	
	
t[#t+1] = LoadActor(THEME:GetPathG("", "_logos/" .. GAMESTATE:GetCurrentGame():GetName()));

t[#t+1] = LoadActor("SimplyLove.png") .. {
	InitCommand=cmd(zoom, 0.333);
};

return t;