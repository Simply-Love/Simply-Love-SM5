-- Each time a judgment occurs during gameplay, the engine broadcasts some relevant data
-- as a key/value table that themeside Lua can listen for via JudgmentMessageCommand()
--
-- The details of *what* gets broadcast is complicated and not documented anywhere I've found,
-- but you can grep the src for "Judgment" (quotes included) to get a sense of what gets sent
-- to Lua in different circumstances.
--
-- This file, PerColumnJudgmentTracking.lua exists so that ScreenEvaluation can have a pane
-- that displays a per-column judgment breakdown.
--
-- We have a local table, judgments, that has as many sub-tables as the current game has panels
-- per player (4 for dance-single, 8 for dance-double, 5 for pump-single, etc.)
-- and each of those sub-tables stores the number of judgments that occur during gameplay on
-- that particular panel.
--
-- This doesn't override or recreate the engine's judgment system in any way. It just allows
-- transient judgment data to persist beyond ScreenGameplay.
------------------------------------------------------------

-- don't bother tracking per-column judgment data in Casual gamemode
if SL.Global.GameMode == "Casual" then return end

local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

local judgments = {}
for i=1,GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() do
	judgments[#judgments+1] = { W0=0, W1=0, W2=0, W3=0, W4=0, W5=0, Miss=0 }
end

local actor = Def.Actor{
	OffCommand=function(self)
		local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
		storage.column_judgments = judgments
	end
}

-- add MissBecauseHeld as a possible judgment for all columns
for i,col_judgments in ipairs(judgments) do
	col_judgments.MissBecauseHeld=0
end

local buttons = {}
local style = GAMESTATE:GetCurrentStyle()
local num_columns = style:ColumnsPerPlayer()
for i=1,num_columns do
	local col = style:GetColumnInfo(player, i)
	table.insert(buttons, col.Name)
end


local held = {}

-- initialize to handle both players, regardless of whether both are actually joined.
-- the engine's InputCallback gives you ALL input, so even if only P1 is joined, the
-- InputCallback will report someone spamming input on P2 as valid events, so we have
-- to ensure that doesn't cause Lua errors here
for player in ivalues( PlayerNumber ) do
	held[player] = {}

	-- initialize all buttons available to this game for this player to be "not held"
	for button in ivalues(buttons) do
		held[player][button] = false
	end
end

local InputHandler = function(event)
	-- if any of these, don't attempt to handle input
	if not event.PlayerNumber or not event.button then return false end

	if event.type == "InputEventType_FirstPress" then
		held[event.PlayerNumber][event.button] = true
	elseif event.type == "InputEventType_Release" then
		held[event.PlayerNumber][event.button] = false
	end
end

actor.OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( InputHandler ) end
actor.JudgmentMessageCommand=function(self, params)
	local health_state = GAMESTATE:GetPlayerState(params.Player):GetHealthState()
	if params.Player == player and params.Notes and health_state ~= 'HealthState_Dead' then
		for col,tapnote in pairs(params.Notes) do

			local tnt = tapnote:GetTapNoteType()

			-- we don't want to consider TapNoteTypes like Mine, HoldTail, Attack, etc. when counting judgments
			-- we do want to consider normal tapnotes, hold heads, and lifts
			-- see: https://quietly-turning.github.io/Lua-For-SM5/LuaAPI#Enums-TapNoteType
			if tnt == "TapNoteType_Tap" or tnt == "TapNoteType_HoldHead" or tnt == "TapNoteType_Lift" then
				local tns = ToEnumShortString(params.TapNoteScore)
				if mods.ShowFaPlusWindow and mods.ShowFaPlusPane and IsW0Judgment(params, player) then
					tns = "W0"
				end
				
				judgments[col][tns] = judgments[col][tns] + 1

				if tns == "Miss" and held[params.Player][ buttons[col] ] then
					judgments[col].MissBecauseHeld = judgments[col].MissBecauseHeld + 1
				end
			end
		end
	end
end

return actor