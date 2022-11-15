-- In this file, we're storing judgment offset data that occurs during gameplay so that
-- ScreenEvaluation can use it to draw both the scatterplot and the offset histogram.
--
-- Similar to PerColumnJudgmentTracking.lua, this file doesn't override or recreate the engine's
-- judgment system in any way. It just allows transient judgment data to persist beyond ScreenGameplay.
------------------------------------------------------------

-- don't bother tracking for Casual gamemode
if SL.Global.GameMode == "Casual" then return end

local player = ...
local sequential_offsets = {}
local worst_window = 1

return Def.Actor{
	JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if params.HoldNoteScore then return end

		if params.TapNoteOffset then
			-- If the judgment was a Miss, store the string "Miss" as offset instead of the number 0.
			-- For all other judgments, store the offset value provided by the engine as a number.
			local offset = params.TapNoteScore == "TapNoteScore_Miss" and "Miss" or params.TapNoteOffset
			if offset ~= "Miss" then
				local window = DetermineTimingWindow(offset)
				if window > worst_window then
					worst_window = window
				end
			end

			-- Store judgment offsets (including misses) in an indexed table as they occur.
			-- Also store the CurMusicSeconds for Evaluation's scatter plot.
			sequential_offsets[#sequential_offsets+1] = { GAMESTATE:GetCurMusicSeconds(), offset }
		end
	end,
	OffCommand=function(self)
		local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
		storage.sequential_offsets = sequential_offsets
		storage.worst_window = worst_window
	end
}