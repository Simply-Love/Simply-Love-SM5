-- This script needs to be loaded before other scripts that use it.

local PlayerDefaults = {
	__index = {
		initialize = function(self)
			self.ActiveModifiers = {
				SpeedModType = "X",
				SpeedMod = 1.00,
				JudgmentGraphic = "Love 2x6 (doubleres).png",
				ComboFont = "Wendy",
				HoldJudgment = "Love 1x2 (doubleres).png",
				NoteSkin = nil,
				Mini = "0%",
				BackgroundFilter = "Off",
				VisualDelay = "0ms",

				HideTargets = false,
				HideSongBG = false,
				HideCombo = false,
				HideLifebar = false,
				HideScore = false,
				HideDanger = false,
				HideComboExplosions = false,

				ColumnFlashOnMiss = false,
				SubtractiveScoring = false,
				MeasureCounter = "None",
				MeasureCounterLeft = true,
				MeasureCounterUp = false,
				DataVisualizations = "None",
				StepStatsExtra = "None",
				TargetScore = 11,
				ActionOnMissedTarget = "Nothing",
				Pacemaker = false,
				LifeMeterType = "Standard",
				MissBecauseHeld = false,
				NPSGraphAtTop = false,
				JudgmentTilt = false,
				ColumnCues = false,
				DisplayScorebox = true,

				ErrorBar = "None",
				ErrorBarUp = false,
				ErrorBarMultiTick = false,
				ErrorBarCap = 5,

				TimingWindows = {true, true, true, true, true},
				ShowFaPlusWindow = false,
				ShowEXScore = false,
				ShowFaPlusPane = true,
				
				FlashMiss = true,
				FlashWayOff = false,
				FlashDecent = false,
				FlashGreat = false,
				FlashExcellent = false,
				FlashFantastic = false,
			}
			-- TODO(teejusb): Rename "Streams" as the data contains more information than that.
			self.Streams = {
				-- Chart identifiers for caching purposes.
				Filename = "",
				StepsType = "",
				Difficulty = "",
				Description = "",

				-- Information parsed out from the chart.
				NotesPerMeasure = {},
				PeakNPS = 0,
				NPSperMeasure = {},
				columnCues = {},
				Hash = '',

				Crossovers = 0,
				Footswitches = 0,
				Sideswitches = 0,
				Jacks = 0,
				Brackets = 0,

				-- Data for measure counter. Populated in ./ScreenGameplay in/MeasureCounterAndMods.lua.
				-- Uses the notesThreshold option.
				Measures = {},
			}
			self.HighScores = {
				EnteringName = false,
				Name = ""
			}
			self.Stages = {
				Stats = {}
			}
			self.PlayerOptionsString = nil
			self.ITLData = {}

			-- default panes to intialize ScreenEvaluation to
			-- when only a single player is joined (single, double)
			-- in versus (2 players joined) only EvalPanePrimary will be used
			self.EvalPanePrimary   = 1 -- large score and judgment counts
			self.EvalPaneSecondary = 5 -- offset histogram

			-- The Groovestats API key loaded for this player
			self.ApiKey = ""
			-- Whether or not the player is playing on pad.
			self.IsPadPlayer = false
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
			}
			self.Stages = {
				PlayedThisGame = 0,
				Remaining = PREFSMAN:GetPreference("SongsPerPlay"),
				Stats = {}
			}
			self.ScreenAfter = {
				PlayAgain = "ScreenEvaluationSummary",
				PlayerOptions  = "ScreenGameplay",
				PlayerOptions2 = "ScreenGameplay",
				PlayerOptions3 = "ScreenGameplay",
				PlayerOptions4 = "ScreenGameplay",
			}
			self.ContinuesRemaining = ThemePrefs.Get("NumberOfContinuesAllowed") or 0
			self.GameMode = ThemePrefs.Get("DefaultGameMode") or "ITG"
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

			self.GameplayReloadCheck = false
			-- How long to wait before displaying a "cue"
			self.ColumnCueMinTime = 1.5
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
	-- These colors are used for text on dark backgrounds and backgrounds containing dark text:
	Colors = {
		"#FF5D47",
		"#FF577E",
		"#FF47B3",
		"#DD57FF",
		"#8885ff",
		"#3D94FF",
		"#00B8CC",
		"#5CE087",
		"#AEFA44",
		"#FFFF00",
		"#FFBE00",
		"#FF7D00",
	},
	-- These are the original SL colors. They're used for decorative (non-text) elements, like the background hearts:
	DecorativeColors = {
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
	-- These judgment colors are used for text & numbers on dark backgrounds:
	JudgmentColors = {
		Casual = {
			color("#21CCE8"),	-- blue
			color("#e29c18"),	-- gold
			color("#66c955"),	-- green
			color("#b45cff"),	-- purple (greatly lightened)
			color("#c9855e"),	-- peach?
			color("#ff3030")	-- red (slightly lightened)
		},
		ITG = {
			color("#21CCE8"),	-- blue
			color("#e29c18"),	-- gold
			color("#66c955"),	-- green
			color("#b45cff"),	-- purple (greatly lightened)
			color("#c9855e"),	-- peach?
			color("#ff3030")	-- red (slightly lightened)
		},
		["FA+"] = {
			color("#21CCE8"),	-- blue
			color("#ffffff"),	-- white
			color("#e29c18"),	-- gold
			color("#66c955"),	-- green
			color("#b45cff"),	-- purple (greatly lightened)
			color("#ff3030")	-- red (slightly lightened)
		},
	},
	Preferences = {
		Casual = {
			TimingWindowAdd=0.0015,
			RegenComboAfterMiss=0,
			MaxRegenComboAfterMiss=0,
			MinTNSToHideNotes="TapNoteScore_W3",
			HarshHotLifePenalty=true,

			PercentageScoring=true,
			AllowW1="AllowW1_Everywhere",
			SubSortByNumSteps=true,

			TimingWindowSecondsW1=0.021500,
			TimingWindowSecondsW2=0.043000,
			TimingWindowSecondsW3=0.102000,
			TimingWindowSecondsW4=0.102000,
			TimingWindowSecondsW5=0.102000,
			TimingWindowSecondsHold=0.320000,
			TimingWindowSecondsMine=0.070000,
			TimingWindowSecondsRoll=0.350000,
		},
		ITG = {
			TimingWindowAdd=0.0015,
			RegenComboAfterMiss=5,
			MaxRegenComboAfterMiss=10,
			MinTNSToHideNotes="TapNoteScore_W3",
			HarshHotLifePenalty=true,

			PercentageScoring=true,
			AllowW1="AllowW1_Everywhere",
			SubSortByNumSteps=true,

			TimingWindowSecondsW1=0.021500,
			TimingWindowSecondsW2=0.043000,
			TimingWindowSecondsW3=0.102000,
			TimingWindowSecondsW4=0.135000,
			TimingWindowSecondsW5=0.180000,
			TimingWindowSecondsHold=0.320000,
			TimingWindowSecondsMine=0.070000,
			TimingWindowSecondsRoll=0.350000,
		},
		["FA+"] = {
			TimingWindowAdd=0.0015,
			RegenComboAfterMiss=5,
			MaxRegenComboAfterMiss=10,
			MinTNSToHideNotes="TapNoteScore_W4",
			HarshHotLifePenalty=true,

			PercentageScoring=true,
			AllowW1="AllowW1_Everywhere",
			SubSortByNumSteps=true,

			TimingWindowSecondsW1=0.013500,
			TimingWindowSecondsW2=0.021500,
			TimingWindowSecondsW3=0.043000,
			TimingWindowSecondsW4=0.102000,
			TimingWindowSecondsW5=0.135000,
			TimingWindowSecondsHold=0.320000,
			-- NOTE(teejusb): FA+ mode previously had mines set to
			-- 65ms instead of the actual window size of 70ms. This
			-- was to account for "SM5 Mines" but now with the patch here:
			-- https://gist.github.com/DinsFire64/4a3f763cd3033afd55a176980b32a3b5
			-- and the development in the thread here:
			-- https://github.com/stepmania/stepmania/issues/1896
			-- it's as good as "fixed" for the very very large majority of
			-- cases so we can set this back to 70ms now.
			TimingWindowSecondsMine=0.070000,
			TimingWindowSecondsRoll=0.350000,
		},
	},
	Metrics = {
		-- The PercentScoreWeightCheckpointHit and
		-- GradeWeightCheckpointHit metrics are only used in pump game
		-- mode. We have to set them to 0 for two reasons:
		-- 1. Due to an inconsistency in the game engine the score for
		--    perfect play adds up to less than 100% when
		--    PercentScoreWeightCheckpointHit is > 0.
		-- 2. It brings the scoring in pump mode closer to PIU scoring,
		--    which does not award points for held checkpoints, but
		--    only penalizes missed checkpoints.

		Casual = {
			PercentScoreWeightW1=3,
			PercentScoreWeightW2=2,
			PercentScoreWeightW3=1,
			PercentScoreWeightW4=0,
			PercentScoreWeightW5=0,
			PercentScoreWeightMiss=0,
			PercentScoreWeightLetGo=0,
			PercentScoreWeightHeld=IsGame("pump") and 0 or 3,
			PercentScoreWeightHitMine=-1,
			PercentScoreWeightCheckpointHit=0,

			GradeWeightW1=3,
			GradeWeightW2=2,
			GradeWeightW3=1,
			GradeWeightW4=0,
			GradeWeightW5=0,
			GradeWeightMiss=0,
			GradeWeightLetGo=0,
			GradeWeightHeld=IsGame("pump") and 0 or 3,
			GradeWeightHitMine=-1,
			GradeWeightCheckpointHit=0,

			LifePercentChangeW1=0,
			LifePercentChangeW2=0,
			LifePercentChangeW3=0,
			LifePercentChangeW4=0,
			LifePercentChangeW5=0,
			LifePercentChangeMiss=0,
			LifePercentChangeLetGo=0,
			LifePercentChangeHeld=0,
			LifePercentChangeHitMine=0,

			InitialValue=0.5,
		},
		ITG = {
			PercentScoreWeightW1=5,
			PercentScoreWeightW2=4,
			PercentScoreWeightW3=2,
			PercentScoreWeightW4=0,
			PercentScoreWeightW5=-6,
			PercentScoreWeightMiss=-12,
			PercentScoreWeightLetGo=0,
			PercentScoreWeightHeld=IsGame("pump") and 0 or 5,
			PercentScoreWeightHitMine=-6,
			PercentScoreWeightCheckpointHit=0,

			GradeWeightW1=5,
			GradeWeightW2=4,
			GradeWeightW3=2,
			GradeWeightW4=0,
			GradeWeightW5=-6,
			GradeWeightMiss=-12,
			GradeWeightLetGo=0,
			GradeWeightHeld=IsGame("pump") and 0 or 5,
			GradeWeightHitMine=-6,
			GradeWeightCheckpointHit=0,

			LifePercentChangeW1=0.008,
			LifePercentChangeW2=0.008,
			LifePercentChangeW3=0.004,
			LifePercentChangeW4=0.000,
			LifePercentChangeW5=-0.050,
			LifePercentChangeMiss=-0.100,
			LifePercentChangeLetGo=IsGame("pump") and 0.000 or -0.080,
			LifePercentChangeHeld=IsGame("pump") and 0.000 or 0.008,
			LifePercentChangeHitMine=-0.050,

			InitialValue=0.5,
		},
		["FA+"] = {
			PercentScoreWeightW1=5,
			PercentScoreWeightW2=5,
			PercentScoreWeightW3=4,
			PercentScoreWeightW4=2,
			PercentScoreWeightW5=0,
			PercentScoreWeightMiss=-12,
			PercentScoreWeightLetGo=0,
			PercentScoreWeightHeld=IsGame("pump") and 0 or 5,
			PercentScoreWeightHitMine=-6,
			PercentScoreWeightCheckpointHit=0,

			GradeWeightW1=5,
			GradeWeightW2=5,
			GradeWeightW3=4,
			GradeWeightW4=2,
			GradeWeightW5=0,
			GradeWeightMiss=-12,
			GradeWeightLetGo=0,
			GradeWeightHeld=IsGame("pump") and 0 or 5,
			GradeWeightHitMine=-6,
			GradeWeightCheckpointHit=0,

			LifePercentChangeW1=0.008,
			LifePercentChangeW2=0.008,
			LifePercentChangeW3=0.008,
			LifePercentChangeW4=0.004,
			LifePercentChangeW5=0,
			LifePercentChangeMiss=-0.1,
			LifePercentChangeLetGo=IsGame("pump") and 0.000 or -0.080,
			LifePercentChangeHeld=IsGame("pump") and 0.000 or 0.008,
			LifePercentChangeHitMine=-0.05,

			InitialValue=0.5,
		},
	},
	ExWeights = {
		-- W0 is not necessarily a "real" window.
		-- In ITG mode it is emulated based off the value of TimingWindowW1 defined
		-- for FA+ mode.
		W0=3.5,
		W1=3,
		W2=2,
		W3=1,
		W4=0,
		W5=0,
		Miss=0,
		LetGo=0,
		Held=1,
		HitMine=-1
	},
	-- Fields used to determine whether or not we can connect to the
	-- GrooveStats services.
	GrooveStats = {
		-- Whether we're connected to the internet or not.
		-- Determined once on boot in ScreenSystemLayer.
		IsConnected = false,

		-- Available GrooveStats services. Subject to change while
		-- StepMania is running.
		GetScores = false,
		Leaderboard = false,
		AutoSubmit = false,

		-- ************* CURRENT QR VERSION *************
		-- * Update whenever we change relevant QR code *
		-- *  and when GrooveStats backend is also      *
		-- *   updated to properly consume this value.  *
		-- **********************************************
		ChartHashVersion = 3,

		-- We want to cache the some of the requests/responses to prevent making the
		-- same request multiple times in a small timeframe.
		-- Each entry is keyed with some string hash which maps to a table with the
		-- following keys:
		--   Response: string, the JSON-ified response to cache
		--   Timestamp: number, when the request was made
		RequestCache = {},

		-- Used to prevent redundant downloads for SRPG unlocks.
		-- Each entry is keyed on the URL of the download which maps to a table of
		-- PackNames the unlock has been unpacked to.
		-- To see if we have already downloaded an unlock, one can just key on
		-- SL.UnlocksCache[url][packName]
		-- LoadUnlocksCache() is defined in SL-Helpers-GrooveStats.lua so that must
		-- be loaded before this file.
		UnlocksCache = LoadUnlocksCache(),
	},
	-- Stores all active/failed downloads.
	-- Each entry is keyed on a string UUID which maps to a table with the
	-- following keys:
	--    Request: HttpRequestFuture, the closure returned by NETWORK:HttpRequest
	--    Name: string, an identifier for this download.
	--    Url: string, The URL of the download.
	--    Destination: string, where the download should be unpacked to.
	--    CurrentBytes: number, the bytes downloaded so far
	--    TotalBytes: number, the total bytes of the file
	--    Complete: bool, whether or not the download has completed
	--              (either success or failure).
	-- If a request fails, there will be another key:
	--    ErrorMessage: string, the reasoning for the failure.
	Downloads = {}
}


-- Initialize preferences by calling this method.  We typically do
-- this from ./BGAnimations/ScreenTitleMenu underlay/default.lua
-- so that preferences reset between each game cycle.

function InitializeSimplyLove()
	SL.P1:initialize()
	SL.P2:initialize()
	SL.Global:initialize()
end

InitializeSimplyLove()
