local player, pss, isTwoPlayers, graph, target_score = unpack(...)
local pn = ToEnumShortString(player)

local pacemaker = Def.BitmapText{
	Font="Common Bold",
	JudgmentMessageCommand=function(self)
		self:queuecommand("Update")
	end,

	-- common logic used for both the Pacemaker text and the ActionOnTargetMissed mod
	UpdateCommand=function(self)
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
}

-- FIXME: rewrite this code to position the Pacemaker bmt soon
--------------------------------------------------------------
--[[
-- if the player wanted the Pacemaker mod
if SL[pn].ActiveModifiers.Pacemaker then

	pacemaker.InitCommand=function(self)

		local nf_cx    = GetNotefieldX(player)
		local nf_width = GetNotefieldWidth()

		local noteX = nf_width / 4 -- ???
		local noteY = 56
		local zoomF = 0.4


		-- non-symmetry kludge; nudge PLAYER_2's pacemaker text to the left so that it
		-- doesn't possibly overlap with the percent score text.  this is necessary because
		-- P1 and P2 percent scores are not strictly symmetrical around the horizontal middle
		if (player ~= PLAYER_1 and isTwoPlayers) then
			noteX = noteX + 25
		end


		-- flip x-coordinate based on player
		if (player ~= PLAYER_1) then
			noteX = -1 * noteX
		end
		noteX = noteX + nf_cx

		self:horizalign(center):xy( noteX, noteY ):zoom(zoomF)

		-- FIXME: Theme elements start to visually overlap in the following circumstance:
		-- a 4:3 display is in use, and both have the NPSGraphAtTop enabled, and both have the
		-- Pacemaker enabled, AND they are playing different charts in the same song that
		-- feature "split BPMs" (i.e. steps timing).  It's unlikely, but possible.

		if SL[pn].ActiveModifiers.NPSGraphAtTop then

			-- if the playfield is centered (Center1Player, double, dance solo, routine, techno8, etc.)
			if GetNotefieldX(player) == _screen.cx then
				-- self:addx((player==PLAYER_1 and 10 or -10 ))
			else
				self:addx((player==PLAYER_1 and (nf_width/2.75) or -(nf_width/3.5) ))
			end
		end
	end
--]]
--------------------------------------------------------------

-- the player didn't want the Pacemaker mod

-- else
	pacemaker.InitCommand=function(self)
		-- so don't bother with any of the (above) positioning code
		-- and don't even draw the BitmapText actor
		self:visible(false)
	end
-- end

return pacemaker
