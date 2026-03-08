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

return Def.ActorFrame {
	Def.Quad {
		Name="CursorTop",
		InitCommand=function(self) self:zoomto(1,2):y(-12) end,
	},
	Def.Quad {
		Name="CursorBottom",
		InitCommand=function(self) self:zoomto(1,2):y(12) end,
		OptionRowChangedMessageCommand=function(self)
			if PlayerOnStepChartOptRow(player) then
				-- self:y(player==PLAYER_1 and 16 or 14)
				self:y(16)
			else
				-- self:y(player==PLAYER_1 and 12 or 10 )
				self:y(12)
			end
		end
	}
}