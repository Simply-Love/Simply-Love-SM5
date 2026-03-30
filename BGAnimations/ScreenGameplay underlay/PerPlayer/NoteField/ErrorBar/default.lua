local player, layout = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

-- don't allow error bar to appear in Casual gamemode via profile settings
if SL.Global.GameMode == "Casual" then
    return
end

-- if mods.ErrorBar == "None" then
--     return
-- end

local af = Def.ActorFrame{
    Name="ErrorBarContainer"..pn
  }

local ErrorBarTypes = { "Colorful", "Monochrome", "Text", "Highlight", "Average" }

for i, barname in ipairs(ErrorBarTypes) do
    if mods[barname] then 
        af[#af+1] = LoadActor(barname .. ".lua", player, layout)
    end
end

return af
