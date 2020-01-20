local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

local rv
local zoom_factor = WideScale(0.8,0.9)

local labelX_col1 = WideScale(-70,-90)
local dataX_col1  = WideScale(-75,-96)

local labelX_col2 = WideScale(10,20)
local dataX_col2  = WideScale(5,15)

local highscoreX = WideScale(56, 80)
local highscorenameX = WideScale(61, 97)

local PaneItems = {}

local InitializeMeasureCounterAndModsLevel = LoadActor("./MeasureCounterAndModsLevel.lua")

--TODO figure out how to change this if a second player joins
local histogramHeight = 40
if not ThemePrefs.Get("ShowExtraSongInfo") then histogramHeight = 30 end --the grid takes a little more space so shrink the histogram a bit

local InitializeDensity = NPS_Histogram(player, 275, histogramHeight)..{
	OnCommand=function(self)
		self:x(labelX_col1 + 20)
			:y( _screen.h/3.5+6)
	end
}

PaneItems[THEME:GetString("RadarCategory","Taps")] = {
	-- "rc" is RadarCategory
	rc = 'RadarCategory_TapsAndHolds',
	label = {
		x = labelX_col1,
		y = 150,
	},
	data = {
		x = dataX_col1,
		y = 150
	}
}

PaneItems[THEME:GetString("RadarCategory","Mines")] = {
	rc = 'RadarCategory_Mines',
	label = {
		x = labelX_col2,
		y = 150,
	},
	data = {
		x = dataX_col2,
		y = 150
	}
}

PaneItems[THEME:GetString("RadarCategory","Jumps")] = {
	rc = 'RadarCategory_Jumps',
	label = {
		x = labelX_col1,
		y = 168,
	},
	data = {
		x = dataX_col1,
		y = 168
	}
}

PaneItems[THEME:GetString("RadarCategory","Hands")] = {
	rc = 'RadarCategory_Hands',
	label = {
		x = labelX_col2,
		y = 168,
	},
	data = {
		x = dataX_col2,
		y = 168
	}
}

PaneItems[THEME:GetString("RadarCategory","Holds")] = {
	rc = 'RadarCategory_Holds',
	label = {
		x = labelX_col1,
		y = 186,
	},
	data = {
		x = dataX_col1,
		y = 186
	}
}

