local numPlayers = GAMESTATE:GetNumPlayersEnabled()
local MusicRate = SL.Global.ActiveModifiers.MusicRate

local MasterPlayerNumber = GAMESTATE:GetMasterPlayerNumber()
local MasterPlayerState = GAMESTATE:GetPlayerState(MasterPlayerNumber)
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
	for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
		bpmDisplay = (pn == PLAYER_1) and dispP1 or dispP2
		SongPosition = GAMESTATE:GetPlayerState(pn):GetSongPosition()
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

		if SL.Global.GameMode == "StomperZ" then
			self:zoom(1)
		else
			self:zoom(1.33)
		end
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


if numPlayers == 1 then
	t[#t+1] = SingleBPMDisplay()
end


if numPlayers == 2 then

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
			t[#t+1] = DualBPMDisplay()
		end
	end
end

return t