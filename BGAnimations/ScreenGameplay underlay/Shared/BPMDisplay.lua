local numPlayers = GAMESTATE:GetNumPlayersEnabled()
local numSides = GAMESTATE:GetNumSidesJoined()
local bDoubles = (numPlayers == 1 and numSides == 2)
local bUsingCenter1P = PREFSMAN:GetPreference('Center1Player')
local MusicRate = SL.Global.ActiveModifiers.MusicRate


local function UpdateSingleBPM(self)

	-- BPM stuff first
	local bpmDisplay = self:GetChild("BPMDisplay")
	local pn = GAMESTATE:GetMasterPlayerNumber()
	local pState = GAMESTATE:GetPlayerState(pn)
	local songPosition = pState:GetSongPosition()

	-- then, MusicRate stuff
	local MusicRateDisplay = self:GetParent():GetChild("RatemodDisplay")
	local so = GAMESTATE:GetSongOptionsObject("ModsLevel_Song")
	local MusicRate = so:MusicRate()

	-- BPM Display
	local bpm = songPosition:GetCurBPS() * 60 * MusicRate
	bpmDisplay:settext( round(bpm) )

	-- MusicRate Display
	MusicRate = string.format("%.2f", MusicRate )
	MusicRateDisplay:settext( MusicRate ~= "1.00" and MusicRate.."x rate" or "" )
end

local t = Def.ActorFrame{
	InitCommand=cmd(xy,_screen.cx, 52; valign,1; zoom,1.33),

	LoadFont("_miso")..{
		Name="RatemodDisplay",
		Text=MusicRate ~= 1 and MusicRate.."x rate" or "",
		InitCommand=cmd(zoom,0.5; y, 12)
	}
}

local displaySingle = Def.ActorFrame{
	LoadFont("_miso")..{
		Name="BPMDisplay",
		InitCommand=cmd(zoom,1)
	}
}

displaySingle.InitCommand=cmd(SetUpdateFunction,UpdateSingleBPM)

-- in CourseMode, both players should always be playing the same charts, right?
if numPlayers == 1 or GAMESTATE:IsCourseMode() then
	t[#t+1] = displaySingle
else
	-- check if both players are playing the same steps
	local stepsP1 = GAMESTATE:GetCurrentSteps(PLAYER_1)
	local stepsP2 = GAMESTATE:GetCurrentSteps(PLAYER_2)

	local stP1 = stepsP1:GetStepsType()
	local stP2 = stepsP2:GetStepsType()

	local diffP1 = stepsP1:GetDifficulty()
	local diffP2 = stepsP2:GetDifficulty()

	-- get timing data...
	local timingP1 = stepsP1:GetTimingData()
	local timingP2 = stepsP2:GetTimingData()

	if timingP1 == timingP2 then
		-- both players are steps with the same TimingData; only need one.
		t[#t+1] = displaySingle
		return t
	end

	-- otherwise, we have some more work to do.

	local function Update2PBPM(self)
		local dispP1 = self:GetChild("DisplayP1")
		local dispP2 = self:GetChild("DisplayP2")

		local MusicRateDisplay = self:GetParent():GetChild("RatemodDisplay")
		local so = GAMESTATE:GetSongOptionsObject("ModsLevel_Song")
		local MusicRate = so:MusicRate()

		-- needs current bpm for p1 and p2
		for pn in ivalues(PlayerNumber) do
			local bpmDisplay = (pn == PLAYER_1) and dispP1 or dispP2
			local pState = GAMESTATE:GetPlayerState(pn)
			local songPosition = pState:GetSongPosition()
			local bpm = songPosition:GetCurBPS() * 60 * MusicRate
			bpmDisplay:settext( round(bpm) )
		end

		MusicRate = string.format("%.2f", MusicRate )
		MusicRateDisplay:settext( MusicRate ~= "1.00" and MusicRate.."x rate" or "" )
	end

	local displayTwoPlayers = Def.ActorFrame{
		-- manual bpm displays
		LoadFont("_miso")..{
			Name="DisplayP1",
			InitCommand=cmd(x,-32; zoom,1; shadowlength,1)
		},
		LoadFont("_miso")..{
			Name="DisplayP2",
			InitCommand=cmd(x,32; zoom,1; shadowlength,1)
		}
	}

	displayTwoPlayers.InitCommand=cmd(SetUpdateFunction,Update2PBPM)

	t[#t+1] = displayTwoPlayers
end

return t