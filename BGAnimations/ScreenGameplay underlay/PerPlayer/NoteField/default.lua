local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local opts = GAMESTATE:GetPlayerState(player):GetCurrentPlayerOptions()
local layout = GetGameplayLayout(player, opts:Reverse() ~= 0)

local af = Def.ActorFrame{
  Name="NoteFieldContainer"..pn,
  OnCommand=function(self)
    -- We multiply by 2 here because most child actors use the center of the
    -- playfield as the anchor point, and we want to move the playfield as a whole.
    self:addx(mods.NoteFieldOffsetX * 2)
    self:addy(mods.NoteFieldOffsetY * 2)
    SCREENMAN:GetTopScreen():GetChild("Player"..pn):GetChild("NoteField"):addx(mods.NoteFieldOffsetX)
    SCREENMAN:GetTopScreen():GetChild("Player"..pn):GetChild("NoteField"):addy(mods.NoteFieldOffsetY)
  end,
}

-- The following actors should also move along with the NoteFields.
-- NOTE(teejusb): Combo and Judgment are not included here because they are
-- controlled by Graphics/Player combo.lua and Graphics/Player judgment.lua
-- respectively.
af[#af+1] = LoadActor("ColumnFlashOnMiss.lua", player)
af[#af+1] = LoadActor("ErrorBar/default.lua", player, layout.ErrorBar)
af[#af+1] = LoadActor("MeasureCounter.lua", player, layout.MeasureCounter)
af[#af+1] = LoadActor("SubtractiveScoring.lua", player, layout.SubtractiveScoring)
af[#af+1] = LoadActor("ColumnCues.lua", player)
af[#af+1] = LoadActor("NoteFieldOffset.lua", player)

return af