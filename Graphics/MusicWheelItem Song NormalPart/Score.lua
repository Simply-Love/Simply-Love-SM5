-- Display best EX from stored highscores
local player = ...

local function CalculateExScoreFromHighscoreAndSteps(hs, steps, pn)
   	-- white fa count is stored in score 🤯
    -- https://discord.com/channels/292111865658474496/958039182327029840/1156796786061606972
	local score = hs:GetScore()
	local ex_counts = {
        W0 = hs:GetTapNoteScore(ToEnumShortString("TNS_W1")) - score,
		W1 = score,
		W2 = hs:GetTapNoteScore(ToEnumShortString("TNS_W2")),
		W3 = hs:GetTapNoteScore(ToEnumShortString("TNS_W3")),
		W4 = hs:GetTapNoteScore(ToEnumShortString("TNS_W4")),
		W5 = hs:GetTapNoteScore(ToEnumShortString("TNS_W5")),
		Miss = hs:GetTapNoteScore(ToEnumShortString("TNS_Miss")),
		Held = hs:GetHoldNoteScore(ToEnumShortString("HNS_Held")),
		LetGo = hs:GetHoldNoteScore(ToEnumShortString("HNS_LetGo")),
		HitMine = hs:GetTapNoteScore(ToEnumShortString("TNS_HitMine"))
	}

    local use_actual_w0_weight = true
    local po_NoMines = false -- can't determine from highscore?
	return CalculateExScoreNoGlobalState(steps, pn, po_NoMines, ex_counts, use_actual_w0_weight)
end

local function MusicRateFromHighscore(hs)
    local music_rate_suffix = "xMusic" -- essentially ssprintf("%2.2fxMusic"), see SongOptions::GetMods
    local mods_string = hs:GetModifiers() -- can be something like "NoHideLights, m250, Overhead, 0.99xMusic"
    local suffix_pos = string.find(mods_string, music_rate_suffix)
    if suffix_pos == nil or suffix_pos == 0 then
        return 1
    else
        local iteration_pos = suffix_pos - 1
        while iteration_pos >= 0 do
            local char_at_iteration_pos = string.sub(mods_string, iteration_pos, iteration_pos)
            if char_at_iteration_pos == " " or char_at_iteration_pos == "," then
                local number = tonumber(string.sub(mods_string, iteration_pos, suffix_pos - 1))
                if number > 0 then
                    return number
                end
            end
            
            iteration_pos = iteration_pos - 1
        end
    end
    
end

-- Based on GetLamp
-- Colors in SL.JudgementColors["FA+"]:
-- 1: blue    (FFC)
-- 2: white   (normal)
-- 3: gold    (FEC)
-- 4: green   (FC)
-- 5: purple  (FBFC)
-- 6: red     (fail)
-- Still called AwardMap since it's mostly based on the awards...
local AwardMap = {
	["StageAward_FullComboW1"] = 1,
	["StageAward_FullComboW2"] = 3,
	["StageAward_SingleDigitW2"] = 3,
	["StageAward_OneW2"] = 3,
	["StageAward_FullComboW3"] = 4,
	["StageAward_SingleDigitW3"] = 4,
	["StageAward_OneW3"] = 4,
	["StageAward_100PercentW3"] = 4,
	-- The StageAwards below technically doesn't exist, but we create them on the
	-- fly below.
	["StageAward_FullComboW0"] = 5,
    ["normal"] = 2,
    ["fail"] = 6
}

-- Based on GetLamp
local function AwardMapIndexColorForHighScore(score)
	local award = score:GetStageAward()
    local grade = score:GetGrade()

    -- quint
	if grade == "Grade_Tier01" then
		if score:GetPercentDP() == 1.0 and score:GetScore() < score:GetTapNoteScore("TapNoteScore_W1") and score:GetScore() == 0 then
			award = "StageAward_FullComboW0"
		end
	end

    if grade == "Grade_Failed" then
        award = "fail"
    end

    if award == nil then
        award = "normal"
    end

    local award_table_index = AwardMap[award]
    return award_table_index
end

local function SetGetGSCachedScore(steps, ex)
    local chart_gs_hash = steps:GetGrooveStatsHash()
    local player_name = PROFILEMAN:GetPlayerName(player)

    local cached_score = nil
    if ex then
        cached_score = CacheGetGSEX(player_name, chart_gs_hash)
    else
        cached_score = CacheGetGSITG(player_name, chart_gs_hash)
    end

    if cached_score ~= nil then
        return cached_score
    end

    return nil
end

