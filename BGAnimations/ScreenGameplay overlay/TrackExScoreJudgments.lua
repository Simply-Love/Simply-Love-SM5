-- In this file, we're keep track of judgment counts for calculating the EX score to display during
-- ScreenGameplay and ScreeEvaluation.
--
-- Similar to PerColumnJudgmentTracking.lua, this file doesn't override or recreate the engine's
-- judgment system in any way. It just allows transient judgment data to persist beyond ScreenGameplay.
------------------------------------------------------------

-- don't bother tracking for Casual gamemode
if SL.Global.GameMode == "Casual" then return end

local player = ...

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]

local valid_tns = {
	-- Emulated, not a real TNS.
	W0 = true,
	W015 = true,

	-- Actual TNS's
	W1 = true,
	W2 = true,
	W3 = true,
	W4 = true,
	W5 = true,
	Miss = true,
	HitMine = true
}

local valid_hns = {
	LetGo = true,
	Held = true
}

return Def.Actor{
	OnCommand=function(self)
		storage.ex_counts = {
			-- These counts are only tracked while a player hasn't failed.
			-- This is so that the EX score stops changing once they've failed.
			W0 = 0,
			W015 = 0,
			W1 = 0,
			W2 = 0,
			W3 = 0,
			W4 = 0,
			W5 = 0,
			Miss = 0,
			HitMine = 0,
			-- Hold and rolls are tracked together here since they're covered by
			-- the HoldNoteScore.
			Held = 0,
			LetGo = 0,
		
			-- The W0 count displayed in the pane in ScreenEvaluation should
			-- still display the total count (whether or not the player has failed).
			-- Track that separately.
			W0_total = 0,
			W015_total = 0
		}
	end,
	JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if IsAutoplay(player) then return end
		
		local count_updated = false
		if params.HoldNoteScore then
			local HNS = ToEnumShortString(params.HoldNoteScore)
			-- Only track the HoldNoteScores we care about
			if valid_hns[HNS] then
				if not stats:GetFailed() then
					storage.ex_counts[HNS] = storage.ex_counts[HNS] + 1
					count_updated = true
				end
			end
		-- HNS also contain TNS. We don't want to double count so add an else if.
		elseif params.TapNoteScore then
			local TNS = ToEnumShortString(params.TapNoteScore)

			if SL.Global.GameMode == "ITG" then
				if TNS == "W1" then
					-- Check if this W1 is actually in the W0 window
					local is_W0 = IsW0Judgment(params, player)
					local is_W015 = IsW015Judgment(params, player)
					if is_W0 then
						if not stats:GetFailed() then
							storage.ex_counts.W0 = storage.ex_counts.W0 + 1
							storage.ex_counts.W015 = storage.ex_counts.W015 + 1
							count_updated = true
						end
						storage.ex_counts.W0_total = storage.ex_counts.W0_total + 1
						storage.ex_counts.W015_total = storage.ex_counts.W015_total + 1
					elseif is_W015 then
						if not stats:GetFailed() then
							storage.ex_counts.W015 = storage.ex_counts.W015 + 1
							count_updated = true
						end
						storage.ex_counts.W015_total = storage.ex_counts.W015_total + 1
					else
						if not stats:GetFailed() then
							storage.ex_counts.W1 = storage.ex_counts.W1 + 1
							count_updated = true
						end
					end
				else
					-- Only track the TapNoteScores we care about
					if valid_tns[TNS] then
						if not stats:GetFailed() then
							storage.ex_counts[TNS] = storage.ex_counts[TNS] + 1
							count_updated = true
						end
					end
				end
			else
				adjusted_TNS = TNS
				tier = string.match(TNS, "W(%d)")

				-- In FA+ mode, we need to shift the windows up 1 so that the key we're using is accurate.
				-- E.g. W1 window becomes W0, W2 becomes W1, etc.
				if tier ~= nil then
					adjusted_TNS = "W"..(tonumber(tier)-1)
				end
				
				-- Only track the TapNoteScores we care about
				if valid_tns[adjusted_TNS] then
					if not stats:GetFailed() then
						storage.ex_counts[adjusted_TNS] = storage.ex_counts[adjusted_TNS] + 1
						count_updated = true
					end
				end
			end
		end
		if count_updated then
			-- Broadcast so other elements on ScreenGameplay can process the updated count.
			MESSAGEMAN:Broadcast("ExCountsChanged", { Player=player, ExCounts=storage.ex_counts, ExScore=CalculateExScore(player) })
		end
	end,
}