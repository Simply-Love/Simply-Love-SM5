local isValidSongResult = function(song)
    local currentStepsType = GAMESTATE:GetCurrentStyle():GetStepsType()
    -- only songs with current step type
    if not song:HasStepsType(currentStepsType) then return false end

    -- pack name exclusion (e.g. Stamina, ITL ...)
    local excludePackSearch = SL.Global.SongSearchParams.ExcludePacksContains
    if excludePackSearch then
        local songGroup = SONGMAN:GetGroup(song)

        if songGroup:GetDisplayTitle():lower():find(excludePackSearch) ~= nil or
            songGroup:GetTranslitTitle():lower():find(excludePackSearch) ~= nil
        then
            return false
        end
    end

    -- title/subtitle search
    local titleSearch = SL.Global.SongSearchParams.Title
    if titleSearch then
        if song:GetDisplayFullTitle():lower():find(titleSearch) == nil and
            song:GetTranslitFullTitle():lower():find(titleSearch) == nil
        then
            return false
        end
    end

    -- artist search
    local artistSearch = SL.Global.SongSearchParams.Artist
    if artistSearch then
        if song:GetDisplayArtist():lower():find(artistSearch) == nil and
            song:GetTranslitArtist():lower():find(artistSearch) == nil
        then
            return false
        end
    end

    -- bpm search
    local bpmFromSearch = tonumber(SL.Global.SongSearchParams.BPMFrom)
    local bpmToSearch = tonumber(SL.Global.SongSearchParams.BPMTo)
    if bpmFromSearch or bpmToSearch then
        local songBpms = song:GetDisplayBpms()

        local lowIsInRange = songBpms[1] >= bpmFromSearch and songBpms[1] <= bpmToSearch
        local highIsInRange = songBpms[2] >= bpmFromSearch and songBpms[2] <= bpmToSearch

        if not lowIsInRange and not highIsInRange then return false end
    end

    -- difficulty
    local meterFromSearch = tonumber(SL.Global.SongSearchParams.MeterFrom)
    local meterToSearch = tonumber(SL.Global.SongSearchParams.MeterTo)
    if meterFromSearch or meterToSearch then
        local songSteps = song:GetStepsByStepsType(currentStepsType)
        local hasStepMeterInRange = false

        for steps in ivalues(songSteps) do
            local stepMeter = steps:GetMeter()

            if stepMeter >= meterFromSearch and stepMeter <= meterToSearch then
                hasStepMeterInRange = true
            end
        end

        if not hasStepMeterInRange then return false end
    end

    return true
end

return {
    normalizeSearchParams = function()
        local bpmFromSearch = tonumber(SL.Global.SongSearchParams.BPMFrom)
        local bpmToSearch = tonumber(SL.Global.SongSearchParams.BPMTo)

        if bpmFromSearch and not bpmToSearch then
            bpmToSearch = bpmFromSearch
        elseif bpmToSearch and not bpmFromSearch then
            bpmFromSearch = bpmToSearch
        elseif bpmFromSearch and bpmToSearch and bpmToSearch < bpmFromSearch then
            local realTo = bpmFromSearch
            bpmFromSearch = bpmToSearch
            bpmToSearch = realTo
        end

        SL.Global.SongSearchParams.BPMFrom = bpmFromSearch
        SL.Global.SongSearchParams.BPMTo = bpmToSearch

        -- meter
        local meterFromSearch = tonumber(SL.Global.SongSearchParams.MeterFrom)
        local meterToSearch = tonumber(SL.Global.SongSearchParams.MeterTo)

        if meterFromSearch and not meterToSearch then
            meterToSearch = meterFromSearch
        elseif meterToSearch and not meterFromSearch then
            meterFromSearch = meterToSearch
        elseif meterFromSearch and meterToSearch and meterToSearch < meterFromSearch then
            local realTo = meterFromSearch
            meterFromSearch = meterToSearch
            meterToSearch = realTo
        end

        SL.Global.SongSearchParams.MeterFrom = meterFromSearch
        SL.Global.SongSearchParams.MeterTo = meterToSearch
    end,

    searchSongs = function()
        local searchResults = {}

        -- starting with all
        local allSongs = SONGMAN:GetAllSongs()

        for song in ivalues(allSongs) do
            local isValid = isValidSongResult(song)

            if isValid then table.insert(searchResults, song) end
        end

        return searchResults
    end
}
