local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local opts = GAMESTATE:GetPlayerState(player):GetCurrentPlayerOptions()
local layout = GetGameplayLayout(player, opts:Reverse() ~= 0)

local af = Def.ActorFrame{
  Name="NoteFieldContainer"..pn,
  OnCommand=function(self)
    local adjusted_offset_x = mods.NoteFieldOffsetX * (player == PLAYER_1 and -1 or 1)

    self:addy(mods.NoteFieldOffsetY)
    SCREENMAN:GetTopScreen():GetChild("Player"..pn):addx(adjusted_offset_x)
    SCREENMAN:GetTopScreen():GetChild("Player"..pn):addy(mods.NoteFieldOffsetY)
  end,
}

-- The following actors should also move along with the NoteFields.
af[#af+1] = LoadActor("ColumnFlashOnMiss.lua", player)
af[#af+1] = LoadActor("ErrorBar/default.lua", player, layout.ErrorBar)
af[#af+1] = LoadActor("MeasureCounter.lua", player, layout.MeasureCounter)
af[#af+1] = LoadActor("SubtractiveScoring.lua", player, layout.SubtractiveScoring)
af[#af+1] = LoadActor("ColumnCues.lua", player)
af[#af+1] = LoadActor("DisplayMods.lua", player)

return af