function PlayerJudgment()
	
	-- Allow users to artbitrarily add new judgment graphics to /Graphics/_judgments/
	-- without needing to modify this script;
	-- instead of hardcoding a list of judgment fonts, get directory listing via FILEMAN.
	local path = THEME:GetPathG("","_judgments")
	local files = FILEMAN:GetDirListing(path.."/")
	local judgmentGraphics = {}
	
	for k,filename in ipairs(files) do
		
		-- A user might put something that isn't a suitable judgment graphic
		-- into /Graphics/_judgments/ (also sometimes hidden files like .DS_Store show up here).
		-- Do our best to filter out such files now.
		if string.match(filename, " %dx%d.png") then
			-- use regexp to get only the name of the graphic, stripping out the extension 
			local name = string.gsub(filename, " %dx%d.png", "")
		
			-- The 3_9 graphic is a special case;
			-- we want it to appear in the options with a period (3.9 not 3_9).
			if name == "3_9" then name = "3.9" end
		
			-- Dynamically fill the table.
			-- Love is a special case; it should always be first.
			if name == "Love" then
				table.insert(judgmentGraphics, 1, name)
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
			local userJudgmentGraphic = SL[ToEnumShortString(pn)].ActiveModifiers.JudgmentGraphic
			local i = FindInTable(userJudgmentGraphic, judgmentGraphics) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			local sSave
			
			for i=1,#list do
				if list[i] then
					sSave=judgmentGraphics[i]
				end
			end
			
			SL[ToEnumShortString(pn)].ActiveModifiers.JudgmentGraphic = sSave
		end
	}
	return t
end


-- screen filter
function OptionRowPlayerFilter()
	local filters = { 'Off','Dark','Darker','Darkest' }
	local t = {
		Name = "Screen Filter",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = filters,
		LoadSelections = function(self, list, pn)
			local userScreenFilter = SL[ToEnumShortString(pn)].ActiveModifiers.ScreenFilter
			local i = FindInTable(userScreenFilter, filters) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			local sSave

			for i=1,#filters do
				if list[i] then
					sSave = filters[i]	
				end
			end

			SL[ToEnumShortString(pn)].ActiveModifiers.ScreenFilter = sSave
		end
	}
	return t
end


