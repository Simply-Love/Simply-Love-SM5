-- reset
SL.Global.GameplayForcePlayerOptions = false

-- ignore on course mode
if GAMESTATE:IsCourseMode() then return end

local rate = SL.Global.ActiveModifiers.MusicRate
local isPayMode = GAMESTATE:GetCoinMode() == "CoinMode_Pay"

local allGuests = true
local humanPlayers = GAMESTATE:GetHumanPlayers()
for player in ivalues(humanPlayers) do
    local pn = ToEnumShortString(player)
    if PROFILEMAN:IsPersistentProfile(player) or SL[pn].ApiKey ~= "" then
        allGuests = false
    end
end

return Def.ActorFrame {
    Name = "ReopenPlayerOptions",

    -- change modifiers without loosing credit or get back to select music
    CodeMessageCommand = function(self, params)
        if params.Name == "ChangePlayerOptions" then
            -- ignore if all guests (prop randoms)
            if isPayMode and allGuests then return end

            local song = GAMESTATE:GetCurrentSong()
            local songPos = GAMESTATE:GetSongPosition()
            local songCurrentSecs = songPos:GetMusicSeconds() / rate
            local songTotalSecs = (song:GetLastSecond() < 0 and 0 or song:GetLastSecond()) / rate
            local songRemainingSecs = songTotalSecs - songCurrentSecs

            local canChangeOptions = false

            -- EVENTMODE -> until last 5 seconds
            -- ARCADE -> until first 10 seconds
            if (isPayMode and songCurrentSecs < 10) or (not isPayMode and songRemainingSecs > 5) then
                canChangeOptions = true
            end

            if canChangeOptions then
                -- avoid music wheel if Pay mode
                if isPayMode then
                    SL.Global.GameplayForcePlayerOptions = true
                end

                SL.Global.GameplayReloadCheck = false

                SCREENMAN:GetTopScreen()
                    :SetPrevScreenName("ScreenPlayerOptions")
                    :begin_backing_out()
            end
        end
    end
}
