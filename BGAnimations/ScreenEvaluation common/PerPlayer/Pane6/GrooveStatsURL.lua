local player = ...

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local PercentDP = stats:GetPercentDancePoints()

local score = FormatPercentScore(PercentDP)
score = tostring(tonumber(score:gsub("%%", "") * 100)):gsub("%.", "")
local failed = stats:GetFailed() and "1" or "0"
local rate = tostring(SL.Global.ActiveModifiers.MusicRate * 100):gsub("%.", "")

local steps = GAMESTATE:GetCurrentSteps(player)
local difficulty = ""

if steps then
	difficulty = steps:GetDifficulty()
	-- GetDifficulty() returns a value from the Difficulty Enum
	-- "Difficulty_Hard" for example.
	-- Strip the characters up to and including the underscore.
	difficulty = ToEnumShortString(difficulty)
end

-- will need to update this to not be hardcoded to dance if GrooveStats supports other games in the future
local style = ""
if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
	style = "dance-double"
else
	style = "dance-single"
end

local hash = GenerateHash(steps, style, difficulty):sub(1, 12)

-- ************* CURRENT QR VERSION *************
-- * Update whenever we change relevant QR code *
-- *  and when the backend GrooveStats is also  *
-- *   updated to properly consume this value.  *
-- **********************************************
local qr_version = 2

return ("https://groovestats.com/qr.php?h=%s&s=%s&f=%s&r=%s&v=%d"):format(hash, score, failed, rate, qr_version)
