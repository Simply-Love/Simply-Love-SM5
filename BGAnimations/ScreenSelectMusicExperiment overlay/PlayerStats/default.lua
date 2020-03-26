local playerStats_input
local player = GAMESTATE:GetMasterPlayerNumber()

local totalTime = 0
local songsPlayedThisGame = 0
local notesHitThisGame = 0

function ConvertSecondsToTimeString(totalTime)
	local hours = math.floor(totalTime/3600)
	local minutes = math.floor((totalTime-(hours*3600))/60)
	local seconds = round(totalTime%60)
	local gametime =  minutes .. THEME:GetString("ScreenGameOver", "Minutes") .. " " .. seconds .. THEME:GetString("ScreenGameOver", "Seconds")
	
	if hours > 0 then
		gametime = hours .. ScreenString("Hours") .. " " ..
		minutes .. ScreenString("Minutes")
	end
	
	return gametime
end

-- Use pairs here (instead of ipairs) because this player might have late-joined
-- which will result in nil entries in the the Stats table, which halts ipairs.
-- We're just summing total time anyway, so order doesn't matter.
for _,stats in pairs( SL[ToEnumShortString(player)].Stages.Stats ) do
	totalTime = totalTime + (stats and stats.duration or 0)
	songsPlayedThisGame = songsPlayedThisGame + (stats and 1 or 0)
	if stats and stats.column_judgments then
		-- increment notesHitThisGame by the total number of tapnotes hit in this particular stepchart by using the per-column data
		-- don't rely on the engine's non-Miss judgment counts here for two reasons:
		-- 1. we want jumps/hands to count as more than 1 here
		-- 2. stepcharts can have non-1 #COMBOS parameters set which would artbitraily inflate notesHitThisGame

		for _, judgments in ipairs(stats.column_judgments) do
			for judgment, judgment_count in pairs(judgments) do
				if judgment ~= "Miss" then
					notesHitThisGame = notesHitThisGame + judgment_count
				end
			end
		end
	end
end

local playerStats = ParseStats(GAMESTATE:GetMasterPlayerNumber())

local sessionGameTime = ConvertSecondsToTimeString(totalTime)

local af =  Def.ActorFrame{
	InitCommand=function(self)
		self:visible(false):xy(200,200)
		playerStats_input = LoadActor("./PlayerStats_InputHandler.lua", {af=self})
	end,
	DirectInputToPlayerStatsCommand=function(self) self:queuecommand("Stall") end,
	StallCommand=function(self)
		self:visible(true):sleep(0.25):queuecommand("CaptureTest")
		MESSAGEMAN:Broadcast("SetOptionPanes")
		self:queuecommand("SetPlayerStats")
	end,
	CaptureTestCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( playerStats_input ) end,

    -- the OffCommand will have been queued, when it is appropriate, from ./Input.lua
	-- sleep for 0.5 seconds to give the PlayerFrames time to tween out
	-- and queue a call to Finish() so that the engine can wrap things up
	OffCommand=function(self)			
		self:sleep(0.5):queuecommand("Finish")
	end,
	FinishCommand=function(self)
		self:visible(false)
		local screen   = SCREENMAN:GetTopScreen()
		local overlay  = screen:GetChild("Overlay")
		screen:RemoveInputCallback( playerStats_input)
		overlay:queuecommand("DirectInputToEngine")
	end,
	Def.ActorFrame{
		InitCommand=function(self)
			self:y(40)
		end,
		Def.Quad {
			Name = "Border",
			InitCommand = function(self)
				self:zoomto(305,455):diffuse(Color.White)
			end,
		},
		Def.Quad {
			Name = "StatsBox",
			InitCommand = function(self)
				self:zoomto(300,450):diffuse(Color.Black)
			end,
		},
		CreateLineGraph(200,150)..{OnCommand=function(self) self:xy(-20,130) end},
		LoadFont("_wendy small") ..
		{
			Text = "Session",
			InitCommand = function(self)
				self:zoom(1):diffuse(Color.White):zoom(.7):y(-180):halign(.5)
			end
		},
		LoadFont("Common Normal") ..
		{
			Name = "Player",
			InitCommand = function(self)
				self:zoom(1):diffuse(Color.White):zoom(.75):xy(-120,-140):halign(0)
				if PROFILEMAN:GetPlayerName(player) == "" then self:settext("Player: Guest")
				else self:settext("Player: "..PROFILEMAN:GetPlayerName(player)) end
			end,
		},
		LoadFont("Common Normal") ..
		{
			Text = "Gametime:",
			InitCommand = function(self)
				self:zoom(1):diffuse(Color.White):zoom(.75):xy(-120,-110):halign(0)
				self:settext(THEME:GetString("ScreenSelectMusicExperiment", "Gametime").." "..sessionGameTime)
			end
		},
		LoadFont("Common Normal") ..
		{
			Name = "Notes Hit",
			InitCommand = function(self)
				self:zoom(1):diffuse(Color.White):zoom(.75):xy(-120,-80):halign(0)
				self:settext("Notes Hit: "..commify(notesHitThisGame))
			end
		},
		LoadFont("Common Normal") ..
		{
			Name = "Songs Played",
			InitCommand = function(self)
				self:zoom(1):diffuse(Color.White):zoom(.75):xy(-120,-50):halign(0)
				self:settext("Songs Played: "..songsPlayedThisGame)
			end
		},
		LoadFont("Common Normal") ..
		{
			Name = "Graph",
			InitCommand = function(self)
				self:zoom(1):diffuse(Color.White):zoom(.75):xy(-120,20):halign(0)
				if songsPlayedThisGame > 0 then self:settext("Score/Difficulty Graph:")
				else self:settext("Score/Difficulty Graph:\n\nNO SONGS PLAYED YET") end
			end
		},
	}
}

