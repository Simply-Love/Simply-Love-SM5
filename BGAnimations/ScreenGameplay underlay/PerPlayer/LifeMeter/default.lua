local player = ...
if SL[ToEnumShortString(player)].ActiveModifiers.HideLifebar then return end

local lifemeter_actor



local lifemeter_type = SL[ToEnumShortString(player)].ActiveModifiers.LifeMeterType or CustomOptionRow("LifeMeterType").Choices[1]
lifemeter_actor = LoadActor(lifemeter_type .. ".lua", player)

return lifemeter_actor