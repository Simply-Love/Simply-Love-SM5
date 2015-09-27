local player = ...

if SL[ ToEnumShortString(player) ].ActiveModifiers.HideScore then
	return false
else

	return Def.BitmapText{
		Font="_wendy monospace numbers",
		Text="0.00",

		Name=ToEnumShortString(player).."Score",
		InitCommand=function(self)
			self:y(56)
			self:valign(1)
			self:halign(1)
			self:zoom(0.5)
			if player == PLAYER_1 then
				self:x( _screen.cx - _screen.w/4.3 )
			elseif player == PLAYER_2 then
				self:x( _screen.cx + _screen.w/2.85 )
			end
		end,
		JudgmentMessageCommand=function(self) self:queuecommand("RedrawScore") end,
		RedrawScoreCommand=function(self)
			local dp = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPercentDancePoints()
			local percent = FormatPercentScore( dp ):sub(1,-2)
			self:settext(percent)
		end
	}
end