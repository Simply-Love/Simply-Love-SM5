return Def.Actor {
    Name="WriteSongInfo",
    InitCommand=function(self)
        local f = RageFileUtil.CreateRageFile()
        if f:Open("Save/SongInfo.txt", 2) then
            f:Write("SONG: --- | ARTIST: ---  | PACK: --- | LENGTH: --- | DIFF: --- | STEPS: --- | ")
        else
            -- do nothing
        end
        f:destroy()
    end
}