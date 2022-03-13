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

return Def.Actor{
	JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if params.HoldNoteScore then return end

		if params.TapNoteOffset then
			-- If the judgment was a Miss, store the string "Miss" as offset instead of the number 0.
			-- For all other judgments, store the offset value provided by the engine as a number.
			local offset = params.TapNoteScore == "TapNoteScore_Miss" and "Miss" or params.TapNoteOffset

			-- Store judgment offsets (including misses) in an indexed table as they occur.
			-- Also store the CurMusicSeconds for Evaluation's scatter plot.
			sequential_offsets[#sequential_offsets+1] = { GAMESTATE:GetCurMusicSeconds(), offset }

			-- Only check/update FA+ count if we received a TNS in the top window.
			if params.TapNoteScore == "TapNoteScore_W1" and SL.Global.GameMode == "ITG"  then
				local prefs = SL.Preferences["FA+"]
				local scale = PREFSMAN:GetPreference("TimingWindowScale")
				local W0 = prefs["TimingWindowSecondsW1"] * scale + prefs["TimingWindowAdd"]

				local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]

				offset = math.abs(offset)
				if offset <= W0 then
					-- Initialized in ScreenGameplay overlay/default.lua
					storage.W0_count = storage.W0_count + 1
				end
			end
		end
	end,
	OffCommand=function(self)
		local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
		storage.sequential_offsets = sequential_offsets
	end
}