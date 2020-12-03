return Def.Actor {
    Name="WriteSongInfo",
    CurrentSongChangedMessageCommand=function(self)
        local song = GAMESTATE:GetCurrentSong()

        --Song Data
        local name   = "SONG: "..song:GetTranslitFullTitle().." | "
        local artist = "ARTIST: "..song:GetTranslitArtist().." | "
        local pack   = "PACK: "..song:GetGroupName().." | "
        local time = song:GetStepsSeconds()
        time = string.format("LENGTH: %d:%02d | ", math.floor(time/60), math.floor(time%60))

        -- Step Data
        local stepData, diff, steps
        if (GAMESTATE:IsCourseMode()) then
            stepData = GAMESTATE:GetCurrentCourse():GetCourseEntry(GAMESTATE:GetCourseSongIndex()):GetSong():GetOneSteps(0, 4)
        else
            stepData = GAMESTATE:GetCurrentSteps(0)
        end

        if (stepData ~= nil) then
            diff   =  "DIFF: "..stepData:GetMeter().." ["..stepData:GetDescription().."] | "
            steps  = "STEPS:  "..stepData:GetRadarValues(0):GetValue(5).." | "
        else
            diff   = "DIFF: --- | " 
            steps  = "STEPS: --- | "
        end

        -- Final
        local f = RageFileUtil.CreateRageFile()
        if f:Open("Save/SongInfo.txt", 2) then  
            f:Write(name..artist..pack..diff..steps..time)
        else    
            local fError = f:GetError()
            Trace( "[FileUtils] Error writing to file: ".. fError )
            f:ClearError()
        end
        f:destroy()
    end
}