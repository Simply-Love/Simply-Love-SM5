-- Draw an indicator on top and bottom of the StepsDisplayList to indicate there are difficulties
-- outside of the current view.
--
-- Based on ScreenSelectMusic overlay/PerPlayer/Cursor.lua

-- the difficulty grid and per-player bouncing cursors don't support CourseMode
-- CourseContentsList.lua should be used instead
if GAMESTATE:IsCourseMode() then return end
-- ----------------------------------------------

local GetStepsToDisplay = LoadActor("../StepsDisplayList/StepsToDisplay.lua")

local t = Def.ActorFrame {}

-- Base Actor. Differences in position and visibility are provided by the arguments.
local function scroll_cursor(name, rotation, get_y, set_visible)
    return Def.Sprite {
        Texture = THEME:GetPathB("ScreenSelectMusic", "overlay/PerPlayer/arrow.png"),
        Name = name,
        InitCommand = function(self)
            self:visible(true)
            self:zoom(0.575)
            self:rotationz(rotation)
            local bg_height = self:GetParent():GetParent():GetChild("Background"):GetZoomedHeight()
            self:y(get_y(bg_height))
        end,

        OnCommand=function(self) self:queuecommand("Set") end,
        CurrentSongChangedMessageCommand=function(self) self:queuecommand("Set") end,
        CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand("Set") end,
        CurrentStepsP2ChangedMessageCommand = function(self) self:queuecommand("Set") end,

        SetCommand = function(self)
            local song = GAMESTATE:GetCurrentSong()
            if not song then self:visible(false) return end
            local playable_steps = SongUtil.GetPlayableSteps(song)
            if not playable_steps then self:visible(false) return end
            local steps_to_display = GetStepsToDisplay(playable_steps)
            if not steps_to_display then self:visible(false) return end

            set_visible(self, playable_steps, steps_to_display)
        end
    }
end

-- The sprite has empty space around the actual content, need to offset a little
local scroll_cursor_sprite_offset = 2

-- Try to match comparison logic in StepsToDisplay.lua
local function steps_eq(steps1, steps2)
    return steps1:GetDifficulty()  == steps2:GetDifficulty()
       and steps1:GetDescription() == steps2:GetDescription()
       and steps1:GetChartName()   == steps2:GetChartName()
       and steps1:GetMeter()       == steps2:GetMeter()
end

t[#t + 1] = scroll_cursor(
    "ScrollCursorDown",
    90,
    function (bg_height) return bg_height / 2 + scroll_cursor_sprite_offset end,
    function (self, playable_steps, steps_to_display)
        local last_playable = playable_steps[#playable_steps]
        for i = 5, 1, -1 do
            if steps_to_display[i] and steps_eq(last_playable, steps_to_display[i]) then
                self:visible(false)
                return
            end
        end
        self:visible(true)
     end
)

t[#t + 1] = scroll_cursor(
    "ScrollCursorUp",
    270,
    function (bg_height) return -(bg_height / 2 + scroll_cursor_sprite_offset) end,
    function (self, playable_steps, steps_to_display)
        local first_playable = playable_steps[1]
        for i = 1, 5 do
            if steps_to_display[i] and steps_eq(first_playable, steps_to_display[i]) then
                self:visible(false)
                return
            end
        end
        self:visible(true)
    end
)

return t