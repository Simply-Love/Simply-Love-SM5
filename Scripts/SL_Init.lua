-- This script needs to be loaded before other scripts that use it.

local PlayerDefaults = {
	__index = {
		initialize = function(self)
			self.ActiveModifiers = {
				JudgmentGraphic = "Love",
				Mini = "0%",
				BackgroundFilter = "Off",
				SpeedModType = "x",
				SpeedMod = 1.00,
				Vocalization = "None",
				Noteskin = nil,
				HideTargets = false,
				HideSongBG = false,
				HideCombo = false,
				HideLifebar = false,
				HideScore = false,
				ColumnFlashOnMiss = false,
				SubtractiveScoring = false,
				MeasureCounter = "None",
			}
			self.Streams = {
				SongDir = nil,
				StepsType = nil,
				Difficulty = nil,
				Measures = nil,
			}
			self.HighScores = {
				EnteringName = false,
				Name = ""
			}
			self.Stages = {
				Stats = {}
			}
			self.CurrentPlayerOptions = {
				String = nil
			}
		end
	}
}

local GlobalDefaults = {
	__index = {

		-- since the initialize() function is run every game cycle, the idea
		-- is to define variables we want to reset every game cycle inside
		initialize = function(self)
			self.ActiveModifiers = {
				MusicRate = 1.0,
			}
			self.Stages = {
				PlayedThisGame = 0,
				Remaining = PREFSMAN:GetPreference("SongsPerPlay"),
				MusicRate = {},
				Stats = {}
			}
			self.ScreenAfter = {
				PlayAgain = "ScreenEvaluationSummary",
				PlayerOptions = "ScreenGameplay",
				PlayerOptions2 = "ScreenGameplay"
			}
			self.ContinuesRemaining = ThemePrefs.Get("NumberOfContinuesAllowed") or 0
			self.Gamestate = {
				Style = "single"
			}
		end,

		-- This won't be reset each game cycle,
		-- but is rather to be updated (maybe) on ScreenSelectColor
		ActiveColorIndex = ThemePrefs.Get("SimplyLoveColor") or 1,

		-- This will be assigned value only once, upon starting StepMania, and should NOT be
		-- reset each game cycle. Instead, we'll use this to check if the TimingWindowScale
		-- preference has changed and needs to be reset back to its initial state.
		-- Thus, define this outside the scope of initialize() above.  The values in there
		-- are reset each game cycle.
		InitialTimingWindowScale = PREFSMAN:GetPreference("TimingWindowScale")
	}
}

-- "SL" is a general-purpose table that can be accessed from anywhere
-- within the theme and stores info that needs to be passed between screens
SL = {
	P1 = setmetatable( {}, PlayerDefaults),
	P2 = setmetatable( {}, PlayerDefaults),
	Global = setmetatable( {}, GlobalDefaults),
	Colors = {
		"#FF3C23",
	    "#FF003C",
	    "#C1006F",
	    "#8200A1",
	    "#413AD0",
	    "#0073FF",
	    "#00ADC0",
	    "#5CE087",
	    "#AEFA44",
	    "#FFFF00",
	    "#FFBE00",
	    "#FF7D00"
	}
}


-- Initialize preferences by calling this method.
--  We typically do this from ./BGAnimations/ScreenTitleMenu underlay.lua
--  so that preferences reset between each game cycle.

function InitializeSimplyLove()
	SL.P1:initialize()
	SL.P2:initialize()
	SL.Global:initialize()

	if PREFSMAN:GetPreference("TimingWindowScale") ~= SL.Global.InitialTimingWindowScale then
		PREFSMAN:SetPreference("TimingWindowScale", SL.Global.InitialTimingWindowScale)
	end
end

-- TODO: remove this; it's for debugging purposes (Control+F2 to reload scripts) only
InitializeSimplyLove()
