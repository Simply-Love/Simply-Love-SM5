local boxSize = {
    border = 1,
    width = 500,
    height = 376,
}

local resultsScroller = setmetatable({}, sick_wheel_mt)
local resultScrollerItem = LoadActor("scroller-result-item.lua", { boxSize = boxSize })
local resultsScrollerMaxItems = 6

-- selection
local selResultIndex = 1
local scrollFocusIndex = 1
local getCurrentSelectedResult = function() return selResultIndex, scrollFocusIndex end
local setCurrentSelectedResult = function(selRes, fIndex)
    selResultIndex = selRes
    scrollFocusIndex = fIndex
end

-- input manangement
local inputBlocked = true
local isInputBlocked = function() return inputBlocked end

-- song preview
-- stop whatever's playing immediately on every focus change (so nothing plays
-- while rolling through the scroller), then only start the preview once the
-- selection has settled on a row for `previewDelay` seconds
local previewDelay = 0.35

local scheduleSongPreview = function(self)
    SOUND:StopMusic()

    self:stoptweening()
        :sleep(previewDelay)
        :queuecommand("PreviewFocusedSong")
end

local allDiffs = {
    "Difficulty_Beginner",
    "Difficulty_Easy",
    "Difficulty_Medium",
    "Difficulty_Hard",
    "Difficulty_Challenge",
    "Difficulty_Edit"
}
local currentStepsType = GAMESTATE:GetCurrentStyle():GetStepsType()

-- data
local getScrollerData = function(songsResults)
    local data = {}

    for song in ivalues(songsResults) do
        table.insert(data, {
            title = song:GetDisplayMainTitle(),
            subtitle = song:GetDisplaySubTitle(),
            fulltitle = song:GetDisplayFullTitle(),
            artist = song:GetDisplayArtist(),
            bpms = function()
                local songBpms = song:GetDisplayBpms()

                if songBpms[2] - songBpms[1] == 0 then
                    return ("%.0f BPM"):format(songBpms[1])
                else
                    return ("%.0f - %.0f BPM"):format(songBpms[1], songBpms[2])
                end
            end,
            length = SecondsToMSS(song:MusicLengthSeconds()),
            packName = function()
                local songGroup = SONGMAN:GetGroup(song)
                return songGroup:GetDisplayTitle()
            end,
            packColor = function()
                local songGroup = SONGMAN:GetGroup(song)
                return SONGMAN:GetSongGroupColor(songGroup:GetGroupName())
            end,
            difficulties = function()
                local meterList = ""
                for i, difficulty in ipairs(allDiffs) do
                    local steps = song:GetOneSteps(currentStepsType, difficulty)
                    if steps then
                        if meterList ~= "" then
                            meterList = meterList .. " – "
                        end

                        meterList = meterList ..
                            steps:GetMeter() ..
                            (ToEnumShortString(difficulty):lower() == "edit" and " (Edit)" or "")
                    end
                end

                return meterList
            end,
            song = song
        })
    end

    table.insert(data,
        {
            isExit = true,
            label = THEME:GetString("OptionNames", "Exit"):upper(),
        })

    return data
end

local headerLabel = ScreenString("SearchResultsTitle")

return Def.ActorFrame {
    Name = "ResultsList",

    InitCommand = function(self)
        self:xy(294, ((_screen.h - boxSize.height) / 2) - 32)
    end,

    -- container
    LoadActor('../../container.lua', { boxSize = boxSize }),

    resultsScroller:create_actors("SearchResultsScroller", resultsScrollerMaxItems, resultScrollerItem, 250, -8),

    OnCommand = function(self)
        local inputHandler = LoadActor('input.lua', {
            isInputBlocked = isInputBlocked,
            scroller = resultsScroller,
            resultsFrame = self,
            getCurrentSelectedResult = getCurrentSelectedResult,
            setCurrentSelectedResult = setCurrentSelectedResult,
            scheduleSongPreview = scheduleSongPreview
        })

        SCREENMAN:GetTopScreen():AddInputCallback(inputHandler)
    end,

    DisplaySearchResultsCommand = function(self, songsResults)
        local scrollerData = getScrollerData(songsResults)

        self:playcommand("UpdateHeader", { newTitle = headerLabel:format(#songsResults) })

        resultsScroller.disable_wrapping = true
        resultsScroller.focus_pos = 1
        resultsScroller:set_info_set(scrollerData, 0)

        inputBlocked = false

        scheduleSongPreview(self)
    end,

    PreviewFocusedSongCommand = function()
        local focusedInfo = resultsScroller:get_info_at_focus_pos()
        local song = (focusedInfo and (not focusedInfo.isExit)) and focusedInfo.song or nil

        -- just in case
        SOUND:StopMusic()

        if song then
            local songPath = song:GetPreviewMusicPath()
            local sampleStart = song:GetSampleStart()
            local sampleLength = song:GetSampleLength()

            SOUND:PlayMusicPart(songPath, sampleStart, sampleLength, 0.5, 1.5, false, true)
        end
    end,

    OffCommand = function(self)
        self:stoptweening()
        SOUND:StopMusic()
    end,

    EndCommand = function(self)
        if self.reloadMusicWheel then
            -- If the MenuTimer is in effect, we need to make sure the current number of seconds
            -- remaining is preserved so we can reinstate it later. ShowPressStartForOptions
            -- will save the current number of seconds before transitioning to the next screen.
            if PREFSMAN:GetPreference("MenuTimer") then
                SCREENMAN:GetTopScreen():playcommand("ShowPressStartForOptions")
            end

            SCREENMAN:GetTopScreen():queuecommand("Reload")
        end
    end
}
