-- TargetScore Graphs and Pacemaker contributed by iamjackg
-- ActionOnMissedTarget contributed by DinsFire64
-- cleanup + fixes contributed by djpohly and andrewipark
-- https://xkcd.com/1508/ imagined by Randall Munroe
-- GNU founded by Richard Stallman
-- ineffable fire described by quietly-turning

-- ---------------------------------------------------------------
-- nothing handled by this file applies to or should appear in Casual mode
if SL.Global.GameMode == "Casual" then return end

-- ---------------------------------------------------------------
-- first, the usual suspects

local player = ...
local pn = ToEnumShortString(player)

-- ---------------------------------------------------------------
-- Make sure that someone requested *something* from this file.
-- There are four reasons we'd want to proceed.
local WantsPacemaker        = SL[pn].ActiveModifiers.Pacemaker
local WantsTargetGraph      = SL[pn].ActiveModifiers.DataVisualizations == "Target Score Graph"
local FailOnMissedTarget    = PREFSMAN:GetPreference("EventMode") and SL[pn].ActiveModifiers.ActionOnMissedTarget == "Fail"
local RestartOnMissedTarget = PREFSMAN:GetPreference("EventMode") and SL[pn].ActiveModifiers.ActionOnMissedTarget == "Restart"

-- if none of those four conditions apply, don't go any futher; just return now.
if not (WantsPacemaker or WantsTargetGraph or FailOnMissedTarget or RestartOnMissedTarget) then return end

-- ---------------------------------------------------------------
-- variables needed by (both) TargetScore graph and/or Pacemaker

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local isTwoPlayers = (GAMESTATE:IsPlayerEnabled(PLAYER_1) and GAMESTATE:IsPlayerEnabled(PLAYER_2))
local notefield_is_centered = (GetNotefieldX(player) == _screen.cx)
local use_smaller_graph = isTwoPlayers or notefield_is_centered

local target_score, pos_data, personal_best = LoadActor("./Setup.lua", {player, use_smaller_graph, notefield_is_centered})

-- ---------------------------------------------------------------
-- add actors to the ActorFrame as needed
local af = Def.ActorFrame{}

if WantsTargetGraph then
	af[#af+1] = LoadActor("./Graph-Common.lua", {player, pss, isTwoPlayers, pos_data, target_score, personal_best, use_smaller_graph})
end


if WantsPacemaker or FailOnMissedTarget or RestartOnMissedTarget then
	-- Pacemaker logic (needed for ActionOnTargetMissed) and BitmapText (needed for Pacemaker)
	af[#af+1] = LoadActor("./Pacemaker.lua", {player, pss, isTwoPlayers, pos_data.graph, target_score})

	-- logic for ActionOnTargetMissed
	if FailOnMissedTarget or RestartOnMissedTarget then
		af[#af+1] = LoadActor("./ActionOnTargetMissed.lua", player)
	end
end

return af
