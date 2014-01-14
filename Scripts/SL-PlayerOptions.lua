function PlayerJudgment()
	local judgmentGraphics = { 'Love','3.9','ITG2','GrooveNights','Chromatic','Tactics','Emoticon' };
	local t = {
		Name = "UserPlayerJudgment",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = judgmentGraphics,
		LoadSelections = function(self, list, pn)
			local userJudgmentGraphic = getenv("JudgmentGraphic" .. ToEnumShortString(pn))
			
			if userJudgmentGraphic then
				for i=1,#judgmentGraphics do
					if userJudgmentGraphic == judgmentGraphics[i] then
						list[i] = true
					end
				end				
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local sSave;
			
			for i=1,#list do
				if list[i] then
					sSave=judgmentGraphics[i]
				end
			end
			
			--SetUserPref("JudgmentGraphic" .. ToEnumShortString(pn), sSave);
			setenv("JudgmentGraphic"..ToEnumShortString(pn), sSave);
		end
	}
	setmetatable(t, t)
	return t
end


-- screen filter
function OptionRowPlayerFilter()
	local filters = { 'Off','Dark','Darker','Darkest' };
	local t = {
		Name = "Screen Filter";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = false;
		ExportOnChange = false;
		Choices = filters;
		LoadSelections = function(self, list, pn)
								
			if getenv("ScreenFilter"..ToEnumShortString(pn)) then
				for i=1,#filters do
					if filters[i] == getenv("ScreenFilter"..ToEnumShortString(pn)) then
						list[i] = true;
					end;
				end
			else
				list[1] = true;
			end
			
		end;
		SaveSelections = function(self, list, pn)
			local sSave;

			for i=1,#filters do
				if list[i] then
					sSave = filters[i]	
				end
			end

			setenv("ScreenFilter"..ToEnumShortString(pn), sSave);
		end;
	};
	setmetatable( t, t );
	return t;
end;


-- mini
function OptionRowPlayerMini()
	local mini = { "Normal","10%","20%","30%","40%","50%","60%","70%","80%","90%","98%" };
	local t = {
		Name = "Mini";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = false;
		ExportOnChange = false;
		Choices = mini;
		LoadSelections = function(self, list, pn)
			local pname = pname(pn);
			
			if getenv("Mini"..pname) then
				for i=1,#mini do
					if mini[i] == getenv("Mini"..pname) then
						list[i] = true;
					end;
				end
			else
				list[1] = true;
			end
			
		end;
		SaveSelections = function(self, list, pn)
			local sSave;

			for i=1,#mini do
				if list[i] then
					sSave = mini[i]	
				end
			end

			setenv("Mini"..ToEnumShortString(pn), sSave);
			
			local mod;
			if sSave == "Normal" then
				mod = "no mini"
			else
				mod = sSave.. " mini"
			end
			
			GAMESTATE:ApplyGameCommand('mod,' ..  mod, pn)	
		end;
	};
	setmetatable( t, t );
	return t;
end;












function ForwardOrBackward()
	local t = {
		Name = "ForwardOrBackward",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = { 'Gameplay', 'Select Music', 'Extra Modifiers' },
		LoadSelections = function(self, list, pn)
			list[1] = true
		end,
		SaveSelections = function(self, list, pn)
			if list[1] then setenv("ScreenPlayerOptions", "ScreenStageInformation") end
			if list[2] then setenv("ScreenPlayerOptions", "ScreenSelectMusic") end
			if list[3] then setenv("ScreenPlayerOptions", "ScreenPlayerOptions2") end
		end
	}
	setmetatable(t, t)
	return t
end


function ForwardOrBackward2()
	local t = {
		Name = "ForwardOrBackward2",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = { 'Gameplay', 'Select Music', 'Normal Modifiers' },
		LoadSelections = function(self, list, pn)
			list[1] = true
		end,
		SaveSelections = function(self, list, pn)
			if list[1] then setenv("ScreenPlayerOptions2", "ScreenStageInformation") end
			if list[2] then setenv("ScreenPlayerOptions2", "ScreenSelectMusic") end
			if list[3] then setenv("ScreenPlayerOptions2", "ScreenPlayerOptions") end
		end
	}
	setmetatable(t, t)
	return t
end