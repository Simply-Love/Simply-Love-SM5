-- start with the same header used for ScreenSelectMusic
local header = LoadActor(THEME:GetPathG("ScreenSelectMusic", "header.lua"))

-- and append an additional, very important OffCommand
--
-- the SL table maintains its own sense of "how many songs have been played this game session?"
-- independent of anything the engine provides
--
-- a LOT of things throughout the Simply Love theme depend on this value
-- for example, tables of judgment data for the entire game session are indexed
-- using SL.Global.Stages.PlayedThisGame for later retrieval in ScreenEvaluationSummary
--
-- we wait until OffComand to increment this value
--
-- we could increment immediately at Init, but that makes debugging difficult
-- (I tend to reload screens frequently while testing via F3+F6 then F3+2, and don't
--  want this value to continually increment each time I happen to reload ScreenEval.)

header.OffCommand=function(self)
	SL.Global.Stages.PlayedThisGame = SL.Global.Stages.PlayedThisGame + 1
end

return header