local player = ...
if SL[ToEnumShortString(player)].ActiveModifiers.HideLifebar then return end

local lifemeter_actor

-- in StomperZ, the LifeMeterType is forced to be Surround-StomperZ style in all its purple glory
if SL.Global.GameMode == "StomperZ" then
	lifemeter_actor = LoadActor("StomperZ.lua", player)

-- in Competitive and ECFA, we have the choice a "Standard" LifeMeter (at the top of the screen)
-- or a "Surround" LifeMeter, which is like the StomperZ surround LifeMeter but more drab.
elseif SL.Global.GameMode == "Competitive" or SL.Global.GameMode == "ECFA" then

	local lifemeter_type = SL[ToEnumShortString(player)].ActiveModifiers.LifeMeterType or CustomOptionRow("LifeMeterType").Choices[1]
	lifemeter_actor = LoadActor(lifemeter_type .. ".lua", player)
end

-- Casual doesn't have a LifeMeter, so in Casual GameMode,
-- lifemeter_actor will be returned as nil
return lifemeter_actor