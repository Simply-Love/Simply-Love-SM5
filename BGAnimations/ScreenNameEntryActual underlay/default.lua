-- Why bother having two distinct name entry screens?  Well, sit down, and I'll tell you a story...

-- ScreenNameEntryTraditional has certain very helpful methods that are only available to it.
-- GetEnteringName() is only available to ScreenNameEntryTraditional and is used to determine
-- which players, if any, are entering highscore names.

-- One thing that ScreenNameEntryTraditional lacks, however, is the ability to listen for message commands
-- like MenuRightP1MessageCommand and MenuLeftP2MessageCommand. Those are very helpful when you want a player
-- to be able to hold down a menu button to contine scrolling through letters.
-- I did try, briefly, to set codes in Metrics for "held" and "released" menubuttons to recreate this functionality,
-- but the results were less than satisfactory.

-- So, use ScreenNameEntryTraditional to determine which players are entering highscore names, set an env value,
-- and proceed to ScreenNameEntryActual.  On ScreenNameEntryActual, have players enter their names if necessary,
-- and eventually save those names using GAMESTATE:StoreRankingName()

local Players = GAMESTATE:GetHumanPlayers()

-- how long should each song display for before cycling to the next
local durationPerSong = 4
-- get the number of stages that were played
local numStages = SL.Global.Stages.PlayedThisGame

local t = Def.ActorFrame {}

t[#t+1] = Def.ActorFrame {

	--fallback banner
	LoadActor( THEME:GetPathB("ScreenSelectMusic", "overlay/colored_banners/banner"..SimplyLoveColor()..".png"))..{
		OnCommand=cmd(xy, _screen.cx, 121.5; zoom, 0.7)
	},

	Def.Quad{
		Name="LeftMask";
		InitCommand=cmd(halign,0),
		OnCommand=cmd(xy, 0, _screen.cy; zoomto, _screen.cx-272, _screen.h; MaskSource)
	},

	Def.Quad{
		Name="CenterMask",
		OnCommand=cmd(Center; zoomto, 110, _screen.h; MaskSource)
	},

	Def.Quad{
		Name="RightMask",
		InitCommand=cmd(halign,1),
		OnCommand=cmd(xy, _screen.w, _screen.cy; zoomto, _screen.cx-272, _screen.h; MaskSource)
	}
}

-- Banner(s) and Title(s)
if GAMESTATE:IsCourseMode() then
	local course = GAMESTATE:GetCurrentCourse()

	t[#t+1] = LoadFont("_misoreg hires")..{
		Name="CourseName",
		InitCommand=cmd(xy, _screen.cx, 54; maxwidth, 294),
		OnCommand=function(self)
			if course then
				self:settext( course:GetDisplayFullTitle() )
			end
		end
	}

	t[#t+1] = Def.Sprite{
		Name="CourseBanner",
		InitCommand=cmd(xy, _screen.cx, 121.5 ),
		OnCommand=function(self)
			local bannerpath

			if course then
				 bannerpath = course:GetBannerPath()
			end

			if bannerpath then
				self:LoadBanner(bannerpath)
				self:setsize(418,164)
				self:zoom(0.7)
			end
		end
	}

else

	local currentStage = 1
	for i=numStages,1,-1 do

		local song = SL.Global.Stages.Stats[currentStage].song


		-- Create an ActorFrame for each Name + Banner pair
		-- so that we can display/hide all children simultaneously.
		local NameAndBanner = Def.ActorFrame{
			InitCommand=cmd(diffusealpha, 0),
			OnCommand=function(self)
				self:sleep(durationPerSong * (math.abs(i-numStages)) );
				self:queuecommand("Display")
			end,
			DisplayCommand=function(self)
				self:diffusealpha(1)
				self:sleep(durationPerSong)
				self:diffusealpha(0)
				self:queuecommand("Wait")
			end,
			WaitCommand=function(self)
				self:sleep(durationPerSong * (numStages-1))
				self:queuecommand("Display")
			end
		}

		NameAndBanner[#NameAndBanner+1] = LoadFont("_misoreg hires")..{
			Name="SongName"..i,
			InitCommand=cmd(xy, _screen.cx, 54; maxwidth, 294),
			OnCommand=function(self)
				if song then
					self:settext( song:GetDisplayMainTitle() )
				end
			end
		}


		NameAndBanner[#NameAndBanner+1] = Def.Sprite{
			Name="SongBanner"..i,
			InitCommand=cmd(xy, _screen.cx, 121.5),
			OnCommand=function(self)
				local bannerpath
				if song then
					 bannerpath = song:GetBannerPath()
				end

				if bannerpath then
					self:LoadBanner(bannerpath)
					self:setsize(418,164)
					self:zoom(0.7)
				end
			end

		}

		-- add each NameAndBanner ActorFrame to the primary ActorFrame
		t[#t+1] = NameAndBanner
		currentStage = currentStage + 1
	end
end




t[#t+1] = Def.Actor {
	DoneEnteringNameP1MessageCommand=function(self)
		SL.P1.HighScores.EnteringName = false
		self:queuecommand("AttemptToFinish")
	end,
	DoneEnteringNameP2MessageCommand=function(self)
		SL.P2.HighScores.EnteringName = false
		self:queuecommand("AttemptToFinish")
	end,
	CodeMessageCommand=function(self, params)
		if params.Name == "Enter" then
			self:queuecommand("AttemptToFinish")
		end
	end,
	AttemptToFinishCommand=function(self)
		local AnyEntering = false

		if SL.P1.HighScores.EnteringName or SL.P2.HighScores.EnteringName then
			AnyEntering = true
		end

		if not AnyEntering then
			self:playcommand("Finish")
		end
	end,
	MenuTimerExpiredMessageCommand=function(self, param)
		self:playcommand("Finish")
	end,
	FinishCommand=function(self)
		-- manually transition to the next screen (defined in Metrics)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end,
	OffCommand=function(self)
		for pn in ivalues(Players) do
			local playerName = SL[ToEnumShortString(pn)].HighScores.Name

			if playerName then

				-- actually store the HighScoreName
				GAMESTATE:StoreRankingName(pn, playerName)

				-- if the player is using a profile, set a LastUsedHighScoreName for him/her
				if PROFILEMAN:IsPersistentProfile(pn) then
					PROFILEMAN:GetProfile(pn):SetLastUsedHighScoreName(playerName)
				end
			end
		end
	end
}


for pn in ivalues(Players) do
	t[#t+1] = LoadActor("alphabet", pn)
	t[#t+1] = LoadActor("highScores", pn)
end

--
return t