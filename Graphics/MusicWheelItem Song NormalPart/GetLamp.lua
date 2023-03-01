local args = {...}
local pn = args[1]

local IsUltraWide = (GetScreenAspectRatio() > 21/9)

local AwardMap = {
	["ITG"] = {
		["StageAward_FullComboW1"] = 1,
		["StageAward_FullComboW2"] = 2,
		["StageAward_SingleDigitW2"] = 2,
		["StageAward_OneW2"] = 2,
		["StageAward_FullComboW3"] = 3,
		["StageAward_SingleDigitW3"] = 3,
		["StageAward_OneW3"] = 3,
		["StageAward_100PercentW3"] = 3,
	},
	["FA+"] = {
		["StageAward_FullComboW1"] = 1,
		["StageAward_FullComboW2"] = 2,
		["StageAward_SingleDigitW2"] = 2,
		["StageAward_OneW2"] = 2,
		["StageAward_FullComboW3"] = 3,
		["StageAward_SingleDigitW3"] = 3,
		["StageAward_OneW3"] = 3,
		["StageAward_100PercentW3"] = 3,
		-- FullComboW4 technically doesn't exist, but we create it on the fly below.
		["StageAward_FullComboW4"] = 4,
	}
}

local ClearLamp = { color("#0000CC"), color("#990000") }

local function GetLamp(song)
	if not song then return nil end

	local steps = GAMESTATE:GetCurrentSteps(pn)
	if not steps then return nil end
	
	local profile = PROFILEMAN:GetProfile(pn)
	local high_score_list = profile:GetHighScoreListIfExists(song, steps)
			
	-- If no scores then just return.
	if high_score_list == nil or #high_score_list:GetHighScores() == 0 then
		return nil
	end

	local game_mode = SL.Global.GameMode
	-- Default to ITG mode tiers if we use a game mode not defined in the AwardMap
	if AwardMap[game_mode] == nil then
		game_mode = "ITG"
	end
	
	local best_lamp = nil

	for score in ivalues(high_score_list:GetHighScores()) do
		local award = score:GetStageAward()

		if award == nil and SL.Global.GameMode == "FA+" and score:GetGrade() ~= "Grade_Failed" then
			-- Dropping a roll/hold breaks the StageAward, but hitting a mine does not.
			local misses = score:GetTapNoteScore("TapNoteScore_Miss") +
					score:GetHoldNoteScore("HoldNoteScore_LetGo") +
					score:GetTapNoteScore("TapNoteScore_CheckpointMiss")
			if misses + score:GetTapNoteScore("TapNoteScore_W5") == 0 then
				award = "StageAward_FullComboW4"
			end
		end

		if AwardMap[game_mode][award] ~= nil then
			best_lamp = math.min(best_lamp and best_lamp or 999, AwardMap[game_mode][award])
		end
		
		if best_lamp == nil then
			if score:GetGrade() == "Grade_Failed" then best_lamp = 52
			else best_lamp = 51 end
		end
	end

	return best_lamp
end

return Def.ActorFrame{
	PlayerJoinedMessageCommand=function(self, params)
		if not PROFILEMAN:IsPersistentProfile(params.Player) then
			GAMESTATE:ResetPlayerOptions(params.Player)
			SL[ToEnumShortString(params.Player)]:initialize()
		end
		if pn == nil then
			player = params.Player
			pn = ToEnumShortString(player)
		end
	end,
	Def.Quad{
		SetCommand=function(self, param)
			self:scaletoclipped(SL_WideScale(5, 6), 31)
			self:horizalign(right)			
			
			local lamp = GetLamp(param.Song)
			if lamp == nil then
				self:visible(false)
			else
				self:visible(true)
				if lamp > 50 then
					self:diffuse(ClearLamp[lamp - 50])
				else
					self:diffuseshift():effectperiod(0.8)
					self:effectcolor1(SL.JudgmentColors[SL.Global.GameMode][lamp])
					self:effectcolor2(lerp_color(
						0.70, color("#ffffff"), SL.JudgmentColors[SL.Global.GameMode][lamp]))
				end
			end
			
			-- Align P2's lamps to the right of the grade if both players are joined.
			if pn == PLAYER_2 and GAMESTATE:GetNumSidesJoined() == 2 then
				-- Ultrawide is quite hard to align, manually scale for it.
				if IsUltraWide then
					self:x(SL_WideScale(18, 30) * 2 + SL_WideScale(5, 8) + 40)
				else
					self:x(SL_WideScale(18, 30) * 2 + SL_WideScale(5, 8))
				end
			end
		end
	}
}