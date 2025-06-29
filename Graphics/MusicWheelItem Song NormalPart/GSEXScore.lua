-- Display best EX from stored highscores
local player = ...

-- Add EX scores to the song wheel as well.
-- It will be centered to the item if only one player is enabled, and stacked otherwise.
return Def.BitmapText{
    Font="Wendy/_wendy monospace numbers",
    Text="",
    InitCommand=function(self)
        self:visible(false)
        self:zoom(0.2)
        self:x(32)
    end,
    PlayerJoinedMessageCommand=function(self)
        self:visible(GAMESTATE:IsPlayerEnabled(player))
    end,
    PlayerUnjoinedMessageCommand=function(self)
        self:visible(GAMESTATE:IsPlayerEnabled(player))
    end,
    SetCommand=function(self, params)
        -- Only display EX score if a profile is found for an enabled player.
        self:visible(false):settext("")
        if not GAMESTATE:IsPlayerEnabled(player) or not PROFILEMAN:IsPersistentProfile(player) then
            return
        end

        if GAMESTATE:GetNumSidesJoined() == 2 then
            if player == PLAYER_1 then
                self:y(-11)
            else
                self:y(4)
            end
        else
            self:y(-4)
        end

        local pn = ToEnumShortString(player)
        if params.Song ~= nil then
            local song = params.Song
            local allSteps = SongUtil.GetPlayableSteps(song)

            local currentSteps = GAMESTATE:GetCurrentSteps(player)
            if currentSteps == nil then
                -- SM("currentSteps nil")
                return
            end

            local currentDifficulty = currentSteps:GetDifficulty()

            -- Like grades, steps that match the currently selected difficulty.
            local steps = nil
            if #allSteps == 1 then
                -- If there's only a single difficulty, don't try to match the difficulty. Just show the only one.
                steps = allSteps[1]
            else
                -- TODO: Match the engine (or theme?) behaviour on which difficulty will be autoselected from this chart
                for k, v in ipairs(allSteps) do
                    if v:GetDifficulty() == currentDifficulty then
                        steps = v
                    end
                end
            end

            if steps == nil then
                return
            end

            -- Adapted from SL-ChartParser.lua
            -- StepsType, a string like "dance-single" or "pump-double"
            local stepsType = ToEnumShortString( steps:GetStepsType() ):gsub("_", "-"):lower()
            -- Difficulty, a string like "Beginner" or "Challenge"
            local difficulty = ToEnumShortString( steps:GetDifficulty() )
            -- An arbitary but unique string provided by the stepartist, needed here to identify Edit charts
            local description = steps:GetDescription()

            local filepath = steps:GetFilename()

            local charthash = CacheGetChartHash(filepath, difficulty, description)
            if charthash == nil then
                local simfileString, fileType = GetSimfileString(steps)
                local chartString, BPMs = GetSimfileChartString(simfileString, stepsType, difficulty, description, fileType)
                charthash = BinaryToHex(CRYPTMAN:SHA1String(chartString..BPMs)):sub(1, 16)
                CacheSetChartHash(filepath, difficulty, description, charthash)
            end

            local playerName = PROFILEMAN:GetPlayerName(player)
            local cachedEX = CacheGetGSEX(charthash, playerName)

			if cachedEX ~= nil then
				self:settext(cachedEX)
				self:visible(true)
			end
        end
    end,
}