PaneItems[THEME:GetString("RadarCategory","Rolls")] = {
	rc = 'RadarCategory_Rolls',
	label = {
		x = labelX_col2,
		y = 186,
	},
	data = {
		x = dataX_col2,
		y = 186
	}
}
local FormatDate = function(scoredate)
	if scoredate == "" then
		return ""
	else
		local months = {}
		for i=1,12 do
			table.insert(months, THEME:GetString("Months", "Month"..i))
		end
		local numbers = {}
		for number in string.gmatch(scoredate, "%d+") do
			numbers[#numbers+1] = number
		end
		return numbers[2] .. "-" ..  numbers[3] ..  "-" .. numbers[1]
	end
end

local GetNameAndScoreAndDate = function(profile)
	local song = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
	local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	local score = ""
	local name = ""
	local scoredate = ""
	if profile and song and steps then
		local scorelist = profile:GetHighScoreList(song,steps)
		local scores = scorelist:GetHighScores()
		local topscore = scores[1]

		if topscore then
			score = string.format("%.2f%%", topscore:GetPercentDP()*100.0)
			name = topscore:GetName()
			scoredate = topscore:GetDate()
		else
			score = string.format("%.2f%%", 0)
			name = "????"
			scoredate = ""
		end
	end

	return score, name, scoredate
end

local af = Def.ActorFrame{
	Name="PaneDisplay"..ToEnumShortString(player),
	InitCommand=function(self)
		self:visible(GAMESTATE:IsHumanPlayer(player))
		--TODO for now if there's only one player their pane display is on the left. We only put things on the right if two people are joined
		if GAMESTATE:GetNumSidesJoined() ~= 2 then
			self:x(_screen.w * 0.25 - 5)
		else
			if player == PLAYER_1 then
				self:x(_screen.w * 0.25 - 5)
			elseif player == PLAYER_2 then
				self:x( _screen.w * 0.75 + 5)
			end
		end

		self:y(_screen.cy + 5)
	end,
	--we want to set both players when someone joins because we might need to bring the grid back and hide the stream info
	--TODO change this if we can get both players to see stream info
	PlayerJoinedMessageCommand=function(self, params)
		--if player==params.Player then
		if player == PLAYER_1 then
			self:x(_screen.w * 0.25 - 5)
		elseif player == PLAYER_2 then
			self:x( _screen.w * 0.75 + 5)
		end
		self:visible(true)
			:zoom(0):croptop(0):bounceend(0.3):zoom(1)
			:playcommand("Set")
		self:GetChild("Measures"):settext("")
		self:GetChild("TotalStream"):settext("")
		self:GetChild("PeakNPS"):settext("")
		self:GetChild("AvgNpsLabel"):settext("")
		self:GetChild("AvgNps"):settext("")
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if player==params.Player then
			self:accelerate(0.3):croptop(1):sleep(0.01):zoom(0)
		end
	end,

	-- These playcommand("Set") need to apply to the ENTIRE panedisplay
	-- (all its children) so declare each here
	OnCommand=function(self) self:queuecommand("Set") end,
	CurrentCourseChangedMessageCommand=function(self) self:queuecommand("Set") end,
	StepsHaveChangedMessageCommand=function(self) self:queuecommand("Set") end,
	SetCommand=function(self)
		local machine_score, machine_name, machine_date = GetNameAndScoreAndDate( PROFILEMAN:GetMachineProfile() )
		self:GetChild("MachineHighScore"):settext(machine_score)
		self:GetChild("MachineHighScoreName"):settext(machine_name):diffuse({0,0,0,1})
		self:GetChild("MachineHighScoreDate"):settext(FormatDate(machine_date))
		DiffuseEmojis(self, machine_name)
		local player_score, player_name = "0.00%", "????"
		if PROFILEMAN:IsPersistentProfile(player) and GAMESTATE:GetCurrentSong() then --if there's no song there won't be a hash
			local hash = GetCurrentHash(player)
			if hash and GetScores(player,hash) then
				player_name = PROFILEMAN:GetProfile(player):GetDisplayName():upper()
				player_score = FormatPercentScore(GetScores(player,hash)[1].score)
			else --if we can't generate hashes (malformed SM/DWI/etc) we can't save scores so fallback on profile here
				player_score, player_name = GetNameAndScoreAndDate( PROFILEMAN:GetProfile(player) )
			end
			self:GetChild("PlayerHighScore"):settext(player_score)
			self:GetChild("PlayerHighScoreName"):settext(player_name):diffuse({0,0,0,1})

			DiffuseEmojis(self, player_name)
		end
	end,
	--hide everything when left or right is held down for more than a couple songs
	BeginScrollingMessageCommand=function(self)
		self:linear(.3):diffusealpha(0)
	end,
	-- This is set separately because it lags SM if players hold down left or right (to scroll quickly). LessLag will trigger after .15 seconds
	-- with no new song changes.
	LessLagMessageCommand=function(self)
			-- ---------------------Extra Song Information------------------------------------------
		--TODO right now we don't show any of this if two players are joined. I'd like to find a way for both to see it
		self:linear(.3):diffusealpha(1)
		local song = GAMESTATE:GetCurrentSong()
		if not GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentSteps(player) and song and ThemePrefs.Get("ShowExtraSongInfo") and GAMESTATE:GetNumSidesJoined() < 2 then
			InitializeMeasureCounterAndModsLevel(player)
			if SL[pn].Streams.Measures then --used to be working without this... not sure what changed but don't run any of this stuff if measures is not filled in
				local lastSequence = #SL[pn].Streams.Measures
				local streamsTable = SL[pn].Streams
				local measureType = SL[pn].ActiveModifiers.MeasureCounter
				local totalStreams = 0
				local previousSequence = 0
				local streamAmount = 0
				local breakdown = "" --breakdown tries to display the full streams including rest measures
				local breakdown2 = "" --breakdown2 tries to display the streams without rest measures
				local breakdown3 = "" --breakdown3 combines streams that would normally be separated with a -
				for i, sequence in ipairs(streamsTable.Measures) do
					if not sequence.isBreak then
						totalStreams = totalStreams + sequence.streamEnd - sequence.streamStart
						breakdown = breakdown..sequence.streamEnd - sequence.streamStart.." "
						if previousSequence < 2 then
							breakdown2 = breakdown2.."-"..sequence.streamEnd - sequence.streamStart
						elseif previousSequence >= 2 then
							breakdown2 = breakdown2.."/"..sequence.streamEnd - sequence.streamStart
							previousSequence = 0
						end
						streamAmount = streamAmount + 1
					else
						breakdown = breakdown.."("..sequence.streamEnd - sequence.streamStart..") "
						previousSequence = previousSequence + sequence.streamEnd - sequence.streamStart
					end
				end	
				if totalStreams == 0 then
					self:GetChild("Measures"):settext(THEME:GetString("ScreenSelectMusicExperiment", "NoStream"))
					self:GetChild("TotalStream"):settext("")
				else
					for stream in ivalues(Split(breakdown2,"/")) do
						local combine = 0
						local multiple = false
						for part in ivalues(Split(stream,"-")) do
							if combine ~= 0 then multiple = true end
							combine = combine + tonumber(part)
						end
						breakdown3 = breakdown3.."/"..combine..(multiple and "*" or "")
					end
					local percent = totalStreams / streamsTable.Measures[lastSequence].streamEnd
					percent = math.floor(percent*100)
					local toWrite = THEME:GetString("ScreenSelectMusicExperiment", "Total").." :"
					toWrite = toWrite..totalStreams.." ("..percent.."%) (>="..measureType
					toWrite = toWrite.." "..THEME:GetString("ScreenSelectMusicExperiment", "NoteStream")..")"
					self:GetChild("Measures"):settext(toWrite)
					if streamAmount > 15 then self:GetChild("TotalStream"):settext(string.sub(breakdown3,2))
					else self:GetChild("TotalStream"):settext(string.sub(breakdown2,2)) end
				end
				local duration = song:MusicLengthSeconds() / SL.Global.ActiveModifiers.MusicRate
				local totalSteps = GAMESTATE:GetCurrentSteps(player):GetRadarValues(player):GetValue('RadarCategory_TapsAndHolds')
				local finalText = totalSteps / duration
				finalText = math.floor(finalText*100)/100 --truncate to two decimals
				self:GetChild("AvgNps"):settext(finalText)
				self:GetChild("AvgNpsLabel"):settext(THEME:GetString("ScreenSelectMusicExperiment", "AvgNps"))
			else
				self:GetChild("Measures"):settext(THEME:GetString("ScreenSelectMusicExperiment", "StreamCounterOff"))
				self:GetChild("TotalStream"):settext("")
				self:GetChild("PeakNPS"):settext("")
				self:GetChild("AvgNpsLabel"):settext("")
				self:GetChild("AvgNps"):settext("")
			end
		else
			self:GetChild("Measures"):settext("")
			self:GetChild("TotalStream"):settext("")
			self:GetChild("PeakNPS"):settext("")
			self:GetChild("AvgNpsLabel"):settext("")
			self:GetChild("AvgNps"):settext("")
		end
	end,
	--TODO part of the pane that gets hidden if two players are joined. i'd like to display this somewhere though
	PeakNPSUpdatedMessageCommand=function(self, params)
		if GAMESTATE:GetCurrentSong() and SL[pn].NoteDensity.Peak and ThemePrefs.Get("ShowExtraSongInfo") and GAMESTATE:GetNumSidesJoined() < 2 then
			self:GetChild("PeakNPS"):settext( THEME:GetString("ScreenGameplay", "PeakNPS") .. ": " .. round(SL[pn].NoteDensity.Peak * SL.Global.ActiveModifiers.MusicRate,2))
		else
			self:GetChild("PeakNPS"):settext( "" )
		end
	end,
}

-- colored background for chart statistics
af[#af+1] = Def.Quad{
	Name="BackgroundQuad",
	InitCommand=cmd(zoomto, _screen.w/2-10, _screen.h/8; y, _screen.h/2 - 67 ),
	SetCommand=function(self, params)
		if GAMESTATE:IsHumanPlayer(player) then
			local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

			if StepsOrTrail then
				local difficulty = StepsOrTrail:GetDifficulty()
				self:diffuse( DifficultyColor(difficulty) )
			else
				self:diffuse( PlayerColor(player) )
			end
		end
	end
}

for key, item in pairs(PaneItems) do

	af[#af+1] = Def.ActorFrame{

		Name=key,
		OnCommand=cmd(x, -_screen.w/20; y,6 ),

		-- label
		LoadFont("Common Normal")..{
			Text=key,
			InitCommand=cmd(zoom, zoom_factor; xy, item.label.x, item.label.y; diffuse, Color.Black; halign, 0)
		},
		--  numerical value
		LoadFont("Common Normal")..{
			InitCommand=cmd(zoom, zoom_factor; xy, item.data.x, item.data.y; diffuse, Color.Black; halign, 1),
			OnCommand=cmd(playcommand, "Set"),
			SetCommand=function(self)
				local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
				if not SongOrCourse then self:settext("?"); return end

				local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
				if steps then
					rv = steps:GetRadarValues(player)
					local val = rv:GetValue( item.rc )

					-- the engine will return -1 as the value for autogenerated content; show a question mark instead if so
					self:settext( val >= 0 and val or "?" )
				else
					self:settext( "" )
				end
			end
		}
	}
end

-- chart difficulty meter
af[#af+1] = LoadFont("_wendy small")..{
	Name="DifficultyMeter",
	InitCommand=cmd(horizalign, right; diffuse, Color.Black; xy, _screen.w/4 - 10, _screen.h/2 - 65; queuecommand, "Set"),
	SetCommand=function(self)
		local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
		if not SongOrCourse then self:settext(""); return end

		local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)
		local meter = StepsOrTrail and StepsOrTrail:GetMeter() or "?"
		self:settext( meter )
	end
}

