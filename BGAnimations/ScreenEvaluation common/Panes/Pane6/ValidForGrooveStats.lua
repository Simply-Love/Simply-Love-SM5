local player = ...

local valid = {}

-- ------------------------------------------
-- First, check for modes not supported by GrooveStats.

-- GrooveStats only supports dance for now (not pump, techno, etc.)
valid[1] = GAMESTATE:GetCurrentGame():GetName() == "dance"

-- GrooveStats does not support dance-solo (i.e. 6-panel dance like DDR Solo 4th Mix)
-- https://en.wikipedia.org/wiki/Dance_Dance_Revolution_Solo
valid[2] = GAMESTATE:GetCurrentStyle():GetName() ~= "solo"

-- GrooveStats does rank Marathons from ITG1, ITG2, and ITG Home
-- but there isn't QR support at this time.
valid[3] = not GAMESTATE:IsCourseMode()

-- GrooveStats was made with ITG settings in mind.
-- FA+ is okay because it just halves ITG's TimingWindowW1 but keeps everything else the same.
-- Casual (and Experimental, Demonic, etc.) uses different settings
-- that are incompatible with GrooveStats ranking.
valid[4] = (SL.Global.GameMode == "ITG" or SL.Global.GameMode == "FA+")

-- ------------------------------------------
-- Next, check global Preferences that would invalidate the score.

-- TimingWindowScale and LifeDifficultyScale are a little confusing. Players can change these under
-- Advanced Options in the operator menu on scales from [1 to Justice] and [1 to 7], respectively.
--
-- The OptionRow for TimingWindowScale offers [1, 2, 3, 4, 5, 6, 7, 8, Justice] as options
-- and these map to [1.5, 1.33, 1.16, 1, 0.84, 0.66, 0.5, 0.33, 0.2] in Preferences.ini for internal use.
--
-- The OptionRow for LifeDifficultyScale offers [1, 2, 3, 4, 5, 6, 7] as options
-- and these map to [1.6, 1.4, 1.2, 1, 0.8, 0.6, 0.4] in Preferences.ini for internal use.
--
-- I don't know the history here, but I suspect these preferences are holdovers from SM3.9 when
-- themes were just visual skins and core mechanics like TimingWindows and Life scaling could only
-- be handled by the SM engine.  Whatever the case, they're still exposed as options in the
-- operator menu and players still play around with them, so we need to handle that here.
--
-- 4 (1, internally) is considered standard for ITG.
-- GrooveStats expects players to have both these set to 4 (1, internally).
valid[5] = PREFSMAN:GetPreference("TimingWindowScale") == 1
valid[6] = PREFSMAN:GetPreference("LifeDifficultyScale") == 1

-- ------------------------------------------
-- Finally, check player-specific modifiers used during this song that would invalidate the score.

-- get playeroptions so we can check mods the player used
local po = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")


-- score is invalid if notes were removed
valid[7] = not (
	   po:Little()  or po:NoHolds() or po:NoStretch()
	or po:NoHands() or po:NoJumps() or po:NoFakes()
	or po:NoLifts() or po:NoQuads() or po:NoRolls()
)

-- score is invalid if notes were added
valid[8] = not (
	   po:Wide() or po:Skippy() or po:Quick()
	or po:Echo() or po:BMRize() or po:Stomp()
	or po:Big()
)

-- only FailTypes "Immediate" and "ImmediateContinue" are valid for GrooveStats
valid[9] = (po:FailSetting() == "FailType_Immediate" or po:FailSetting() == "FailType_ImmediateContinue")

-- ------------------------------------------
-- return the entire table so that we can let the player know which settings,
-- if any, prevented their score from being valid for GrooveStats

return valid