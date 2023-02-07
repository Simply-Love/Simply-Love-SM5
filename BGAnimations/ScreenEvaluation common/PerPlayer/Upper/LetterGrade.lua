local player = ...

local playerStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local grade = playerStats:GetGrade()
local hasStream = false

-- "I passd with a q though."
local title = GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
if title == "D" then grade = "Grade_Tier99" end

if not GAMESTATE:IsCourseMode() then
	streamMeasures, breakMeasures = GetTotalStreamAndBreakMeasures(ToEnumShortString(player))
	totalMeasures = streamMeasures + breakMeasures
	
	if streamMeasures/totalMeasures >= 0.2 then hasStream = true end
end

local t = Def.ActorFrame{}

t[#t+1] = LoadActor(THEME:GetPathG("", "_grades/"..grade..".lua"), playerStats)..{
	InitCommand=function(self)
		self:x(70 * (player==PLAYER_1 and -1 or 1))
		self:y(_screen.cy-144)
	end,
	OnCommand=function(self)
		self:zoom(0.3)
		
		if not hasStream then
			self:zoom(0.4)
			self:y(_screen.cy-136)
		end
	end
}

return t