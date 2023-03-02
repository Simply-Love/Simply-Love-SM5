local args = {...}
local player = args[1]
local pn = ToEnumShortString(player)

local IsUltraWide = (GetScreenAspectRatio() > 21/9)

local AwardMap = {
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

local function GetLamp(song)
	if not song then return nil end

	local steps = GAMESTATE:GetCurrentSteps(player)
	if not steps then return nil end
	
	local profile = PROFILEMAN:GetProfile(player)
	local high_score_list = profile:GetHighScoreListIfExists(song, steps)
			
	-- If no scores then just return.
	if high_score_list == nil or #high_score_list:GetHighScores() == 0 then
		return nil
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

		if AwardMap[award] ~= nil then
			best_lamp = math.min(best_lamp and best_lamp or 999, AwardMap[award])
		end
	end

	return best_lamp
end

local function MaybeSetLampForUnmarkedItlSong(self, player)
	local pn = ToEnumShortString(player)
	local hash = SL[pn].Streams.Hash
	if SL[pn].ITLData["hashMap"][hash] ~= nil then
		local song = GAMESTATE:GetCurrentSong()
		local song_dir = song:GetSongDir()
		if song_dir ~= nil and #song_dir ~= 0 then
			if SL[pn].ITLData["pathMap"][song_dir] == nil then
				SL[pn].ITLData["pathMap"][song_dir] = hash

				-- TODO: This seems to be offset for whatever reason when initially hovering over the song.
				-- Figure out what's going on.

				-- local itl_lamp = 6 - SL[pn].ITLData["hashMap"][hash]["clearType"]
				-- if itl_lamp == 5 then
				-- 	self:visible(false)
				-- else
				-- 	self:visible(true)
				-- 	self:diffuseshift():effectperiod(0.8)
				-- 	self:effectcolor1(SL.JudgmentColors["FA+"][itl_lamp])
				-- 	self:effectcolor2(lerp_color(0.70, color("#ffffff"), SL.JudgmentColors["FA+"][itl_lamp]))
				-- end

				-- if player == PLAYER_2 and GAMESTATE:GetNumSidesJoined() == 2 then
				-- 	-- Ultrawide is quite hard to align, manually scale for it.
				-- 	if IsUltraWide then
				-- 		self:x(SL_WideScale(18, 30) * 2 + SL_WideScale(5, 8) + 40)
				-- 	else
				-- 		self:x(SL_WideScale(18, 30) * 2 + SL_WideScale(5, 8))
				-- 	end
				-- end
				WriteItlFile(player)
			end
		end
	end
end

return Def.ActorFrame{
	Def.Quad{
		P1ChartParsedMessageCommand=function(self)
			if player ~= PLAYER_1 then return end
			MaybeSetLampForUnmarkedItlSong(self, player)
		end,
		P2ChartParsedMessageCommand=function(self)
			if player ~= PLAYER_2 then return end
			MaybeSetLampForUnmarkedItlSong(self, player)
		end,
		SetCommand=function(self, param)
			self:scaletoclipped(SL_WideScale(5, 6), 31)
			self:horizalign(right)

			-- Check ITL File
			local itl_lamp = nil
			if param.Song ~= nil then
				local song = param.Song
				local song_dir = song:GetSongDir()
				if song_dir ~= nil and #song_dir ~= 0 then
					if SL[pn].ITLData["pathMap"][song_dir] ~= nil then
						local hash = SL[pn].ITLData["pathMap"][song_dir]
						if SL[pn].ITLData["hashMap"][hash] ~= nil then
							itl_lamp = 6 - SL[pn].ITLData["hashMap"][hash]["clearType"]
						end
					end
				end
			end

			if itl_lamp ~= nil then
				-- Disable for normal clear types. The wheel grade should cover it.
				if itl_lamp == 5 then
					self:visible(false)
				else
					self:visible(true)
					self:diffuseshift():effectperiod(0.8)
					self:effectcolor1(SL.JudgmentColors["FA+"][itl_lamp])
					self:effectcolor2(lerp_color(0.70, color("#ffffff"), SL.JudgmentColors["FA+"][itl_lamp]))
				end
			else
				local lamp = GetLamp(param.Song)
				if lamp == nil then
					self:visible(false)
				else
					self:visible(true)
					self:diffuseshift():effectperiod(0.8)
					self:effectcolor1(SL.JudgmentColors[SL.Global.GameMode][lamp])
					self:effectcolor2(lerp_color(
						0.70, color("#ffffff"), SL.JudgmentColors[SL.Global.GameMode][lamp]))
				end
			end
			
			-- Align P2's lamps to the right of the grade if both players are joined.
			if player == PLAYER_2 and GAMESTATE:GetNumSidesJoined() == 2 then
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