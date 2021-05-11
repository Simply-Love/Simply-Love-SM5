---- this is to calculate the average bpm/difficulty but not let it increment unless the song was finished. HELP ----
local SongInSet = SL.Global.Stages.PlayedThisGame
local SongsInSet = SongInSet + 1
local P1 = GAMESTATE:IsHumanPlayer(PLAYER_1)
local P2 = GAMESTATE:IsHumanPlayer(PLAYER_2)


-- insert more junk for calculating average difficulty here
local PlayerOneChart = GAMESTATE:GetCurrentSteps(0)
local PlayerTwoChart = GAMESTATE:GetCurrentSteps(1)

local PlayerOneDifficulty = PlayerOneChart:GetMeter()
local PlayerTwoDifficulty = PlayerTwoChart:GetMeter()

local PlayerOneREALDifficulty = ""
local PlayerTwoREALDifficulty = ""

if SongInSet == 0 or nil then
TotalDifficultyPlayer1 = 0
TotalDifficultyPlayer2 = 0
else
end

-- Have the BPM based off PeakNPS instead to get the 16th equivalent BPM for things with 24th/32nd stream etc.
local MusicRate = SL.Global.ActiveModifiers.MusicRate

if P1 then
PlayerOneNPS = SL["P1"].Streams.PeakNPS
PlayerOneTrueBPM = (PlayerOneNPS * 15) * MusicRate
end

if P2 then
PlayerTwoNPS = SL["P2"].Streams.PeakNPS
PlayerTwoTrueBPM = (PlayerTwoNPS * 15) * MusicRate
end


---------- Only do these if the player is currently active or else things will get messy. ----------
if P1 then
-- This is to prevent meme rated charts from breaking the average significantly and give a slight rating boost for rate mods.
	if PlayerOneDifficulty > 40 then
		PlayerOneDifficulty = 10
		if MusicRate == 1 then
			PlayerOneREALDifficulty = PlayerOneDifficulty
		else
			PlayerOneREALDifficulty = (PlayerOneDifficulty - (PlayerOneDifficulty/MusicRate)) + PlayerOneDifficulty
		end
	else
		if MusicRate == 1 then
			PlayerOneREALDifficulty = PlayerOneDifficulty
		else
			PlayerOneREALDifficulty = (PlayerOneDifficulty - (PlayerOneDifficulty/MusicRate)) + PlayerOneDifficulty
		end
	end

P1SongsInSet = P1SongsInSet + 1
TotalBPMPlayer1 = PlayerOneTrueBPM + TotalBPMPlayer1
AverageBPMPlayer1 = TotalBPMPlayer1 / P1SongsInSet
TotalDifficultyPlayer1 = PlayerOneREALDifficulty + TotalDifficultyPlayer1
AverageDifficultyPlayer1 = TotalDifficultyPlayer1 / P1SongsInSet
end

if P2 then
-- This is to prevent meme rated charts from breaking the average significantly and give a slight rating boost for rate mods.
	if PlayerTwoDifficulty > 40 then
		PlayerTwoDifficulty = 10
		if MusicRate == 1 then
			PlayerTwoREALDifficulty = PlayerTwoDifficulty
		elseif MusicRate > 1 then
			PlayerTwoREALDifficulty = (PlayerTwoDifficulty - (PlayerTwoDifficulty/MusicRate)) + PlayerTwoDifficulty
		end
	else
		if MusicRate == 1 then
			PlayerTwoREALDifficulty = PlayerTwoDifficulty
		elseif MusicRate > 1 then
			PlayerTwoREALDifficulty = (PlayerTwoDifficulty - (PlayerTwoDifficulty/MusicRate)) + PlayerTwoDifficulty
		end
	end
P2SongsInSet = P2SongsInSet + 1
TotalBPMPlayer2 = PlayerTwoTrueBPM + TotalBPMPlayer2
AverageBPMPlayer2 = TotalBPMPlayer2 / P2SongsInSet
TotalDifficultyPlayer2 = PlayerTwoREALDifficulty + TotalDifficultyPlayer2
AverageDifficultyPlayer2 = TotalDifficultyPlayer2 / P2SongsInSet
end

-- Update stats
local song = GAMESTATE:GetCurrentSong()
if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
	DDStats.SetStat(PLAYER_1, 'LastSong', song:GetSongDir())
	DDStats.SetStat(PLAYER_1, 'LastDifficulty', PlayerOneChart:GetDifficulty())
	DDStats.Save(PLAYER_1)
end

if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	DDStats.SetStat(PLAYER_2, 'LastSong', song:GetSongDir())
	DDStats.SetStat(PLAYER_2, 'LastDifficulty', PlayerTwoChart:GetDifficulty())
	DDStats.Save(PLAYER_2)
end

return Def.ActorFrame { }
