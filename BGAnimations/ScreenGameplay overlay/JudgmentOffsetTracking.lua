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

local require_step_on_hold_heads = THEME:GetMetric("Player", "RequireStepOnHoldHeads")

return Def.Actor{
	JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if params.HoldNoteScore then return end

		local tns = params.TapNoteScore

		if params.TapNoteOffset then
			-- Store "Miss" for misses (including checkpoint misses, which the engine
			-- reports with a meaningless 0ms offset); store the engine's offset otherwise.
			local offset = (tns == "TapNoteScore_Miss" or tns == "TapNoteScore_CheckpointMiss") and "Miss" or params.TapNoteOffset

			-- A note you don't have to hit. Pump hold heads/ticks.
			local is_autohit = false
			if tns == "TapNoteScore_CheckpointHit" then
				is_autohit = true
			elseif not require_step_on_hold_heads and params.Notes then
				local only_hold_heads, found_note = true, false
				for _,tapnote in pairs(params.Notes) do
					found_note = true
					if tapnote:GetTapNoteType() ~= "TapNoteType_HoldHead" then
						only_hold_heads = false
						break
					end
				end
				is_autohit = found_note and only_hold_heads
			end

			local courseOffset = 0
			if GAMESTATE:IsCourseMode() then
				local curCourseSong = GAMESTATE:GetCourseSongIndex()
				local courseEntries = GAMESTATE:GetCurrentTrail(ToEnumShortString(player)):GetTrailEntries()

				for i=1,curCourseSong do
					courseOffset = courseOffset + courseEntries[i]:GetSong():GetLastSecond()
				end
			end

			-- Store judgment offsets (including misses) in an indexed table as they occur.
			-- Also store the CurMusicSeconds for Evaluation's scatter plot.
			sequential_offsets[#sequential_offsets+1] = { courseOffset + GAMESTATE:GetCurMusicSeconds(), offset, is_autohit }
		end
	end,
	OffCommand=function(self)
		local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
		storage.sequential_offsets = sequential_offsets
	end
}