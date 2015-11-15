local player = ...

if not SL[ ToEnumShortString(player) ].ActiveModifiers.SubtractiveScoring then
	return false
else

	local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
	local notefield_width = GAMESTATE:GetCurrentStyle():GetWidth(player)

	-- grab the appropriate x position from ScreenGameplay's
	-- metrics on Player positioning
	local pn = ToEnumShortString(player)
	local x_position = GetNotefieldX( player )

	-- flag to determine whether to bother to continue counting excellents
	-- or whether to just display percent away from 100%
	local received_judgment_lower_than_w2 = false

	-- these start at 0 for each new song
	-- FIXME: What about course mode?
	local w2_count = 0
	local judgment_count = 0
	local tns

	return Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			self:horizalign(left)
				:diffuse(color("#ff4cff")):zoom(0.35)
				:xy( x_position + (notefield_width/2.9), _screen.cy )
		end,
		JudgmentMessageCommand=function(self, params)
			tns = ToEnumShortString(params.TapNoteScore)
			self:queuecommand("Set")
		end,
		SetCommand=function(self, params)

			if tns == "W2" and not received_judgment_lower_than_w2 and w2_count < 10 then
					-- increment for the first ten
					w2_count = w2_count + 1
					-- and specificy literal W2 count
					self:settext("-" .. w2_count)

			elseif tns ~= "W1" then
				received_judgment_lower_than_w2 = true

				-- if not W1 or W2, specify percent away from 100%
				local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
				local current_possible_dp = pss:GetCurrentPossibleDancePoints()
				local possible_dp = pss:GetPossibleDancePoints()
				local actual_dp = pss:GetActualDancePoints()

				local score = current_possible_dp - actual_dp
				score = ((possible_dp - score) / possible_dp) * 100

				self:settext("-" .. string.format("%.2f", 100-score) .. "%" )
			end
		end
	}
end