--PLAYER PROFILE high score
af[#af+1] = LoadFont("Common Normal")..{
	Name="PlayerHighScore",
	InitCommand=cmd(x, highscoreX; y, 176; zoom, zoom_factor; diffuse, Color.Black; halign, 1 )

} 
--PLAYER PROFILE highscore name
af[#af+1] = LoadFont("Common Normal")..{
	Name="PlayerHighScoreName",
					
	InitCommand=cmd(x, highscorenameX; y, 176; zoom, zoom_factor; diffuse, Color.Black; halign, 0; maxwidth, 80)
}
--MACHINE high score
af[#af+1] = LoadFont("Common Normal")..{
	Name="MachineHighScore",
	InitCommand=cmd(x, highscoreX; y, 156; zoom, zoom_factor; diffuse, Color.Black; halign, 1 )
}

--MACHINE highscore name
af[#af+1] = LoadFont("Common Normal")..{
	Name="MachineHighScoreName",
	InitCommand=cmd(x, highscorenameX; y, 156; zoom, zoom_factor; diffuse, Color.Black; halign, 0; maxwidth, 80)
}

--MACHINE highscore date
af[#af+1] = LoadFont("Common Normal")..{
	Name="MachineHighScoreDate",
	InitCommand=cmd(x, highscoreX; y, 193; zoom, zoom_factor; diffuse, Color.Black; halign, .5)
}