local function GetSetLocalCachedScore(song, steps, ex)
    local pn = ToEnumShortString(player)
    local chart_gs_hash = steps:GetGrooveStatsHash()
    local current_song = GAMESTATE:GetCurrentSong()

    local player_name = PROFILEMAN:GetPlayerName(player)
    local highscores = PROFILEMAN:GetProfile(pn):GetHighScoreList(song, steps):GetHighScores()

    if ex then
        local cached_ex, cached_award_map_idx = CacheGetLocalEX(player_name, chart_gs_hash)

        ---@type string|number|nil
        local best_ex = nil
        ---@type integer?
        local best_ex_award_map_idx = nil

        if cached_ex == nil or song == current_song then
            -- Calculate from all local scores
            local hs_for_best_ex = nil
            for hs in ivalues(highscores) do
                if MusicRateFromHighscore(hs) >= 1 then
                    local ex = CalculateExScoreFromHighscoreAndSteps(hs, steps, pn)
                    if ex ~= nil and best_ex == nil then
                        best_ex = ex
                        hs_for_best_ex = hs
                    elseif ex ~= nil and ex > best_ex then
                        best_ex = ex
                        hs_for_best_ex = hs
                    end
                end
            end

            if best_ex ~= nil then
                best_ex = ("%05.2f"):format(best_ex)
                best_ex_award_map_idx = AwardMapIndexColorForHighScore(hs_for_best_ex)
                CacheSetLocalEX(player_name, chart_gs_hash, best_ex, ("%d"):format(best_ex_award_map_idx))
            end
        else
            best_ex = cached_ex
            best_ex_award_map_idx = tonumber(cached_award_map_idx)
        end

        local best_ex_color = SL.JudgmentColors["FA+"][best_ex_award_map_idx]

        return best_ex, best_ex_color
    else -- ITG score
        local cached_itg, cached_award_map_idx = CacheGetLocalITG(player_name, chart_gs_hash)
        if cached_itg == nil or song == current_song then
            -- TODO: highscores should already be ordered by GetPercentDP, check if they really are?
            for hs in ivalues(highscores) do
                if MusicRateFromHighscore(hs) >= 1 then
                    local itg = hs:GetPercentDP() * 100
                    -- TODO: does AwardMapIndexColorForHighScore work properly for ITG scores?
                    local itg_award_map_idx = AwardMapIndexColorForHighScore(hs)
                    if itg ~= nil then
                        -- Store ITG score in cache too as this allows sharing scores between charts that are in several packs
                        local itg_string = ("%05.2f"):format(itg)
                        -- without tostring(itg_award_map_idx), for some reason gets stored as float string in sqlite
                        CacheSetLocalITG(player_name, chart_gs_hash, itg_string, ("%d"):format(itg_award_map_idx))
                        return itg_string, SL.JudgmentColors["FA+"][itg_award_map_idx]
                    end
                end
            end
        else
            return cached_itg, SL.JudgmentColors["FA+"][tonumber(cached_award_map_idx)]
        end

        return nil, nil
    end
end

local function UpdateYPosition(actor)
    if GAMESTATE:GetNumSidesJoined() == 2 then
        if player == PLAYER_1 then
            actor:y(-11)
        else
            actor:y(4)
        end
    else
        actor:y(-4)
    end
end

local function EXScore_DBG(message)
    -- uncomment this line to enable debug logs
    -- lua.Info(message)
end

