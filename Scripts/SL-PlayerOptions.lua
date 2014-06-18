function PlayerJudgment()
	
	-- Allow users to artbitrarily add new judgment graphics to /Graphics/_judgments/
	-- without needing to modify this script;
	-- instead of hardcoding a list of judgment fonts, get directory listing via FILEMAN.
	local path = THEME:GetPathG("","_judgments");
	local files = FILEMAN:GetDirListing(path.."/");
	local judgmentGraphics = {};
	
	for k,filename in ipairs(files) do
		
		-- A user might put something that isn't a suitable judgment graphic
		-- into /Graphics/_judgments/ (also sometimes hidden files like .DS_Store show up here).
		-- Do our best to filter out such files now.
		if string.match(filename, " %dx%d.png") then
			-- use regexp to get only the name of the graphic, stripping out the extension 
			local name = string.gsub(filename, " %dx%d.png", "");
		
			-- The 3_9 graphic is a special case;
			-- we want it to appear in the options with a period (3.9 not 3_9).
			if name == "3_9" then name = "3.9" end
		
			-- Dynamically fill the table.
			-- Love is a special case; it should always be first.
			if name == "Love" then
				table.insert(judgmentGraphics, 1, name);
			else
				judgmentGraphics[#judgmentGraphics+1] = name
			end
		end
	end
	
	judgmentGraphics[#judgmentGraphics+1] = "None"
	
	
	local t = {
		Name = "UserPlayerJudgment",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = judgmentGraphics,
		LoadSelections = function(self, list, pn)
			local userJudgmentGraphic = getenv("JudgmentGraphic" .. ToEnumShortString(pn));
			local i = FindInTable(userJudgmentGraphic, judgmentGraphics) or 1
			list[i] = true;
		end,
		SaveSelections = function(self, list, pn)
			local sSave;
			
			for i=1,#list do
				if list[i] then
					sSave=judgmentGraphics[i]
				end
			end
			
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
			local userScreenFilter = getenv("ScreenFilter"..ToEnumShortString(pn));
			local i = FindInTable(userScreenFilter, filters) or 1
			list[i] = true;
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
	-- 200% mini is (literally) impossible to see, so don't bother.
	local mini = { "Normal" };
	for i=1,30 do
		mini[#mini+1] = tostring(i * 5) .. "%";
	end
	
	local t = {
		Name = "Mini";
		LayoutType = "ShowAllInRow";
		SelectType = "SelectOne";
		OneChoiceForAllPlayers = false;
		ExportOnChange = true;
		Choices = mini;
		LoadSelections = function(self, list, pn)
			local userMini = getenv("Mini"..ToEnumShortString(pn));
			local i = FindInTable(userMini, mini) or 1
			list[i] = true;
		end;
		SaveSelections = function(self, list, pn)
			local sSave;

			for i=1,#mini do
				if list[i] then
					sSave = mini[i]	
				end
			end
			
			setenv("Mini"..ToEnumShortString(pn), sSave);
			ApplyMini(pn);
		end;
	};
	setmetatable( t, t );
	return t;
end;


-- ApplyMini() is called above, from OptionRowPlayerMini()
-- but also, and less obviously, from
-- /BGAnimations/ScreenSelectMusic overlay/playerModifiers.lua
function ApplyMini(pn)
	local mini;
	local envMini = getenv("Mini" .. ToEnumShortString(pn)) or "Normal";
	
	if envMini == "Normal" then
		mini = "no mini";
	else
		mini = envMini .. " mini";
	end
	
	GAMESTATE:ApplyGameCommand('mod,' .. mini, pn)
end








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
			if list[1] then setenv("ScreenPlayerOptions", Branch.GameplayScreen()) end
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
			if list[1] then setenv("ScreenPlayerOptions2", Branch.GameplayScreen()) end
			if list[2] then setenv("ScreenPlayerOptions2", "ScreenSelectMusic") end
			if list[3] then setenv("ScreenPlayerOptions2", "ScreenPlayerOptions") end
		end
	}
	setmetatable(t, t)
	return t
end