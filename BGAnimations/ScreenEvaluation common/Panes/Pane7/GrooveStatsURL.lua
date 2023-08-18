local player = ...
local pn = ToEnumShortString(player)

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local percent_dp = stats:GetPercentDancePoints()

local score = FormatPercentScore(percent_dp)
score = tostring(tonumber(score:gsub("%%", "") * 100)):gsub("%.", "")
local ex_score = CalculateExScore(player)
ex_score = tostring(tonumber(ex_score:gsub("%%", "") * 100)):gsub("%.", "")

local judgmentCounts = GetExJudgmentCounts(player)

local fantastic_plus = judgmentCounts["W0"]
local fantastic = judgmentCounts["W1"]
local excellent = judgmentCounts["W2"]
local great = judgmentCounts["W3"]
local decent = judgmentCounts["W4"]
local wayOff = judgmentCounts["W5"]
local miss = judgmentCounts["Miss"]
local total_steps = judgmentCounts["totalSteps"]
local holds_held = judgmentCounts["Holds"]
local total_holds = judgmentCounts["totalHolds"]
local mines_hit = judgmentCounts["Mines"]
local total_mines = judgmentCounts["totalMines"]
local rolls_held = judgmentCounts["Rolls"]
local total_rolls = judgmentCounts["totalRolls"]

local cmod = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):CMod()
local used_cmod = cmod ~= nil and "1" or "0"

local failed = stats:GetFailed() and "1" or "0"
local rate = tostring(SL.Global.ActiveModifiers.MusicRate * 100):gsub("%.", "")

local steps = GAMESTATE:GetCurrentSteps(player)

-- ParseChartInfo will do no work if the data already exists in the SL.Streams Cache.
ParseChartInfo(steps, pn)
local hash = SL[pn].Streams.Hash

local hash_version = SL.GrooveStats.ChartHashVersion

local dec_wo_enabled = (SL.Global.GameMode == "ITG")
for i = 1, NumJudgmentsAvailable() do
  -- (GMODS Timing Windows) - Zankoku
  dec_wo_enabled = dec_wo_enabled and SL.Global.ActiveModifiers.TimingWindows[i]
end
dec_wo_enabled = dec_wo_enabled and "1" or "0"

return ("HTTPS://GROOVESTATS.COM/QR/%d/%s/T%iP%iF%iE%iG%iD%iW%iM%iH%iT%iM%iT%iR%iT%i/F%sR%sC%sB%s"):format(
        hash_version, hash:upper(), total_steps, fantastic_plus, fantastic, excellent, great, decent, wayOff, miss,
        holds_held, total_holds, mines_hit, total_mines, rolls_held, total_rolls,
        failed, rate, used_cmod, dec_wo_enabled)
