local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

if not mods.ColumnCues then return end

local playerState = GAMESTATE:GetPlayerState(player)
local columnCues = SL[pn].Streams.ColumnCues

local numColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
local style = GAMESTATE:GetCurrentStyle(player)
local width = style:GetWidth(player)

local yOffset = 80
local fadeTime = 0.15
local curIndex = 1

local Update = function(self, delta)
	if curIndex <= #columnCues then
		local curTime = playerState:GetSongPosition():GetMusicSecondsVisible()
		local columnCue = columnCues[curIndex]
		if columnCue.startTime <= curTime then
			-- Get the current music rate.
			-- Note that Lua files might change the rate mode so this might not be accurate.
			-- It's hard to handle that case since we don't exactly know when a file will apply a rate mod.
			local rate = SL.Global.ActiveModifiers.MusicRate
			local scaledDuration = columnCue.duration / rate
			-- Make sure there's still something to display after any potential scaling.
			if scaledDuration > 2 * fadeTime then
				for col_mine in ivalues(columnCue.columns) do
					local col = col_mine.colNum
					local isMine = col_mine.isMine
					self:GetChild("Column"..col):playcommand("Flash", {
						duration=scaledDuration,
						isMine=isMine
					})
				end
			end
			curIndex = curIndex + 1
		end
	end
end

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:xy( GetNotefieldX(player), yOffset)
		local zoom_factor = 1 - scale( mods.Mini:gsub("%%","")/100, 0, 2, 0, 1)
		self:zoomx( zoom_factor )
		self:queuecommand("SetUpdate")
	end,
	SetUpdateCommand=function(self)
		self:SetUpdateFunction(Update)
	end
}

for columnIndex=1,numColumns do
	af[#af+1] = Def.Quad {
		Name="Column"..columnIndex,
		InitCommand=function(self)
			self:diffuse(0,0,0,0)
				:x((columnIndex - (numColumns/2 + 0.5)) * (width/numColumns))
				:vertalign(top)
				:setsize(width/numColumns, _screen.h - yOffset)
				:fadebottom(0.333)
		end,
		FlashCommand=function(self, params)
			local flashDuration = params.duration
			local clr = params.isMine and color("1,0,0,0.12") or color("0.3,1,1,0.12")
			self:stoptweening()
				:decelerate(fadeTime)
				:diffuse(clr)
				:sleep(flashDuration - 2*fadeTime)
				:accelerate(fadeTime)
				:diffuse(0,0,0,0)
		end
	}
end

return af