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

local columnTimes = GetChartColumnTimes(steps, pn)


local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
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
			local now = GAMESTATE:GetCurMusicSeconds()
			local flash = false
			while true do
				local nextTime = columnTimes[ColumnIndex][timeIndex]
				if nextTime == nil then break end
				local waitTime = nextTime - now - cue_time
				if waitTime >= 0.017 then
					self:sleep(waitTime)
					self:queuecommand('Run')
					break
				end
				timeIndex = timeIndex + 1
				flash = true
			end

			if flash then
				quad:stoptweening()
					:decelerate(fade_time)
					:diffuse(0.3,1,1,0.12)
					:sleep(cue_time - fade_time)
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
