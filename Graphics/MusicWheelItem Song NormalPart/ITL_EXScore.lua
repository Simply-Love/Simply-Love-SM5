local player = ...

-- Add ITL EX scores to the song wheel as well.
-- It will be centered to the item if only one player is enabled, and stacked otherwise.
return Def.BitmapText{
    Font="Wendy/_wendy monospace numbers",
    Text="",
    InitCommand=function(self)
        self:visible(false)
        self:zoom(0.2)
        self:x(32)
        self:x(_screen.w/(WideScale(2.15, 2.14)) - self:GetWidth()*self:GetZoom() - 35)
        self:diffuse(SL.JudgmentColors["FA+"][1])
    end,
    PlayerJoinedMessageCommand=function(self)
        self:visible(GAMESTATE:IsPlayerEnabled(player))
    end,
    PlayerUnjoinedMessageCommand=function(self)
        self:visible(GAMESTATE:IsPlayerEnabled(player))
    end,
    SetCommand=function(self, params)
        -- Only display EX score if a profile is found for an enabled player.
        if not GAMESTATE:IsPlayerEnabled(player) or not PROFILEMAN:IsPersistentProfile(player) then
            self:visible(false)
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
        self:settext("00.00"):visible(true)
        local pn = ToEnumShortString(player)
        if params.Song ~= nil then
            local song = params.Song
            local song_dir = song:GetSongDir()
            if song_dir ~= nil and #song_dir ~= 0 then
                if SL[pn].ITLData["pathMap"][song_dir] ~= nil then
                    local hash = SL[pn].ITLData["pathMap"][song_dir]
                    if SL[pn].ITLData["hashMap"][hash] ~= nil then
                        local ex = SL[pn].ITLData["hashMap"][hash]["ex"] / 100
                        self:settext(("%.2f"):format(ex))
                        self:visible(true)
                        return
                    end
                end
            end
        end
        self:visible(false)
    end,
}