SessionDataForStatistics = function(player)

    local totalTime = 0
    local songsPlayedThisGame = 0
    local notesHitThisGame = 0

    -- Use pairs here (instead of ipairs) because this player might have late-joined
    -- which will result in nil entries in the the Stats table, which halts ipairs.
    -- We're just summing total time anyway, so order doesn't matter.
    for i,stats in pairs( SL[ToEnumShortString(player)].Stages.Stats ) do
        totalTime = totalTime + (stats and stats.duration or 0)
        songsPlayedThisGame = songsPlayedThisGame + (stats and 1 or 0)

        if stats and stats.column_judgments then
            -- increment notesHitThisGame by the total number of tapnotes hit in this particular stepchart by using the per-column data
            -- don't rely on the engine's non-Miss judgment counts here for two reasons:
            -- 1. we want jumps/hands to count as more than 1 here
            -- 2. stepcharts can have non-1 #COMBOS parameters set which would artbitraily inflate notesHitThisGame

            for column, judgments in ipairs(stats.column_judgments) do
                for judgment, judgment_count in pairs(judgments) do
                    if judgment ~= "Miss" then
                        notesHitThisGame = notesHitThisGame + judgment_count
                    end
                end
            end
        end
    end

    local hours = math.floor(totalTime/3600)
    local minutes = math.floor((totalTime-(hours*3600))/60)
    local seconds = round(totalTime%60)

    return { 
        totalTime = totalTime, 
        hours = hours,
        minutes = minutes, 
        seconds = seconds, 
        songsPlayedThisGame = songsPlayedThisGame, 
        notesHitThisGame = notesHitThisGame }

end