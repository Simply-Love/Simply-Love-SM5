-- This script needs to be loaded before other scripts that use it.

local PlayerDefaults = {
	__index = {
		initialize = function(self)
			self.ActiveModifiers = {
				JudgmentGraphic = "Love 2x6.png",
				Mini = "0%",
				BackgroundFilter = "Off",
				SpeedModType = "x",
				SpeedMod = 1.00,
				Vocalization = "None",
				NoteSkin = nil,
				HideTargets = false,
				HideSongBG = false,
				HideCombo = false,
				HideLifebar = false,
				HideScore = false,
				HideDanger = false,
				HideComboExplosions = false,
				ColumnFlashOnMiss = false,
				SubtractiveScoring = false,
				MeasureCounterLeft = true,
				MeasureCounterUp = false,
				MeasureCounter = "None",
				DataVisualizations = "Disabled",
				TargetScore = 11,
				ActionOnMissedTarget = "Nothing",
				Pacemaker = false,
				ReceptorArrowsPosition = "StomperZ",
				LifeMeterType = "Standard",
				MissBecauseHeld = false,
				NPSGraphAtTop = false,
				Vocalization = "None",
			}
			self.Streams = {
				SongDir = nil,
				StepsType = nil,
				Difficulty = nil,
				Measures = nil,
			}
			self.NoteDensity = {
				Peak = nil
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

		-- since the initialize() function is called every game cycle, the idea
		-- is to define variables we want to reset every game cycle inside
		initialize = function(self)
			self.ActiveModifiers = {
				MusicRate = 1.0,
				WorstTimingWindow = 5,
			}
			self.Stages = {
				PlayedThisGame = 0,
				Remaining = PREFSMAN:GetPreference("SongsPerPlay"),
				Stats = {}
			}
			self.ScreenAfter = {
				PlayAgain = "ScreenEvaluationSummary",
				PlayerOptions = "ScreenGameplay",
				PlayerOptions2 = "ScreenGameplay"
			}
			self.ContinuesRemaining = ThemePrefs.Get("NumberOfContinuesAllowed") or 0
			self.GameMode = ThemePrefs.Get("DefaultGameMode") or "Competitive"
			self.ScreenshotTexture = nil
			self.MenuTimer = {
				ScreenSelectMusic = ThemePrefs.Get("ScreenSelectMusicMenuTimer"),
				ScreenSelectMusicCasual = ThemePrefs.Get("ScreenSelectMusicCasualMenuTimer"),
				ScreenPlayerOptions = ThemePrefs.Get("ScreenPlayerOptionsMenuTimer"),
				ScreenEvaluation = ThemePrefs.Get("ScreenEvaluationMenuTimer"),
				ScreenEvaluationSummary = ThemePrefs.Get("ScreenEvaluationSummaryMenuTimer"),
				ScreenNameEntry = ThemePrefs.Get("ScreenNameEntryMenuTimer"),
			}
			self.TimeAtSessionStart = nil
		end,

		-- These values outside initialize() won't be reset each game cycle,
		-- but are rather manipulated as needed by the theme.
		ActiveColorIndex = ThemePrefs.Get("SimplyLoveColor") or 1,
	}
}

-- "SL" is a general-purpose table that can be accessed from anywhere
-- within the theme and stores info that needs to be passed between screens
SL = {
	P1 = setmetatable( {}, PlayerDefaults),
	P2 = setmetatable( {}, PlayerDefaults),
	Global = setmetatable( {}, GlobalDefaults),
	-- Colors that Simply Love's background can be
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
	},
	JudgmentColors = {
		Casual = {
			color("#21CCE8"),	-- blue
			color("#e29c18"),	-- gold
			color("#66c955"),	-- green
			color("#5b2b8e"),	-- purple
			color("#c9855e"),	-- peach?
			color("#ff0000")	-- red
		},
		Competitive = {
			color("#21CCE8"),	-- blue
			color("#e29c18"),	-- gold
			color("#66c955"),	-- green
			color("#5b2b8e"),	-- purple
			color("#c9855e"),	-- peach?
			color("#ff0000")	-- red
		},
		ECFA = {
			color("#21CCE8"),	-- blue
			color("#ffffff"),	-- white
			color("#e29c18"),	-- gold
			color("#66c955"),	-- green
			color("#5b2b8e"),	-- purple
			color("#ff0000")	-- red
		},
		StomperZ = {
			color("#5b2b8e"),	-- purple
			color("#0073ff"),	-- dark blue
			color("#66c955"),	-- green
			color("#e29c18"),	-- gold
			color("#dddddd"),	-- grey
			color("#ff0000")	-- red
		}
	},
	Preferences = {
		Casual = {
			TimingWindowAdd=ThemePrefs.Get("TimingWindowAdd"),
			RegenComboAfterMiss=0,
			MaxRegenComboAfterMiss=0,
			MinTNSToHideNotes="TapNoteScore_W3",
			HarshHotLifePenalty=1,

			PercentageScoring=1,
			AllowW1="AllowW1_Everywhere",
			SubSortByNumSteps=1,

			TimingWindowSecondsW1=0.021500,
			TimingWindowSecondsW2=0.043000,
			TimingWindowSecondsW3=0.102000,
			TimingWindowSecondsW4=0.102000,
			TimingWindowSecondsW5=0.102000,
			TimingWindowSecondsHold=0.320000,
			TimingWindowSecondsMine=0.070000,
			TimingWindowSecondsRoll=0.350000,
		},
		Competitive = {
			TimingWindowAdd=ThemePrefs.Get("TimingWindowAdd"),
			RegenComboAfterMiss=5,
			MaxRegenComboAfterMiss=10,
			MinTNSToHideNotes="TapNoteScore_W3",
			HarshHotLifePenalty=1,

			PercentageScoring=1,
			AllowW1="AllowW1_Everywhere",
			SubSortByNumSteps=1,

			TimingWindowSecondsW1=0.021500,
			TimingWindowSecondsW2=0.043000,
			TimingWindowSecondsW3=0.102000,
			TimingWindowSecondsW4=0.135000,
			TimingWindowSecondsW5=0.180000,
			TimingWindowSecondsHold=0.320000,
			TimingWindowSecondsMine=0.070000,
			TimingWindowSecondsRoll=0.350000,
		},
		ECFA = {
			TimingWindowAdd=0.0015,
			RegenComboAfterMiss=5,
			MaxRegenComboAfterMiss=10,
			MinTNSToHideNotes="TapNoteScore_W4",
			HarshHotLifePenalty=1,

			PercentageScoring=1,
			AllowW1="AllowW1_Everywhere",
			SubSortByNumSteps=1,

			TimingWindowSecondsW1=0.011000,
			TimingWindowSecondsW2=0.021500,
			TimingWindowSecondsW3=0.043000,
			TimingWindowSecondsW4=0.102000,
			TimingWindowSecondsW5=0.135000,
			TimingWindowSecondsHold=0.320000,
			TimingWindowSecondsMine=0.065000,
			TimingWindowSecondsRoll=0.350000,
		},
		StomperZ = {
			TimingWindowAdd=0,
			RegenComboAfterMiss=0,
			MaxRegenComboAfterMiss=0,
			MinTNSToHideNotes="TapNoteScore_W4",
			HarshHotLifePenalty=0,

			PercentageScoring=1,
			AllowW1="AllowW1_Everywhere",
			SubSortByNumSteps=1,

			TimingWindowSecondsW1=0.012500,
			TimingWindowSecondsW2=0.025000,
			TimingWindowSecondsW3=0.050000,
			TimingWindowSecondsW4=0.100000,
			TimingWindowSecondsW5=0.10000,
			TimingWindowSecondsHold=0.20000,
			TimingWindowSecondsMine=0.070000,
			TimingWindowSecondsRoll=0.350000,
		},
	},
	Metrics = {
		Casual = {
			PercentScoreWeightW1=3,
			PercentScoreWeightW2=2,
			PercentScoreWeightW3=1,
			PercentScoreWeightW4=0,
			PercentScoreWeightW5=0,
			PercentScoreWeightMiss=0,
			PercentScoreWeightLetGo=0,
			PercentScoreWeightHeld=3,
			PercentScoreWeightHitMine=-1,

			GradeWeightW1=3,
			GradeWeightW2=2,
			GradeWeightW3=1,
			GradeWeightW4=0,
			GradeWeightW5=0,
			GradeWeightMiss=0,
			GradeWeightLetGo=0,
			GradeWeightHeld=3,
			GradeWeightHitMine=-1,

			LifePercentChangeW1=0,
			LifePercentChangeW2=0,
			LifePercentChangeW3=0,
			LifePercentChangeW4=0,
			LifePercentChangeW5=0,
			LifePercentChangeMiss=0,
			LifePercentChangeLetGo=0,
			LifePercentChangeHeld=0,
			LifePercentChangeHitMine=0,
		},
		Competitive = {
			PercentScoreWeightW1=5,
			PercentScoreWeightW2=4,
			PercentScoreWeightW3=2,
			PercentScoreWeightW4=0,
			PercentScoreWeightW5=-6,
			PercentScoreWeightMiss=-12,
			PercentScoreWeightLetGo=0,
			PercentScoreWeightHeld=5,
			PercentScoreWeightHitMine=-6,

			GradeWeightW1=5,
			GradeWeightW2=4,
			GradeWeightW3=2,
			GradeWeightW4=0,
			GradeWeightW5=-6,
			GradeWeightMiss=-12,
			GradeWeightLetGo=0,
			GradeWeightHeld=5,
			GradeWeightHitMine=-6,

			LifePercentChangeW1=0.008,
			LifePercentChangeW2=0.008,
			LifePercentChangeW3=0.004,
			LifePercentChangeW4=0.000,
			LifePercentChangeW5=-0.050,
			LifePercentChangeMiss=-0.100,
			LifePercentChangeLetGo=IsGame("pump") and 0.000 or -0.080,
			LifePercentChangeHeld=IsGame("pump") and 0.000 or 0.008,
			LifePercentChangeHitMine=-0.050,
		},
		ECFA = {
			PercentScoreWeightW1=5,
			PercentScoreWeightW2=5,
			PercentScoreWeightW3=4,
			PercentScoreWeightW4=2,
			PercentScoreWeightW5=0,
			PercentScoreWeightMiss=-12,
			PercentScoreWeightLetGo=0,
			PercentScoreWeightHeld=5,
			PercentScoreWeightHitMine=-6,

			GradeWeightW1=5,
			GradeWeightW2=5,
			GradeWeightW3=4,
			GradeWeightW4=2,
			GradeWeightW5=0,
			GradeWeightMiss=-12,
			GradeWeightLetGo=0,
			GradeWeightHeld=5,
			GradeWeightHitMine=-6,

			LifePercentChangeW1=0.008,
			LifePercentChangeW2=0.008,
			LifePercentChangeW3=0.008,
			LifePercentChangeW4=0.004,
			LifePercentChangeW5=0,
			LifePercentChangeMiss=-0.1,
			LifePercentChangeLetGo=-0.08,
			LifePercentChangeHeld=0.008,
			LifePercentChangeHitMine=-0.05,
		},
		StomperZ = {
			PercentScoreWeightW1=10,
			PercentScoreWeightW2=9,
			PercentScoreWeightW3=8,
			PercentScoreWeightW4=5,
			PercentScoreWeightW5=0,
			PercentScoreWeightMiss=0,
			PercentScoreWeightLetGo=0,
			PercentScoreWeightHeld=10,
			PercentScoreWeightHitMine=-5,

			GradeWeightW1=10,
			GradeWeightW2=9,
			GradeWeightW3=8,
			GradeWeightW4=5,
			GradeWeightW5=0,
			GradeWeightMiss=0,
			GradeWeightLetGo=0,
			GradeWeightHeld=10,
			GradeWeightHitMine=-5,

			LifePercentChangeW1=0.004,
			LifePercentChangeW2=0.004,
			LifePercentChangeW3=0.004,
			LifePercentChangeW4=0.004,
			LifePercentChangeW5=0,
			LifePercentChangeMiss=-0.04,
			LifePercentChangeLetGo=-0.04,
			LifePercentChangeHeld=0,
			LifePercentChangeHitMine=-0.04,
		},
	}
}


-- Initialize preferences by calling this method.
-- We typically do this from ./BGAnimations/ScreenTitleMenu underlay/default.lua
-- so that preferences reset between each game cycle.

function InitializeSimplyLove()
	SL.P1:initialize()
	SL.P2:initialize()
	SL.Global:initialize()
end

-- TODO: remove this; it's for debugging purposes (Control+F2 to reload scripts) only
InitializeSimplyLove()