if playerStats then
	local allGameTime = ConvertSecondsToTimeString(playerStats.TotalGameplaySeconds)

	local allTime = Def.ActorFrame{
		InitCommand = function(self)
			self:xy(400,40)
		end,
		Def.Quad {
			Name = "Border",
			InitCommand = function(self)
				self:zoomto(305,455):diffuse(Color.White)
			end,
		},
		Def.Quad {
			Name = "StatsBox",
			InitCommand = function(self)
				self:zoomto(300,450):diffuse(Color.Black)
			end,
		},
		LoadFont("_wendy small") ..
		{
			Text = "All Time",
			InitCommand = function(self)
				self:zoom(1):diffuse(Color.White):zoom(.7):y(-180):halign(.5)
			end
		},
		LoadFont("Common Normal") ..
		{
			Name = "Player",
			InitCommand = function(self)
				self:zoom(1):diffuse(Color.White):zoom(.75):xy(-120,-140):halign(0)
				if PROFILEMAN:GetPlayerName(player) == "" then self:settext("Player: Guest")
				else self:settext("Player: "..PROFILEMAN:GetPlayerName(player)) end
			end,
		},
		LoadFont("Common Normal") ..
		{
			Text = "Gametime:",
			InitCommand = function(self)
				self:zoom(1):diffuse(Color.White):zoom(.75):xy(-120,-110):halign(0)
				self:settext(THEME:GetString("ScreenSelectMusicExperiment", "Gametime").." "..allGameTime)
			end
		},
		LoadFont("Common Normal") ..
		{
			Name = "Notes Hit",
			InitCommand = function(self)
				self:zoom(1):diffuse(Color.White):zoom(.75):xy(-120,-80):halign(0)
				self:settext("Notes Hit: "..commify(playerStats.TotalTapsAndHolds))
			end
		},
		LoadFont("Common Normal") ..
		{
			Name = "Songs Played",
			InitCommand = function(self)
				self:zoom(1):diffuse(Color.White):zoom(.75):xy(-120,-50):halign(0)
				self:settext("Songs Played: "..commify(playerStats.NumTotalSongsPlayed ))
			end
		},
		LoadFont("Common Normal") ..
		{
			Name = "First Passes",
			InitCommand = function(self)
				self:zoom(1):diffuse(Color.White):zoom(.75):xy(-120,-20):halign(0)
				self:settext("First Passed:")
			end
		},
	}

	--Get first passes
	local firstPasses = {}
	local songs = SONGMAN:GetAllSongs()
	local maxDiff = 0
	if ThemePrefs.Get("UseCustomScores") then
		for song in ivalues(songs) do
			if song:HasStepsType(GetStepsType()) then
				for steps in ivalues(song:GetStepsByStepsType(GetStepsType())) do
					local hash = GetHash(player,song,steps)
					if hash then
						local customScore = GetChartStats(player,hash)
						if customScore and customScore.FirstPass ~= "Never" and customScore.FirstPass ~= "Unknown" then
							if not firstPasses[steps:GetMeter()] then
								if steps:GetMeter() > maxDiff then maxDiff = steps:GetMeter() end
								firstPasses[steps:GetMeter()] = {date = customScore.FirstPass, song = song:GetMainTitle()}
							else
								if DateToMinutes(firstPasses[steps:GetMeter()].date) > DateToMinutes(customScore.FirstPass) then
									firstPasses[steps:GetMeter()] = {date = customScore.FirstPass, song = song:GetMainTitle()}
								end
							end
						end
					end
				end
			end
		end
		local sortedFirstPasses = {}
		for i = 1,maxDiff do
			if firstPasses[i] then
				local pass = firstPasses[i]
				table.insert(sortedFirstPasses,{level = i, date = pass.date, song = pass.song})
			end
		end

		local begin = #sortedFirstPasses > 10 and #sortedFirstPasses - 10 or 1
		for i = begin,#sortedFirstPasses do
			local row = (i - begin)*20
			allTime[#allTime+1] =
			LoadFont("Common Normal") ..
			{
				InitCommand = function(self)
					self:zoom(1):diffuse(Color.White):zoom(.75):xy(-120,10+row):halign(0)
					local toWrite = sortedFirstPasses[i].level..": "
					toWrite = toWrite..FormatDate(Split(sortedFirstPasses[i].date)[1])
					toWrite = toWrite.." ("..sortedFirstPasses[i].song..")"
					self:settext(toWrite)
				end
			}
		end
	end
	af[#af+1] = allTime
end

return af