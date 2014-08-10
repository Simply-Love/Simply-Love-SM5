-- Timing Window Values
-- in SM5 these are saved in Preferences.ini
local TimingWindowValues = {}

--SM5 Default Timing Windows
TimingWindowValues["SM5"] = {	
	Hold=0.250000,
	Mine=0.090000,
	Roll=0.500000,
	W1=0.022500,
	W2=0.045000,
	W3=0.090000,
	W4=0.135000,
	W5=0.180000
}

--ITG Default Timing Windows
TimingWindowValues["ITG"] = {
	Hold=0.320000,
	Mine=0.070000,
	Roll=0.350000,
	W1=0.021500,
	W2=0.043000,
	W3=0.102000,
	W4=0.135000,
	W5=0.180000
}

--Pump Pro Default Timing Windows
TimingWindowValues["Pump Pro"] = {
	Hold=0.350,
	Mine=0.070,
	Roll=0.350,
	W1=0.026,
	W2=0.055,
	W3=0.100,
	W4=0.145,
	W5=0
}


function TimingWindow()
	local windows = { 'SM5','ITG','Pump Pro' };
	local t = {
		Name = "CustomTimingWindow",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = windows,
		LoadSelections = function(self, list, pn)
			local userWindow = ThemePrefs.Get("TimingWindow")
			local i = FindInTable(userWindow, windows) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			local index
			
			for i=1,#list do
				if list[i] then
					index=i
					ThemePrefs.Set("TimingWindow", windows[i] )
					ThemePrefs.Save()
				end
			end			
						
			for k,v in pairs(TimingWindowValues[windows[index]]) do
				PREFSMAN:SetPreference("TimingWindowSeconds"..k, v );
			end
			PREFSMAN:SavePreferences()
		end
	}
	return t
end