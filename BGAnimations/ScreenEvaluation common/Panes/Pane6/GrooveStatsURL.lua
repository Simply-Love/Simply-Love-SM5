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

local qr_version = SL.GrooveStats.ChartHashVersion

return ("https://groovestats.com/qr.php?h=%s&s=%s&f=%s&r=%s&v=%d"):format(hash, score, failed, rate, qr_version)
