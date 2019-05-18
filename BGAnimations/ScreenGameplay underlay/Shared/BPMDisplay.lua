local Players = GAMESTATE:GetHumanPlayers()
local MusicRate = SL.Global.ActiveModifiers.MusicRate

local MasterPlayerState = GAMESTATE:GetPlayerState(GAMESTATE:GetMasterPlayerNumber())
local so = GAMESTATE:GetSongOptionsObject("ModsLevel_Song")

local bpmDisplay, SongPosition
local StepsP1, StepsP2


-- the update function when a single BPM Display is in use
local UpdateSingleBPM = function(af)
	-- BPM stuff first
	SongPosition = MasterPlayerState:GetSongPosition()

	-- then, MusicRate stuff
	MusicRate = so:MusicRate()

	-- BPM Display
	bpmDisplay:settext( round(SongPosition:GetCurBPS() * 60 * MusicRate) )

	-- MusicRate Display
	MusicRate = string.format("%.2f", MusicRate )
	MusicRateDisplay:settext( MusicRate ~= "1.00" and MusicRate.."x rate" or "" )
end

-- the update function when two BPM Displays are needed for divergent TimingData (split BPMs)
local Update2PBPM = function(self)
	MusicRate = so:MusicRate()

	-- need current bpm for p1 and p2
	for player in ivalues(Players) do
		bpmDisplay = (player == PLAYER_1) and dispP1 or dispP2
		SongPosition = GAMESTATE:GetPlayerState(player):GetSongPosition()
		bpmDisplay:settext( round( SongPosition:GetCurBPS() * 60 * MusicRate ) )
	end

	MusicRate = string.format("%.2f", MusicRate )
	MusicRateDisplay:settext( MusicRate ~= "1.00" and MusicRate.."x rate" or "" )
end



local SingleBPMDisplay = function()
	return Def.ActorFrame{
		InitCommand=cmd(SetUpdateFunction,UpdateSingleBPM),

		LoadFont("_miso")..{
			Name="BPMDisplay",
			InitCommand=function(self)
				self:zoom(1)
				bpmDisplay = self
			end
		}
	}
end

local DualBPMDisplay = function()
	return Def.ActorFrame{
		InitCommand=function(self) self:SetUpdateFunction(Update2PBPM) end,

		-- manual bpm displays
		LoadFont("_miso")..{
			Name="DisplayP1",
			InitCommand=function(self)
				self:x(-18):zoom(1):shadowlength(1)
				dispP1 = self
			end
		},
		LoadFont("_miso")..{
			Name="DisplayP2",
			InitCommand=function(self)
				self:x(18):zoom(1):shadowlength(1)
				dispP2 = self
			end
		}
	}
end

-- -------------------------------------

local t = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(_screen.cx, 52):valign(1)

		if PREFSMAN:GetPreference("Center1Player") and #GAMESTATE:GetHumanPlayers() == 1 then
			local mpn = GAMESTATE:GetMasterPlayerNumber()
			if SL[ToEnumShortString(mpn)].ActiveModifiers.NPSGraphAtTop then
				self:x(_screen.cx + GetNotefieldWidth(mpn) * (mpn==PLAYER_1 and 1 or -1))
			end
		end

		self:zoom(SL.Global.GameMode == "StomperZ" and 1 or 1.33)
	end,

	LoadFont("_miso")..{
		Name="RatemodDisplay",
		Text=MusicRate ~= 1 and MusicRate.."x rate" or "",
		InitCommand=function(self)
			self:zoom(0.5):y(12)
			MusicRateDisplay = self
		end
	}
}

if SL.Global.GameMode == "StomperZ" then
	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:diffuse(0,0,0,0.85):zoomto(66,40):valign(0):xy( 0, -20 )
		end
	}
end


if #Players == 1 then
	t[#t+1] = SingleBPMDisplay()
end


if #Players == 2 then

	if not GAMESTATE:IsCourseMode() then
		-- check if both players are playing the same steps
		StepsP1 = GAMESTATE:GetCurrentSteps(PLAYER_1)
		StepsP2 = GAMESTATE:GetCurrentSteps(PLAYER_2)

		-- get timing data...
		local TimingDataP1 = StepsP1:GetTimingData()
		local TimingDataP2 = StepsP2:GetTimingData()

		local dispP1, dispP2

		if TimingDataP1 == TimingDataP2 then
			-- both players have the same TimingData; only need one BPM Display.
			t[#t+1] = SingleBPMDisplay()
		else
			t[#t+1] = DualBPMDisplay()
		end

	-- if we ARE in CourseMode
	else
		local TrailP1 = GAMESTATE:GetCurrentTrail(PLAYER_1)
		local TrailP2 = GAMESTATE:GetCurrentTrail(PLAYER_2)

		if TrailP1 == TrailP2 then
			-- both players have the same trail; only need one BPM Display.
			t[#t+1] = SingleBPMDisplay()
		else
			-- Two different Trails may effectively share the the same TimingData for each of their TrailEntries,
			-- but this is not guaranteed.  A single song within the course may feature split BPMs, for example.
			-- So, loop through the TrailEntries of both and compare the TimingData of each.
			-- If there is even one discrepancy, break from the loop and use a DualBPMDisplay.
			local TrailEntriesP1 = TrailP1:GetTrailEntries()
			local TrailEntriesP2 = TrailP2:GetTrailEntries()
			local DivergentTimingData = false

			for i=1, #TrailEntriesP1 do
				if TrailEntriesP1[i]:GetSteps():GetTimingData() ~= TrailEntriesP2[i]:GetSteps():GetTimingData() then
					DivergentTimingData = true
					break
				end
			end

			t[#t+1] = DivergentTimingData and DualBPMDisplay() or SingleBPMDisplay()
		end
	end
end

return t