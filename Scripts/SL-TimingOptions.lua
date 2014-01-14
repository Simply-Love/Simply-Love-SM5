-- Timing Window Values
-- in SM5 these are saved in Preferences.ini
local TimingWindowValues = {

	--SM5 Default Timing Windows
	{	
		Hold=0.250000,
		Mine=0.090000,
		Roll=0.500000,
		W1=0.022500,
		W2=0.045000,
		W3=0.090000,
		W4=0.135000,
		W5=0.180000
	},

	--ITG Default Timing Windows
	{
		Hold=0.320000,
		Mine=0.070000,
		Roll=0.350000,
		W1=0.021500,
		W2=0.043000,
		W3=0.102000,
		W4=0.135000,
		W5=0.180000
	},

	--Pump Pro Default Timing Windows
	{
		Hold=0.350,
		Mine=0.070,
		Roll=0.350,
		W1=0.026,
		W2=0.055,
		W3=0.100,
		W4=0.145,
		W5=0
	}
};



-- Percent Score Weight Values
-- in SM5 these are theme-specific, and thus saved in Metrics.ini
-- under [ScoreKeeperNormal]
local PercentScoreWeightValues = {
	
	-- ITG Percent Score Weight Values
	{
		Held=5,
		HitMine=-6,
		LetGo=0,
		W1=5,
		W2=4,
		W3=2,
		W4=0,
		W5=-6,
		Miss=-12
	},
	
	-- 	SM5 Percent Score Weight Values
	{
		Held=IsGame("Pump") and 0 or 3,
		HitMine=-2,
		LetGo=0,
		Miss=0,
		W1=3,
		W2=2,
		W3=1,
		W4=0,
		W5=0
	},
	
	-- Pump Pro Percent Score Weight Values
	{
		Held=3,
		HitMine=-2,
		LetGo=0,
		W1=10,
		W2=8,
		W3=6,
		W4=2,
		W5=-2,
		Miss=-2
	}
};



-- Grade Weight Values
-- these are also theme-specific in SM5
-- again, [ScoreKeeperNormal] in Metrics.ini
local GradeWeightValues = {

	--SM5 Grade Weight Values
	{
		Held=IsGame("Pump") and 0 or 6,
		LetGo=0,
		HitMine=-8,
		W1=2,
		W2=2,
		W3=1,
		W4=0,
		W5=-4,
		Miss=-8
	},
	
	-- ITG Grade Weight Values
	{
		Held=5,
		LetGo=0,
		HitMine=-6,
		W1=5,
		W2=4,
		W3=2,
		W4=0,
		W5=-6,
		Miss=-12
	},

	-- Pump Pro Grade Weight Values
	{
		Held=6,
		LetGo=0,
		HitMine=-8,
		W1=10,
		W2=8,
		W3=6,
		W4=2,
		W5=-2,
		Miss=-2
	}
};




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
			local userWindow = GetUserPref("TimingWindow")
			
			if userWindow then
				for i=1,#windows do
					if userWindow == windows[i] then
						list[i] = true
					end
				end				
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local index;
			
			for i=1,#list do
				if list[i] then
					index=i
					SetUserPref("TimingWindow", windows[i] )
				end
			end			
						
			for k,v in pairs(TimingWindowValues[index]) do
				PREFSMAN:SetPreference("TimingWindowSeconds"..k, v );
			end
		end
	}
	setmetatable(t, t)
	return t
end



function PercentScoreWeight()
	local weights = { 'SM5','ITG','Pump Pro' };
	local t = {
		Name = "CustomPercentScoreWeight",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = weights,
		LoadSelections = function(self, list, pn)
			local userScoreWeight = GetUserPref("ScoreWeightSetting")
			
			if userScoreWeight then
				for i=1,#weights do
					if userScoreWeight == weights[i] then
						list[i] = true
					end
				end				
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			
			for i=1,#list do
				if list[i] then
					SetUserPref("ScoreWeightSetting", weights[i] )
				end
			end
			THEME:ReloadMetrics();
		end
	}
	setmetatable(t, t)
	return t
end



function GradeWeight()
	local weights = { 'SM5','ITG','Pump Pro' };
	local t = {
		Name = "CustomGradeWeight",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = weights,
		LoadSelections = function(self, list, pn)
			local userGradeWeight = GetUserPref("GradeWeightSetting")
			
			if userGradeWeight then
				for i=1,#weights do
					if userGradeWeight == weights[i] then
						list[i] = true
					end
				end				
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			
			for i=1,#list do
				if list[i] then
					SetUserPref("GradeWeightSetting", weights[i] )
				end
			end
			THEME:ReloadMetrics();
		end
	}
	setmetatable(t, t)
	return t
end



function SLPercentScoreWeight( event )
	--default to SM5 as fallback
	local index = 1;
	local ScoreWeightSetting = GetUserPref("ScoreWeightSetting") or "SM5";
	if ScoreWeightSetting == "ITG" then
		index = 2;
	elseif ScoreWeightSetting == "Pump Pro" then
		index = 3;
	end
	
	
	return PercentScoreWeightValues[index][event]
end

function SLGradeWeight( event )
	--default to SM5 as fallback
	local index = 1;
	local GradeWeightSetting = GetUserPref("GradeWeightSetting") or "SM5";
	if GradeWeightSetting == "ITG" then
		index = 2;
	elseif GradeWeightSetting == "Pump Pro" then
		index = 3;
	end
	return GradeWeightValues[index][event]
end