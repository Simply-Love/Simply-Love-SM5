local player = ...
local pn = ToEnumShortString(player)

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local PercentDP = stats:GetPercentDancePoints()

local score = FormatPercentScore(PercentDP)
score = tostring(tonumber(score:gsub("%%", "") * 100)):gsub("%.", "")
local failed = stats:GetFailed() and "1" or "0"
local rate = tostring(SL.Global.ActiveModifiers.MusicRate * 100):gsub("%.", "")

local steps = GAMESTATE:GetCurrentSteps(player)

-- ParseChartInfo will do no work if the data already exists in the SL.Streams Cache.
ParseChartInfo(steps, pn)
local hash = SL[pn].Streams.Hash

local hash_version = SL.GrooveStats.ChartHashVersion

local dec_wo_enabled = (SL.Global.GameMode == "ITG")
for i = 1, NumJudgmentsAvailable() do
  dec_wo_enabled = dec_wo_enabled and SL[pn].ActiveModifiers.TimingWindows[i]
end
dec_wo_enabled = dec_wo_enabled and "1" or "0"

return ("https://groovestats.com/qr.php?h=%s&s=%s&f=%s&r=%s&v=%d&b=%s"):format(hash, score, failed, rate, hash_version, dec_wo_enabled)
