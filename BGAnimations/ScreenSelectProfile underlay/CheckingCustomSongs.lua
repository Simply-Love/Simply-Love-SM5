if not PREFSMAN:GetPreference("CustomSongsEnable") then return end

return Def.ActorFrame {
    Name = "CheckingCustomSongs",

    InitCommand = function(self)
        self:Center():diffusealpha(0)
    end,

    OffCommand = function(self)
        for player in ivalues(PlayerNumber) do
            if GAMESTATE:IsHumanPlayer(player) and
                MEMCARDMAN:GetCardState(player) ~= 'MemoryCardState_none' then
                self:linear(0.5):diffusealpha(1)
            end
        end
    end,

    Def.Sprite {
        Texture = THEME:GetPathB("ScreenMemoryCard", "overlay/usbicon.png"),
        InitCommand = function(self)
            self:x(-150):zoom(0.45)
        end
    },

    Def.BitmapText {
        Font = "Common Normal",
        Text = ScreenString("CheckingCustomSongs"),
        InitCommand = function(self)
            self:x(80):zoom(1.5)
        end
    },
}
