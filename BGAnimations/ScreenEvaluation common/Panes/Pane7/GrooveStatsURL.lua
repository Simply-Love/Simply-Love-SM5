local player = ...
local pn = ToEnumShortString(player)

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

local judgmentCounts = GetExJudgmentCounts(player)

local fantastic_plus = judgmentCounts["W0"]
local fantastic = judgmentCounts["W1"]
local excellent = judgmentCounts["W2"]
local great = judgmentCounts["W3"]
local decent = judgmentCounts["W4"] -- could be nil
local wayOff = judgmentCounts["W5"] -- could be nil
local miss = judgmentCounts["Miss"]
local total_steps = judgmentCounts["totalSteps"]
local holds_held = judgmentCounts["Holds"]
local total_holds = judgmentCounts["totalHolds"]
local mines_hit = judgmentCounts["Mines"]
local total_mines = judgmentCounts["totalMines"]
local rolls_held = judgmentCounts["Rolls"]
local total_rolls = judgmentCounts["totalRolls"]

-- Preemptively stringify the deceent and wayoff counts to account for nil values
if decent == nil then
  decent = "N"
else
  decent = ("%x"):format(decent)
end

if wayOff == nil then
  wayOff = "N"
else
  wayOff = ("%x"):format(wayOff)
end

local cmod = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):CMod()
local used_cmod = cmod ~= nil and "1" or "0"

local failed = stats:GetFailed() and "1" or "0"
local rate = math.floor(SL.Global.ActiveModifiers.MusicRate * 100)

local steps = GAMESTATE:GetCurrentSteps(player)

-- ParseChartInfo will do no work if the data already exists in the SL.Streams Cache.
ParseChartInfo(steps, pn)
local hash = SL[pn].Streams.Hash
local hash_version = SL.GrooveStats.ChartHashVersion

local rescored = {
  W0 = 0,
  W1 = 0,
  W2 = 0,
  W3 = 0,
  W4 = 0,
  W5 = 0
}

local rows = { "W0", "W1", "W2", "W3", "W4", "W5" }

for i=1,GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() do
  for j, judgment in ipairs(rows) do
    rescored[judgment] = rescored[judgment] + SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].column_judgments[i]["Early"][judgment]
  end
end

local rescored_str = ""

if rescored["W0"] > 0 then
  rescored_str = rescored_str .. "G" .. ("%x"):format(rescored["W0"])
end

if rescored["W1"] > 0 then
  rescored_str = rescored_str .. "H" .. ("%x"):format(rescored["W1"])
end

if rescored["W2"] > 0 then
  rescored_str = rescored_str .. "I" .. ("%x"):format(rescored["W2"])
end

if rescored["W3"] > 0 then
  rescored_str = rescored_str .. "J" .. ("%x"):format(rescored["W3"])
end

if rescored["W4"] > 0 then
  rescored_str = rescored_str .. "K" .. ("%x"):format(rescored["W4"])
end

if rescored["W5"] > 0 then
  rescored_str = rescored_str .. "L" .. ("%x"):format(rescored["W5"])
end

return ("HTTPS://GROOVESTATS.COM/QR/%s/T%xG%xH%xI%xJ%xK%sL%sM%xH%xT%xR%xT%xM%xT%x%s/F%sR%xC%sV%x"):format(
        hash, total_steps, fantastic_plus, fantastic, excellent, great, decent, wayOff, miss,
        holds_held, total_holds, rolls_held, total_rolls, mines_hit, total_mines, rescored_str,
        failed, rate, used_cmod, hash_version):upper()

