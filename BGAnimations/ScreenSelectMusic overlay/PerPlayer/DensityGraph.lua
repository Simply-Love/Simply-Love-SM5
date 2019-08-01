local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]
local show = false

local function getInputHandler(actor)
    return (function (event)
        if (event.GameButton == "Up" or event.GameButton == "MenuUp") and event.PlayerNumber == player and GAMESTATE:IsPlayerEnabled(player) then
            if event.type == "InputEventType_FirstPress" then
                show = true
                actor:queuecommand("UpdateGraphState")
            elseif event.type == "InputEventType_Release" then
                show = false
                actor:queuecommand("UpdateGraphState")
            end
        end

        return false
    end)
end

local bannerWidth = 418
local bannerHeight = 164
local padding = 10

local histogramWidth = bannerWidth - (padding * 2)
local histogramHeight = bannerHeight / 2 - (padding * 1.5)
local histogram = NPS_Histogram(player, histogramWidth, histogramHeight)
 
-- don't do anything when song changes
histogram.CurrentSongChangedMessageCommand=nil

return Def.ActorFrame {
    InitCommand=function(self)
        local zoom, xPos
        local yPos = 112

        if IsUsingWideScreen() then
            zoom = 0.7655
            xPos = 170
        else
            zoom = 0.75
            xPos = 166
        end
        
        local histogramCenterXPosition = histogramWidth / 2
        local histogramCenterYPosition = bannerHeight / 2 - padding

        self:zoom(zoom)
        self:xy(_screen.cx - xPos - histogramCenterXPosition * zoom, yPos - histogramCenterYPosition * zoom)

        if (player == PLAYER_2) then
            self:addy((histogramHeight + padding) * zoom)
        end

        self:diffusealpha(0)
        self:queuecommand("Capture")
    end,

    CaptureCommand=function(self)
        SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self))
    end,
    
    StepsHaveChangedCommand=function(self, params)
        if show then
            self:queuecommand("UpdateGraphState")
        end
    end,

    UpdateGraphStateCommand=function(self, params)
        if show and not GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentSong() then
            self:stoptweening()
            self:linear(0.1):diffusealpha(0.9)
        else
            self:stoptweening()
            self:linear(0.1):diffusealpha(0)
        end
    end,

    -- background for whole thing
    Def.Quad{
        InitCommand=function(self)
            self:zoomto(histogramWidth,histogramHeight)
                :align(0, 0)
                :diffuse(color("#4D6677"))
        end
    },

    histogram..{
        UpdateGraphStateCommand=function(self)
            self:y(histogramHeight)

            if show and not GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentSong() then
                histogram:Initialize(self)
            end
        end
    },

    -- background for the text
    Def.Quad {
        InitCommand=function(self)
            self:zoomto(histogramWidth, 20)
                :diffuse(color("#000000"))
                :diffusealpha(0.8)
                :align(0, 0)
                :y(histogramHeight - 20)
        end,
    },
    
    Def.BitmapText{
        Font="Common Normal",
        InitCommand=function(self)
            self:diffuse(color("#ffffff"))
                :horizalign("left")
                :y(histogramHeight - 20 + 2)
                :x(5)
                :maxwidth(histogramWidth - 10)
                :align(0, 0)
                :Stroke(color("#000000"))
        end,

        StepsHaveChangedCommand=function(self, params)
            if show then
                self:queuecommand("UpdateGraphState")
            end
        end,

        UpdateGraphStateCommand=function(self)
            if show and not GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentSong() then
                local song_dir = GAMESTATE:GetCurrentSong():GetSongDir()
                local steps = GAMESTATE:GetCurrentSteps(player)
                local steps_type = ToEnumShortString( steps:GetStepsType() ):gsub("_", "-"):lower()
                local difficulty = ToEnumShortString( steps:GetDifficulty() )
                local breakdown = GetStreamBreakdown(song_dir, steps_type, difficulty)
                
                if breakdown == "" then
                    self:settext("No streams!")
                else
                    self:settext("Streams: " .. breakdown)
                end
                
                return true
            end
        end
    }
}
