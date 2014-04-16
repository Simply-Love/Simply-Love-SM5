function PlayerJudgment()
	
	-- allow users to artbitrarily add new judgment graphics to /Graphics/Player judgment/
	-- without needing to modify this script;
	-- instead of hardcoding a list of judgment fonts, get directory listing via FILEMAN 
	local path = THEME:GetPathG("Player","judgment");
	path = string.gsub(path, "default.lua", "");
	local files = FILEMAN:GetDirListing(path);
	local judgmentGraphics = {};
	
	for k,filename in ipairs(files) do
		-- FILEMAN returns all directory contents, but we're only interested in .png files,
		-- so ignore default.lua
		if filename ~= "default.lua" then
			
			-- use regexp to get only the name of the graphic, stripping out the extension 
			local tempname = string.gsub(filename, " %dx%d.png", "");
			-- the 3_9 graphic is a special case; we want it to appear in the options with a period (3.9 not 3_9)
			if tempname == "3_9" then tempname = "3.9" end
			-- dynamically fill the table
			judgmentGraphics[#judgmentGraphics+1] = tempname
		end
	end
	
	local t = {
		Name = "UserPlayerJudgment",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = judgmentGraphics,
		LoadSelections = function(self, list, pn)
			local userJudgmentGraphic = getenv("JudgmentGraphic" .. ToEnumShortString(pn));
			list[1] = true;
			
			if userJudgmentGraphic then
				for i=1,#judgmentGraphics do
					if userJudgmentGraphic == judgmentGraphics[i] then
						list[1] = nil;
						list[i] = true;
					end
				end
			end
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
			list[1] = true;
						
			if userScreenFilter then
				for i=1,#filters do
					if userScreenFilter == filters[i] then
						list[1] = nil;
						list[i] = true;
					end;
				end
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
			local userMini = getenv("Mini"..ToEnumShortString(pn));
			list[1] = true;
			
			if userMini then
				for i=1,#mini do
					if userMini == mini[i] then
						list[1] = nil;
						list[i] = true;
					end;
				end
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