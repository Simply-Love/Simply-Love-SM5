local player, layout = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

-- don't allow error bar to appear in Casual gamemode via profile settings
if SL.Global.GameMode == "Casual" then
    return
end

if mods.ErrorBar == "None" then
    return
end

local a = LoadActor(mods.ErrorBar .. ".lua", player, layout)

return a
