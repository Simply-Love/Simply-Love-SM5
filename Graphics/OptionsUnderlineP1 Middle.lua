local StepchartOptRowIndex = nil

-- get all the LinesNames as a single string from Metrics.ini, split on commas,
local LineNames = split(",", THEME:GetMetric("ScreenPlayerOptions", "LineNames"))
-- and loop through until we find one that matches "Stepchart" (or, we don't).
for i, name in ipairs(LineNames) do
	if name == "Stepchart" then StepchartOptRowIndex = i-1; break end
end
-- -----------------------------------------------------------------------

return Def.ActorFrame{
	Name="OptionsUnderlineMiddle",

	Def.Quad {
		InitCommand=function(self)
			self:zoomto(1,3)
		end,
		OptionRowChangedMessageCommand=function(self)
			-- apparently changing one particular OptionRow's underline sprite's y()
			-- once at Init or On isn't enough to stick because the engine will
			-- continue to reset the y() of each underline each time the user
			-- changes focus to a new OptionRow ...
			--
			-- So, SL's metrics will broadcast "OptionRowChanged" using MESSAGEMAN.
			-- Listen for that here, and find the underline actor for the StepChart
			-- OptionRow amidst myriad unnamed children belonging to the topscreen
			-- each and every time.
			local optrow = SCREENMAN:GetTopScreen():GetChild("Container"):GetChild("")[StepchartOptRowIndex+1]
			if not optrow then return end

			local underline_af = optrow:GetChild("")
			if not underline_af then return end

			-- there are 18 unnamed children (???)
			local unnamed_children = underline_af:GetChild("")
			if not unnamed_children then return end

			for k,v in ipairs(unnamed_children) do
				-- offset them all by 4px
				v:y(4)
			end
		end
	}
}