local player = ...
if not player then return Def.Actor end

local StepchartOptRowIndex = nil

-- get all the LinesNames as a single string from Metrics.ini, split on commas,
local LineNames = split(",", THEME:GetMetric("ScreenPlayerOptions", "LineNames"))
-- and loop through until we find one that matches "Stepchart" (or, we don't).
for i, name in ipairs(LineNames) do
	if name == "Stepchart" then StepchartOptRowIndex = i-1; break end
end

local PlayerOnStepChartOptRow = function(p)
	return SCREENMAN:GetTopScreen():GetCurrentRowIndex(p) == StepchartOptRowIndex
end

-- -----------------------------------------------------------------------

return Def.Quad {
	Name="CursorRight",
	InitCommand=function(self) self:zoomto(2,26) end,
	OptionRowChangedMessageCommand=function(self, params)
		if PlayerOnStepChartOptRow(player) then
			self:y(player==PLAYER_1 and 1 or 3):zoomto(2,30)
		else
			self:y(player==PLAYER_1 and -1 or 1):zoomto(2,26)
		end
	end
}