--PeakNPS
af[#af+1] = LoadFont("Common Normal")..{
	Name="PeakNPS",
	InitCommand=cmd(xy, _screen.w/2 - 500, _screen.h/8 - 30; zoom, zoom_factor; diffuse, Color.White; halign, 0),
}

--AVG NPS label
af[#af+1] = LoadFont("Common Normal")..{
	Name="AvgNpsLabel",
	InitCommand=cmd(x, highscorenameX; y,  _screen.h/8 - 30; zoom, zoom_factor; diffuse, Color.White; halign, 0)
}

--AVG NPS
af[#af+1] = LoadFont("Common Normal")..{
	Name="AvgNps",
	InitCommand=cmd(x, highscoreX; y, _screen.h/8 - 30; zoom, zoom_factor; diffuse, Color.White; halign, 1)
}

--Total Stream
af[#af+1] = LoadFont("Common Normal")..{
	Name="TotalStream",
	InitCommand=cmd(xy, _screen.w/2 - 500, _screen.h/8 + 10; zoom, zoom_factor; diffuse, Color.White; halign, 0)
}

--Measures
af[#af+1] = LoadFont("Common Normal")..{
	Name="Measures",
	InitCommand=cmd(xy, _screen.w/2 - 500, _screen.h/8 - 10; zoom, zoom_factor; diffuse, Color.White; halign, 0; maxwidth, 315)
}

if not GAMESTATE:IsCourseMode() then af[#af+1] =  InitializeDensity end

return af