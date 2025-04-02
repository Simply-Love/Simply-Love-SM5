local IsUltraWide = (GetScreenAspectRatio() >= 21/9)

local AwardMap = {
	["StageAward_FullComboW1"] = 1,
	["StageAward_FullComboW2"] = 2,
	["StageAward_SingleDigitW2"] = 2,
	["StageAward_OneW2"] = 2,
	["StageAward_FullComboW3"] = 3,
	["StageAward_SingleDigitW3"] = 3,
	["StageAward_OneW3"] = 3,
	["StageAward_100PercentW3"] = 3,
	-- The StageAwards below technically doesn't exist, but we create them on the
	-- fly below.
	["StageAward_FullComboW4"] = 4,
	["StageAward_FullComboW0"] = 0,
}

local function GetLamp(high_score_list)
	-- If no scores then just return.
	if high_score_list == nil or #high_score_list:GetHighScores() == 0 then
		return nil
	end

	local best_lamp = nil

	for score in ivalues(high_score_list:GetHighScores()) do
		local award = score:GetStageAward()
		if score:GetGrade() == "Grade_Tier01" then
			if score:GetPercentDP() == 1.0 and score:GetScore() < score:GetTapNoteScore("TapNoteScore_W1") and score:GetScore() == 0 then
				award = "StageAward_FullComboW0"
			end
		end

		if AwardMap[award] ~= nil then
			best_lamp = math.min(best_lamp and best_lamp or 999, AwardMap[award])
		end
	end

	return best_lamp
end

return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(self)
			self:visible(false)
		end,
		SetGradeCommand=function(self, param)
			self:scaletoclipped(SL_WideScale(5, 6), 31)

			local lamp = GetLamp(param.HighScoreList)
			if lamp == nil then
				self:visible(false)
			else
				self:visible(true)
				-- Default to the quint color.
				local lamp_color = color("1,0.2,0.406,1")
				if lamp ~= 0 then
					lamp_color = SL.JudgmentColors[SL.Global.GameMode][lamp]
				end

				self:diffuseshift():effectperiod(0.8)
				self:effectcolor1(lamp_color)
				self:effectcolor2(lerp_color(0.70, color("#ffffff"), lamp_color))
			end

			-- Ultrawide is quite hard to align, manually scale for it.
			if IsUltraWide then
				self:x((SL_WideScale(13, 20) + 10) * (param.PlayerNumber == PLAYER_1 and -1 or 1))
			else
				self:x(SL_WideScale(13, 20) * (param.PlayerNumber == PLAYER_1 and -1 or 1))
			end
		end
	}
}