-- mini
function OptionRowPlayerMini()
	-- 200% mini is (literally) impossible to see, so don't bother.
	local mini = { "Normal" }
	for i=5,150,5 do
		mini[#mini+1] = tostring(i) .. "%"
	end
	
	local t = {
		Name = "Mini",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = mini,
		LoadSelections = function(self, list, pn)
			local userMini = SL[ToEnumShortString(pn)].ActiveModifiers.Mini
			local i = FindInTable(userMini, mini) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			local sSave

			for i=1,#mini do
				if list[i] then
					sSave = mini[i]	
				end
			end
			
			SL[ToEnumShortString(pn)].ActiveModifiers.Mini = sSave
			ApplyMini(pn)
		end
	}
	return t
end

function OptionRowSongMusicRate()
	local musicrate = {}
	for i=0.5,2.1,0.1 do
		musicrate[#musicrate+1] = string.format("%.1f",i)
	end
	
	local t = {
		Name = "Music Rate",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = true,
		Choices = musicrate,
		LoadSelections = function(self, list, pn)
			local userRate = string.format("%.1f", SL.Global.ActiveModifiers.MusicRate)
			local i = FindInTable(userRate, musicrate) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			local sSave

			for i=1,#musicrate do
				if list[i] then
					sSave = musicrate[i]	
				end
			end
			
			SL.Global.ActiveModifiers.MusicRate = tonumber(sSave)
			local topscreen = SCREENMAN:GetTopScreen():GetName()
		
			-- Use the older GameCommand interface for applying rate mods in Edit Mode;
			-- it seems to be the only way (probably due to how broken Edit Mode is, in general).
			-- As an unintentional side-effect of setting musicrate mods this way, they STAY set
			-- (between songs, between screens, etc.) until you manually change them.  This is (probably)
			-- not the desired behavior in EditMode, so when users change between different songs in EditMode,
			-- always reset the musicrate mod.  See: ./BGAnimations/ScreenEditMeny underlay.lua
			if topscreen == "ScreenEditOptions" then
				GAMESTATE:ApplyGameCommand("mod," .. sSave .."xmusic")
			else
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(tonumber(sSave))
			end
		
			MESSAGEMAN:Broadcast("MusicRateChanged")
		end
	}
	return t
end


-- ApplyMini() is called above, from OptionRowPlayerMini()
-- but also, and less obviously, from
-- /BGAnimations/ScreenSelectMusic overlay/playerModifiers.lua
function ApplyMini(pn)
	local mini = SL[ToEnumShortString(pn)].ActiveModifiers.Mini or "Normal"
	
	if mini == "Normal" then
		mini = 0
	else
		mini = mini:gsub("%%","")/100
	end
	
	local topscreen = SCREENMAN:GetTopScreen():GetName()
	local modslevel = topscreen  == "ScreenEditOptions" and "ModsLevel_Stage" or "ModsLevel_Preferred"
	
	-- to make the arrows smaller, pass Mini() a value between 0 and 1
	-- (to make the arrows bigger, pass Mini() a value larger than 1)
	GAMESTATE:GetPlayerState(pn):GetPlayerOptions(modslevel):Mini(mini)
end


function OptionRowHide()
	local t = {
		Name = "Hide",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectMultiple",
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = { "Targets", "Background", "Combo", "Life", "Score" },
		LoadSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers
			list[1] = mods.HideTargets or false
			list[2] = mods.HideSongBG or false
			list[3] = mods.HideCombo or false
			list[4] = mods.HideLifebar or false
			list[5] = mods.HideScore or false
		end,
		SaveSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers
			mods.HideTargets = list[1]
			mods.HideSongBG = list[2]
			mods.HideCombo = list[3]
			mods.HideLifebar = list[4]
			mods.HideScore = list[5]
			ApplyHide(pn)
		end,
	}
	return t
end

function ApplyHide(pn)
	local mods = SL[ToEnumShortString(pn)].ActiveModifiers

	local topscreen = SCREENMAN:GetTopScreen():GetName()
	local modslevel = (topscreen == "ScreenEditOptions") and "ModsLevel_Stage" or "ModsLevel_Preferred"

	local opts = GAMESTATE:GetPlayerState(pn):GetPlayerOptions(modslevel)
	opts:Dark(mods.HideTargets and 1 or 0)
	opts:Cover(mods.HideSongBG and 1 or 0)
end


function OptionRowVocalize()
	
	-- Allow users to artbitrarily add new vocalizations to ./Simply Love/Other/Vocalize/
	-- and have those vocalizations be automatically detected
	local files = FILEMAN:GetDirListing(GetVocalizeDir() , true, false)
	local vocalizations = { "None" }
	
	for k,dir in ipairs(files) do
		-- Dynamically fill the table.
		vocalizations[#vocalizations+1] = dir
	end
	
	if #vocalizations > 1 then
		vocalizations[#vocalizations+1] = "Random"
		vocalizations[#vocalizations+1] = "Blender"
	end
	
	local t = {
		Name = "UserScoreVocalization",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = vocalizations,
		LoadSelections = function(self, list, pn)
			local userVocal = SL[ToEnumShortString(pn)].ActiveModifiers.Vocalization
			local i = FindInTable(userVocal, vocalizations) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			local sSave
			
			for i=1,#list do
				if list[i] then
					sSave=vocalizations[i]
				end
			end
			
			SL[ToEnumShortString(pn)].ActiveModifiers.Vocalization = sSave
		end
	}
	return t
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
			if list[1] then SL.Global.ScreenAfter.PlayerOptions = Branch.GameplayScreen() end
			if list[2] then SL.Global.ScreenAfter.PlayerOptions = "ScreenSelectMusic" end
			if list[3] then SL.Global.ScreenAfter.PlayerOptions = "ScreenPlayerOptions2" end
		end
	}
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
			if list[1] then SL.Global.ScreenAfter.PlayerOptions2 =  Branch.GameplayScreen() end
			if list[2] then SL.Global.ScreenAfter.PlayerOptions2 =  "ScreenSelectMusic" end
			if list[3] then SL.Global.ScreenAfter.PlayerOptions2 =  "ScreenPlayerOptions" end
		end
	}
	return t
end