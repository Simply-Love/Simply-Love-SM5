local player = ...

local mods = SL[ToEnumShortString(player)].ActiveModifiers

local cue_time = nil
if mods.ColumnCues ~= nil then
	cue_time = tonumber(mods.ColumnCues:sub(1, #mods.ColumnCues-1))
end

if cue_time == nil then
	return Def.ActorFrame {}
end

local pn = ToEnumShortString(player)
local steps = GAMESTATE:GetCurrentSteps(player)

local noteTimes = GetChartNoteTimes(steps, pn)
-- Find gaps of at least cue_time

if noteTimes == nil then
	return Def.ActorFrame {}
end

local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
local columnTimes = {}
for i=1,NumColumns do
	columnTimes[i] = {}
end

local prevTime = 0
local cueStartTime = -1
local cueEndTime = -1
local holdCount = 0
for _, noteTime in ipairs(noteTimes) do
	if noteTime.type:match('[1234]') then
		if noteTime.time - prevTime >= cue_time then
			cueStartTime = prevTime
			cueEndTime = noteTime.time
		end

		if noteTime.time == cueEndTime and holdCount == 0 then
			if noteTime.type == '1' or noteTime.type == '2' or noteTime.type == '4' then
				local times = columnTimes[noteTime.column]
				times[#times+1] = {
					start=cueStartTime,
					duration=cueEndTime-cueStartTime,
				}
			end
		end

		if noteTime.type == '2' or noteTime.type == '4' then
			holdCount = holdCount + 1
		end

		if noteTime.type == '3' then
			holdCount = holdCount - 1
		end

		prevTime = noteTime.time
	end
end

SM(holdCount)

local style = GAMESTATE:GetCurrentStyle(player)
local width = style:GetWidth(player)

local y_offset = 80
local fade_time = 0.15

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:xy( GetNotefieldX(player), y_offset)
		-- See ColumnFlashOnMiss for what the fuck this is.
		local zoom_factor = 1 - scale( mods.Mini:gsub("%%","")/100, 0, 2, 0, 1)
		self:zoomx( zoom_factor )
	end,
	OnCommand=function(self)
		
	end,
}

for ColumnIndex=1,NumColumns do
	local timeIndex = 1
	local quad = nil
	af[#af+1] = Def.ActorFrame {
		InitCommand=function(self)
			self:queuecommand('Run')
		end,
		RunCommand=function(self)
			local now = GAMESTATE:GetCurMusicSeconds() / SL.Global.ActiveModifiers.MusicRate
			local flashDuration = nil
			while true do
				local nextTime = columnTimes[ColumnIndex][timeIndex]
				if nextTime == nil then break end
				local waitTime = nextTime.start - now
				if waitTime >= 0.017 then
					self:sleep(waitTime)
					self:queuecommand('Run')
					break
				end
				timeIndex = timeIndex + 1
				flashDuration = nextTime.duration
			end

			if flashDuration ~= nil then
				quad:stoptweening()
					:decelerate(fade_time)
					:diffuse(0.3,1,1,0.12)
					:sleep(flashDuration - 2*fade_time)
					:accelerate(fade_time)
					:diffuse(0,0,0,0)
			end
		end,
		Def.Quad {
			InitCommand=function(self)
				self:diffuse(0,0,0,0)
					:x((ColumnIndex - (NumColumns/2 + 0.5)) * (width/NumColumns))
					:vertalign(top)
					:setsize(width/NumColumns, _screen.h - y_offset)
					:fadebottom(0.333)
				quad = self
			end,
		}
	}
end

return af
