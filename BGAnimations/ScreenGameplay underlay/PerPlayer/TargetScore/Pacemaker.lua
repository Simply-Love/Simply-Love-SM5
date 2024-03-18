local player, pss, isTwoPlayers, graph, target_score = unpack(...)
local pn = ToEnumShortString(player)

local GetPossibleExScore = function(counts)
	local best_counts = {}
	
	local keys = { "W0", "W1", "W2", "W3", "W4", "W5", "Miss", "Held", "LetGo", "HitMine" }

	for key in ivalues(keys) do
		local value = counts[key]
		if value ~= nil then
			-- Initialize the keys	
			if best_counts[key] == nil then
				best_counts[key] = 0
			end

			-- Upgrade dropped holds/rolls to held.
			if key == "LetGo" or key == "Held" then
				best_counts["Held"] = best_counts["Held"] + value
			-- We never hit any mines.
			elseif key == "HitMine" then
				best_counts[key] = 0
			-- Upgrade to FA+ window.
			else
				best_counts["W015"] = best_counts["W015"] + value
			end
		end
	end
	
	local possible_ex_score, possible_total = CalculateExScore(player, best_counts)
	return possible_ex_score, possible_total
end

local pacemaker = Def.BitmapText{
	Font=ThemePrefs.Get("ThemeFont") .. " Bold",
	JudgmentMessageCommand=function(self)
		self:queuecommand("Update")
	end,
	
	ExCountsChangedMessageCommand=function(self, params)
		if SL[pn].ActiveModifiers.ShowEXScore then
			local PercentMax, DPCurrMax = GetPossibleExScore(params.ExCounts)
			local DPCurr = params.actual_points
			local DPMax = params.actual_possible
			
			local percentDifference = (DPCurr - (target_score * DPCurrMax)) / DPMax

			-- cap negative score displays
			percentDifference = math.max(percentDifference, -target_score)

			local places = 2
			-- if there's enough dance points so that our current precision is ambiguous,
			-- i.e. each dance point is less than half of a digit in the last place,
			-- and we don't already display 2.5 digits,
			-- i.e. 2 significant figures and (possibly) a leading 1,
			-- add a decimal point.
			-- .1995 prevents flickering between .01995, which is rounded and displayed as ".0200", and
			-- and an actual .0200, which is displayed as ".020"
			while (math.abs(percentDifference) < 0.1995 / math.pow(10, places))
				and (DPMax >= 2 * math.pow(10, places + 2)) and (places < 4) do
				places = places + 1
			end

			self:settext(string.format("%+."..places.."f", percentDifference * 100))

			-- have we already missed so many dance points
			-- that the current goal is not possible anymore?
			if ((DPCurrMax - DPCurr) > (DPMax * (1 - target_score))) then
				self:diffusealpha(0.65)
				-- see: ./SL/BGA/ScreenGameplay underlay/PerPlayer/TargetScore/ActionOnTargetMissed.lua
				MESSAGEMAN:Broadcast("TargetGradeMissed", {Player=player})
			end
		end
	end,

	-- common logic used for both the Pacemaker text and the ActionOnTargetMissed mod
	UpdateCommand=function(self)
		if not SL[pn].ActiveModifiers.ShowEXScore then
			local DPCurr = pss:GetActualDancePoints()
			local DPCurrMax = pss:GetCurrentPossibleDancePoints()
			local DPMax = pss:GetPossibleDancePoints()
			
			

			local percentDifference = (DPCurr - (target_score * DPCurrMax)) / DPMax

			-- cap negative score displays
			percentDifference = math.max(percentDifference, -target_score)

			local places = 2
			-- if there's enough dance points so that our current precision is ambiguous,
			-- i.e. each dance point is less than half of a digit in the last place,
			-- and we don't already display 2.5 digits,
			-- i.e. 2 significant figures and (possibly) a leading 1,
			-- add a decimal point.
			-- .1995 prevents flickering between .01995, which is rounded and displayed as ".0200", and
			-- and an actual .0200, which is displayed as ".020"
			while (math.abs(percentDifference) < 0.1995 / math.pow(10, places))
				and (DPMax >= 2 * math.pow(10, places + 2)) and (places < 4) do
				places = places + 1
			end

			self:settext(string.format("%+."..places.."f", percentDifference * 100))

			-- have we already missed so many dance points
			-- that the current goal is not possible anymore?
			if ((DPCurrMax - DPCurr) > (DPMax * (1 - target_score))) then
				self:diffusealpha(0.65)
				-- see: ./SL/BGA/ScreenGameplay underlay/PerPlayer/TargetScore/ActionOnTargetMissed.lua
				MESSAGEMAN:Broadcast("TargetGradeMissed", {Player=player})
			end
		end
	end
}

--------------------------------------------------------------
-- if the player wanted the Pacemaker mod

if SL[pn].ActiveModifiers.Pacemaker then

	pacemaker.InitCommand=function(self)

		local isCentered = (GetNotefieldX(player) == _screen.cx)
		local _y = 56
		local zoomF = 0.4

		local _x = {
			[PLAYER_1] = GetNotefieldX(PLAYER_1) + 64,
			[PLAYER_2] = GetNotefieldX(PLAYER_2) - 64
		}

		if isTwoPlayers and SL[pn].ActiveModifiers.NPSGraphAtTop then
			_x[PLAYER_1] = GetNotefieldX(PLAYER_1) - 128
			_x[PLAYER_2] = GetNotefieldX(PLAYER_2) + 128
			_y = 84
		end

		self:horizalign(center):zoom(zoomF)
		self:y(_y)
		self:x( _x[player] )

		if (not isTwoPlayers) and SL[pn].ActiveModifiers.NPSGraphAtTop then
			if not isCentered then
				self:x( _x[OtherPlayer[player]] )
			else
				self:x( _x[player] + (82 * (player==PLAYER_1 and 1 or -1)) )
			end
		end
	end

--------------------------------------------------------------
-- the player didn't want the Pacemaker mod

else
	pacemaker.InitCommand=function(self)
		-- so don't bother with any of the (above) positioning code
		-- and don't even draw the BitmapText actor
		self:visible(false)
	end
end

return pacemaker