-- Add EX scores to the song wheel as well.
-- It will be centered to the item if only one player is enabled, and stacked otherwise.
return Def.BitmapText {
    Font = "Wendy/_wendy monospace numbers",
    Text = "",

    InitCommand = function(self)
        self:visible(false)
        self:zoom(0.2)
        if ThemePrefs.Get("MusicWheelScore") == MusicWheelScore_ReplaceGrade then
            self:x(32)
        else
            -- Similar to ITL_EXScore.lua
            self:x(_screen.w / WideScale(2.15, 2.14) - self:GetWidth() * self:GetZoom() - 35)
        end
        UpdateYPosition(self)
    end,

    PlayerJoinedMessageCommand = function(self)
        self:visible(GAMESTATE:IsPlayerEnabled(player))
        UpdateYPosition(self)
    end,

    PlayerUnjoinedMessageCommand = function(self)
        self:visible(GAMESTATE:IsPlayerEnabled(player))
        UpdateYPosition(self)
    end,

    SetCommand = function(self, params)
        EXScore_DBG("Running SetCommand")

        -- Goal here is to utilize different levels of caches to do as little
        -- processing as possible to keep the UI snappy.

        -- Only display EX score if a profile is found for an enabled player.
        if not GAMESTATE:IsPlayerEnabled(player) or not PROFILEMAN:IsPersistentProfile(player) then
            self:visible(false):settext("")
            return
        end

        local currentSteps = GAMESTATE:GetCurrentSteps(player)
        if currentSteps == nil then
            EXScore_DBG("Early return due to nil currentSteps")
            return
        end
        local currentDifficulty = currentSteps:GetDifficulty()

        local song = nil

        -- If there's a params.Song, we are being called by the engine.
        -- In this case we want to check if this actor is already displaying the
        -- score for this song. If the the difficulty has changed, the steps
        -- are probably different too. Don't want to move the step selection logic
        -- so high up as it's more complicated.
        if params ~= nil and params.Song ~= nil then
            song = params.Song
            if self.Song == song and self.Difficulty == currentDifficulty then
                -- Song and difficulty hasn't changed, don't need to update anything!
                EXScore_DBG("Early return due to song being the same as previously")
                return
            end
        -- If we're running due to the groovestats cache being updated (CacheUpdatedGSMessageCommand)
        -- self.Song must also be set on an earlier round, otherwise the first valid run of this command
        -- will get the latest cached value anyways.
        elseif params.CacheUpdatedGS ~=nil and self.Song ~=nil then
            song = self.Song
        -- This branch is ran when
        -- 1. The engine runs us with a nil params.Song
        -- 2. CacheUpdatedGS runs us but SetCommand has not yet ran completely.
        else
            EXScore_DBG("Early return due to nil song.")
            return
        end

        if song ~= nil then EXScore_DBG("SetCommand song is " .. song:GetSongDir()) end

        -- If we have reached this point, we have a song.
        -- If there is an early return past this point,
        -- something was invalid and we don't want to display anything.
        self:visible(false):settext("")

        local allSteps = SongUtil.GetPlayableSteps(song)
        -- Show value that matches the currently selected difficulty.
        local steps = nil
        if #allSteps == 1 then
            -- If there's only a single difficulty, don't try to match the difficulty. Just show the only one.
            -- This is important for tournament packs which usually have other difficulties removed.
            steps = allSteps[1]
        else
            -- TODO: Match the engine (or theme?) behaviour on which difficulty will be autoselected from this chart
            -- if there's no exact match.
            for k, v in ipairs(allSteps) do
                if v:GetDifficulty() == currentDifficulty then
                    steps = v
                end
            end
        end

        if steps == nil then
            EXScore_DBG("Early return due to nil steps")
            return
        end

        EXScore_DBG("Actually calculating something for " .. song:GetMainTitle())

        ---@type boolean
        local showExScore = SL[ToEnumShortString(player)].ActiveModifiers.ShowExScore

        -- Local score. GetSetLocalCached... will recalculate if this song is the currently selected song.
        ---@type string?
        local local_score = nil
        ---@type table?
        local local_score_color = nil

        -- GrooveStats score. GetSetGSCached... will not call the API, that's done by PaneDisplay.
        -- PaneDisplay broadcasts CacheUpdatedGS when it writes something to the cache.
        ---@type string?
        local groovestats_score = nil

        if showExScore then
            local_score, local_score_color = GetSetLocalCachedScore(song, steps, true)
            if ThemePrefs.Get("EnableGrooveStats") then
                groovestats_score = SetGetGSCachedScore(steps, true)
            end
        else
            local_score, local_score_color = GetSetLocalCachedScore(song, steps, false)
            if ThemePrefs.Get("EnableGrooveStats") then
                groovestats_score = SetGetGSCachedScore(steps, false)
            end
        end
        
        EXScore_DBG(song:GetMainTitle() .. " -- local_score: " .. tostring(local_score) .. " local_score_color: " .. tostring(local_score_color))

        -- Display the best score
        if local_score ~= nil and tonumber(local_score) >= tonumber(groovestats_score or "0") then
            self:settext(local_score)
            self:diffuse(local_score_color)
            self:visible(true)
        elseif groovestats_score ~= nil and tonumber(groovestats_score) > (tonumber(local_score) or 0) then
            self:settext(groovestats_score)
            -- We don't get timing counts from GS so we don't know what lamp color this would be.
            -- If we also have the score locally (technically it might not be the same score as
            -- multiple scores could have the same EX), it's shown by the earlier if branch.
            self:diffuse(color("#ffffff"))
            self:visible(true)
        end

        -- Flag that we are already displaying an accurate result for the song & difficulty pair
        self.Song = song
        self.Difficulty = currentDifficulty
    end,

    CacheUpdatedGSMessageCommand = function(self, params)
        EXScore_DBG("Got CacheUpdatedGS " .. tostring(params.Song))
        -- Optimization: only refresh the song that was updated.
        if params.Song == self.Song then
            self:playcommand("Set", { CacheUpdatedGS = true })
        else
            EXScore_DBG("CacheUpdatedGS not calling Set due to self.Song not matching")
        end
    end
}