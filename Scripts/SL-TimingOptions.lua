-- Timing Window Values
-- in SM5 these are saved in Preferences.ini
TimingWindowValues = {}

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

function WhichTimingIsBeingUsed()
	local r
	
	for key,WindowSet in pairs(TimingWindowValues) do
		r = key
		
		for Category,WindowValue in pairs(WindowSet) do
			
			local CurrentWindow = PREFSMAN:GetPreference("TimingWindowSeconds"..Category)
			
			-- I guess it's only worth matching the first 6 decimal places?
			if ("%0.6f"):format(CurrentWindow) ~=  ("%0.6f"):format(WindowValue) then
				r = nil
				break
			end
		end
		
		-- if r still has a non-nil value, we have a match
		if r ~= nil then break end
	end
	
	-- if r is still nil by now, none of the above matched,
	-- so some sort of custom windows have been implemented
	if not r then
		r = "Custom"
		
		-- add a new index to the TimingWindowValues table
		TimingWindowValues["Custom"] = {
			Hold=PREFSMAN:GetPreference("TimingWindowSecondsHold"),
			Mine=PREFSMAN:GetPreference("TimingWindowSecondsMine"),
			Roll=PREFSMAN:GetPreference("TimingWindowSecondsRoll"),
			W1=PREFSMAN:GetPreference("TimingWindowSecondsW1"),
			W2=PREFSMAN:GetPreference("TimingWindowSecondsW2"),
			W3=PREFSMAN:GetPreference("TimingWindowSecondsW3"),
			W4=PREFSMAN:GetPreference("TimingWindowSecondsW4"),
			W5=PREFSMAN:GetPreference("TimingWindowSecondsW5")	
		}
	end	
	return r
end


function TimingWindow()
	
	local which = WhichTimingIsBeingUsed()
	local windows = { 'SM5','ITG','Pump Pro' }
	
	if which == "Custom" then
		windows = { 'SM5','ITG','Pump Pro', 'Custom' }
	end	
		
	local t = {
		Name = "CustomTimingWindow",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = windows,
		LoadSelections = function(self, list, pn)
			local i = FindInTable(which, windows) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			local index
			
			for i=1,#list do
				if list[i] then
					index=i
				end
			end			
			
			MESSAGEMAN:Broadcast("TimingWindowChanged", {TimingWindow=windows[index]})
			
			for k,v in pairs(TimingWindowValues[windows[index]]) do
				PREFSMAN:SetPreference("TimingWindowSeconds"..k, v )
			end
			PREFSMAN:SavePreferences()
		end
	}
	return t
end