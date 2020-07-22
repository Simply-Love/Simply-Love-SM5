local player = ...
if SL[ToEnumShortString(player)].ActiveModifiers.HideLifebar then return end

local lifemeter_actor



local lifemeter_type = SL[ToEnumShortString(player)].ActiveModifiers.LifeMeterType or CustomOptionRow("LifeMeterType").Choices[1]
lifemeter_actor = LoadActor(lifemeter_type .. ".lua", player)

-- Casual doesn't have a LifeMeter, so in Casual Mode,
-- lifemeter_actor will be returned as nil
return lifemeter_actor