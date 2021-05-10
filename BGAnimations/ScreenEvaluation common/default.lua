local Players = GAMESTATE:GetHumanPlayers()
local NumPanes = 7

local InputHandler = nil
local RpgInputHandler = nil

if ThemePrefs.Get("WriteCustomScores") then
	WriteScores()
end

local t = Def.ActorFrame{Name="ScreenEval Common"}


-- add a lua-based InputCalllback to this screen so that we can navigate
-- through multiple panes of information; pass a reference to this ActorFrame
-- and the number of panes there are to InputHandler.lua
t.OnCommand=function(self)
	InputHandler = LoadActor("./InputHandler.lua", {self, NumPanes})
	RpgInputHandler = LoadActor("./Shared/RpgInputHandler.lua")
	SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
end
t.DirectInputToEngineCommand=function(self)
	SCREENMAN:GetTopScreen():RemoveInputCallback(RpgInputHandler)
	SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)

	for player in ivalues(PlayerNumber) do
		SCREENMAN:set_input_redirected(player, false)
	end
end
t.DirectInputToRpgHandlerCommand=function(self)
	SCREENMAN:GetTopScreen():RemoveInputCallback(InputHandler)
	SCREENMAN:GetTopScreen():AddInputCallback(RpgInputHandler)

	for player in ivalues(PlayerNumber) do
		SCREENMAN:set_input_redirected(player, true)
	end
end


-- This is to show style icons based on style type (1-2 Player vs Double)
if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
	t[#t+1] = LoadActor ("./4panels.png") .. {
		InitCommand=function(self)
			self:zoom(0.15)
			self:xy(550,16)
		end
	}
	t[#t+1] = LoadActor ("./4panels.png") .. {
		InitCommand=function(self)
			self:zoom(0.15)
			self:xy(585,16)
		end
	}
else
	t[#t+1] = LoadActor ("./4panels.png") .. {
		InitCommand=function(self)
			self:zoom(0.15)
			self:xy(550,16)
		end
	}
	end

-- -----------------------------------------------------------------------
-- First, add actors that would be the same whether 1 or 2 players are joined.

-- code for triggering a screenshot and animating a "screenshot" texture
t[#t+1] = LoadActor("./Shared/ScreenshotHandler.lua")

-- the title of the song and its graphical banner, if there is one
t[#t+1] = LoadActor("./Shared/TitleAndBanner.lua")

-- text to display BPM range (and ratemod if ~= 1.0) immediately under the banner
t[#t+1] = LoadActor("./Shared/BPM_RateMod.lua")

-- store some attributes of this playthrough of this song in the global SL table
-- for later retrieval on ScreenEvaluationSummary
t[#t+1] = LoadActor("./Shared/GlobalStorage.lua")

-- Guest steps
t[#t+1] = LoadActor("./GuestSteps.lua")

-- -----------------------------------------------------------------------
-- Then, load player-specific actors.

for player in ivalues(Players) do

	-- store player stats for later retrieval on EvaluationSummary and NameEntryTraditional
	-- this doesn't draw anything to the screen, it just runs some code
	t[#t+1] = LoadActor("./PerPlayer/Storage.lua", player)

	-- the per-player upper half of ScreenEvaluation, including: letter grade, nice
	-- stepartist, difficulty text, difficulty meter, machine/personal HighScore text
	t[#t+1] = LoadActor("./PerPlayer/Upper/default.lua", player)

	-- the per-player lower half of ScreenEvaluation, including:
	-- judgment scatterplot, modifier list, disqualified text
	t[#t+1] = LoadActor("./PerPlayer/Lower/default.lua", player)
end

-- -----------------------------------------------------------------------
-- Then load the Panes.

t[#t+1] = LoadActor("./Panes/default.lua", NumPanes)

-- -----------------------------------------------------------------------

-- The actor that will automatically upload scores to GrooveStats.
-- This is only added in "dance" mode and if the service is available.
-- Since this actor also spawns the RPG overlay it must go on top of everything else
t[#t+1] = LoadActor("./Shared/AutoSubmitScore.lua")

return t