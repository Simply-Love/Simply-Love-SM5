local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

return Def.Actor{
  OnCommand=function(self)
    SCREENMAN:GetTopScreen():GetChild("Player"..pn):GetChild("NoteField"):addx(mods.NoteFieldOffsetX)
    SCREENMAN:GetTopScreen():GetChild("Player"..pn):GetChild("NoteField"):addy(mods.NoteFieldOffsetY)
  end,
}

