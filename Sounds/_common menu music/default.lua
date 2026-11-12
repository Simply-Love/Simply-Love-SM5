local style = GetVisualStyle()

if PREFSMAN:GetPreference("EasterEggs") and style.id ~= "Thonk" then
	if MonthOfYear() == 10 and DayOfMonth() == 20 then
		return THEME:GetPathS("", "_common menu music/20")
	end
	if MonthOfYear() == 11 then
		return THEME:GetPathS("", "_common menu music/HolidayCheer")
	end
end

return VisualStyleSound("menuMusic")
