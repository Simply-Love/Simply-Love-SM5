local Player = ...;
local profile = PROFILEMAN:GetProfile(Player);
local playerName = profile:GetLastUsedHighScoreName();
local totalSongs = profile:GetNumTotalSongsPlayed();
local caloriesToday = round(profile:GetCaloriesBurnedToday());

local stageStats = STATSMAN:GetCurStageStats();
local currentCombo = stageStats:GetPlayerStageStats(Player):GetCurrentCombo()

local x_pos;

if Player == PLAYER_1 then
	x_pos = 80;
elseif Player == PLAYER_2 then
	x_pos = _screen.w-80;
end

 
local t = Def.ActorFrame{};

t[#t+1] = LoadFont("_miso")..{
	Text=playerName;
	InitCommand=cmd(diffuse, PlayerColor(Player); xy, x_pos, 40);
};

t[#t+1] = LoadFont("_miso")..{
	Text="Calories Today:\n"..caloriesToday;
	InitCommand=cmd(diffuse, PlayerColor(Player); xy, x_pos, 100);
};

t[#t+1] = LoadFont("_miso")..{
	Text="Current Combo:\n"..currentCombo;
	InitCommand=cmd(diffuse, PlayerColor(Player); xy, x_pos, 160);
};

t[#t+1] = LoadFont("_miso")..{
	Text="Total Songs Played:\n"..totalSongs;
	InitCommand=cmd(diffuse, PlayerColor(Player); xy, x_pos, 220);
};

return t;