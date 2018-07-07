local player = ...

if SL[ ToEnumShortString(player) ].ActiveModifiers.HideScore then return end

local dance_points, percent
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

return Def.BitmapText{
	Font="_wendy monospace numbers",
	Text="0.00",

	Name=ToEnumShortString(player).."Score",
	InitCommand=function(self)
		self:valign(1):halign(1)

		-- figure out where the font should be placed
		-- maximum width is for the text 100.00
		local max_width = (5 * 48) + 20 - 4
		-- respectively: all chars, decimal point,
		-- compensation for 1 appearing narrower than a 0
		-- 0 is 25
		-- (since P1 has the 1 on the edge and P2 has the 0)

		-- set y-position and scaling now
		local scale = 0.5
		self:y(56)

		if SL.Global.GameMode == "StomperZ" then
			scale = 0.4
			self:y(20)
		end

		self:zoom(scale)

		-- position the text just inwards of the difficulty meter with padding
		local push = WideScale(27, 84) + 18

		self:x(push + (max_width * scale))
		if (player == PLAYER_2) then
			self:x( _screen.w - push)
		end

	end,
	JudgmentMessageCommand=function(self) self:queuecommand("RedrawScore") end,
	RedrawScoreCommand=function(self)
		dance_points = pss:GetPercentDancePoints()
		percent = FormatPercentScore( dance_points ):sub(1,-2)
		self:settext(percent)
	end
}
