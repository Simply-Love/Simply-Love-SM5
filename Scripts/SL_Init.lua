-- This script needs to be loaded before other scripts that use it.

local PlayerDefaults = {
	__index = {
		initialize = function(self)
			self.ActiveModifiers = {
				JudgmentGraphic = "Love",
				Mini = "Normal",
				ScreenFilter = "Off",
				SpeedModType = "x",
				SpeedMod = 1.00,
				Vocalization = "None"
			}
			self.HighScores = {
				EnteringName = false,
				Name = nil
			}
			self.Stages = {
				Stats = {}
			}
			self.CurrentPlayerOptions = 
			{
				String = nil
			}
		end
	}
}

local GlobalDefaults = {
	__index = {
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
			self.ContinuesRemaining = SL_CustomPrefs:get_data().NumberOfContinuesAllowed
			self.Gamestate = {
				Style = "single"
			}
		end
	}
}


-- "SL" is a general-purpose table that can be accessed from anywhere
-- within the theme and stores info that needs to be passed between screens
SL = {
	P1 = setmetatable( {}, PlayerDefaults),
	P2 = setmetatable( {}, PlayerDefaults),
	Global = setmetatable( {}, GlobalDefaults),
}

function InitializeSimplyLove()
	SL.P1:initialize()
	SL.P2:initialize()
	SL.Global:initialize()
end

-- Initialize preferences now (when this script is loaded when StepMania is initializing)
-- and also from ScreenTitleMenu underlay.lua so that preferences reset between each game.
InitializeSimplyLove()