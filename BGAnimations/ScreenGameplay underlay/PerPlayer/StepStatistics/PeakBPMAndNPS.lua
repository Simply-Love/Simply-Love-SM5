local player = ...
local pn = ToEnumShortString(player)

local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)
local IsUltraWide = (GetScreenAspectRatio() > 21/9)


-- Peak BPM and Peak NPS values
local values = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:horizalign(left)
		self:vertalign(bottom)
		self:vertspacing(-3)
	end,
	PeakNPSUpdatedMessageCommand=function(self)
		-- don't use the GetDisplayBPMs(player) helper function here because in CourseMode
		-- that would give us the min/max BPM for the overall Course; in this case
		-- we want the peak bpm value to update with each new TrailEntry in the Course
		local steps
		if GAMESTATE:IsCourseMode() then
			local trail_entry = GAMESTATE:GetCurrentTrail(player):GetTrailEntry(GAMESTATE:GetCourseSongIndex())
			if trail_entry then steps = trail_entry:GetSteps() end
		else
			steps = GAMESTATE:GetCurrentSteps(player)
		end

		local bpms =  steps:GetTimingData():GetActualBPM()
		local peak_bpm = type(bpms)=="table" and tostring(round(bpms[2] * SL.Global.ActiveModifiers.MusicRate,2)) or ""

		local peak_nps = GAMESTATE:Env()[pn.."PeakNPS"]
		if peak_nps then
			peak_nps = tostring(round(peak_nps * SL.Global.ActiveModifiers.MusicRate,2))
		else
			peak_nps = ""
		end

		self:settext( ("%s\n%s"):format(peak_bpm, peak_nps) )
	end,
}

-- Peak BPM and Peak NPS labels
local labels = LoadFont("Common Normal")..{
	Text=("%s    \n%s    "):format(THEME:GetString("ScreenGameplay", "PeakBPM"), THEME:GetString("ScreenGameplay", "PeakNPS")),
	InitCommand=function(self)
		self:zoom(0.833)
		self:vertspacing(1)
		self:horizalign(right)
		self:vertalign(bottom)
	end
}

local af = Def.ActorFrame{}
af.InitCommand=function(self)
	self:x( player==PLAYER_1 and 58 or -82 )

	-- adjust for smaller panes when notefield is centered
	if NoteFieldIsCentered and IsUsingWideScreen() then
		self:x( player==PLAYER_1 and 58 or -86 )

	-- adjust for smaller panes when ultrawide and both players joined
	elseif IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
		self:x( player==PLAYER_1 and -83 or 54 )
	end

	self:y( 50 )
end

af[#af+1] = values
af[#af+1] = labels

return af