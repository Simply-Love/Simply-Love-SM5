SortMenuNeedsUpdating = false

----- Option names for each dynamic sort/filter value
local MainSortIndex = GetMainSortPreference()
local SubSortIndex = GetSubSortPreference()
local CurrentLowerDifficulty = GetLowerDifficultyFilter()
local CurrentUpperDifficulty = GetUpperDifficultyFilter()
local CurrentLowerBPM = GetLowerBPMFilter()
local CurrentUpperBPM = GetUpperBPMFilter()
local CurrentLowerLength = GetLowerLengthFilter()
local CurrentUpperLength = GetUpperLengthFilter()
local IsTopSortActive = false

local MainSort = {
	"GROUP",
	"TITLE",
	"ARTIST",
	"LENGTH",
	"BPM",
	"DIFFICULTY",
}


local SubSort = {
	"GROUP",
	"TITLE",
	"ARTIST",
	"LENGTH",
	"BPM",
	"# OF STEPS",
	"DIFFICULTY",
}

---------- The text/number values and how they change based on scroll ----------
local t = Def.ActorFrame {
	InitCommand=function(self)
		self:draworder(105)
	end,
	
----- We need a seperate init command otherwise the sort menu will have no idea
----- if it needs to refresh or not.
InitializeDDSortMenuMessageCommand=function(self)
	self:queuecommand("RefreshMainSort")
	self:queuecommand("RefreshSubSort")
	self:queuecommand("RefreshLowerDifficulty")
	self:queuecommand("RefreshUpperDifficulty")
	self:queuecommand("RefreshLowerBPM")
	self:queuecommand("RefreshUpperBPM")
	self:queuecommand("RefreshLowerLength")
	self:queuecommand("RefreshUpperLength")
end,
	
---- Only sets and saves the stat if it's actually being picked by pressing enter.
---- This way if a player changes there mind and presses select/back it won't save or set.
---- It will also reset once the screen is reloaded.
SetSortMenuTopStatsMessageCommand = function(self)
	if IsSortMenuInputToggled == true then
		if DDSortMenuCursorPosition == 1 then
			SetMainSortPreference(MainSortIndex)
		end
		if DDSortMenuCursorPosition == 2 then
			SetSubSortPreference(SubSortIndex)
		end
		if DDSortMenuCursorPosition == 3 then
			SetLowerDifficultyFilter(CurrentLowerDifficulty)
		end	
		if DDSortMenuCursorPosition == 4 then
			SetUpperDifficultyFilter(CurrentUpperDifficulty)
		end	
		if DDSortMenuCursorPosition == 5 then
			SetLowerBPMFilter(CurrentLowerBPM)
		end	
		if DDSortMenuCursorPosition == 6 then
			SetUpperBPMFilter(CurrentUpperBPM)
		end	
		if DDSortMenuCursorPosition == 7 then
			SetLowerLengthFilter(CurrentLowerLength)
		end	
		if DDSortMenuCursorPosition == 8 then
			SetUpperLengthFilter(CurrentUpperLength)
		end	
		
		SortMenuNeedsUpdating = true
		
	end
end,

	----- CONTROLS WHAT THE UPPER OPTIONS DO WHEN YOU PRESS LEFT -----
	MoveSortMenuOptionLeftMessageCommand=function(self)
		if DDSortMenuCursorPosition == 1 then
			if MainSortIndex == 1 then
				MainSortIndex = 6
				self:queuecommand('ScrollLeftMainSort')
			else
				MainSortIndex = tonumber(MainSortIndex) - 1
				self:queuecommand('ScrollLeftMainSort')
			end
		end
		if DDSortMenuCursorPosition == 2 then
			if SubSortIndex == 1 then
				SubSortIndex = 7
				self:queuecommand('ScrollLeftSubSort')
			else
				SubSortIndex = tonumber(SubSortIndex) - 1
				self:queuecommand('ScrollLeftSubSort')
			end
		end
		if DDSortMenuCursorPosition == 3 then
			if tonumber(CurrentLowerDifficulty) <= 0 then
				CurrentLowerDifficulty = 30
				self:queuecommand('UpdateLowerDifficulty')
			else
				CurrentLowerDifficulty = CurrentLowerDifficulty - 1
				self:queuecommand('UpdateLowerDifficulty')
			end
			if IsTopSortActive == true then
				SetUpperDifficultyFilter(CurrentUpperDifficulty)
			end
			
		end	
		if DDSortMenuCursorPosition == 4 then
			if tonumber(CurrentUpperDifficulty) <= 0 then
				CurrentUpperDifficulty = 30
				self:queuecommand('UpdateUpperDifficulty')
			else
				CurrentUpperDifficulty = CurrentUpperDifficulty - 1
				self:queuecommand('UpdateUpperDifficulty')
			end
		end	
		if DDSortMenuCursorPosition == 5 then
			if tonumber(CurrentLowerBPM) <= 49 then
				CurrentLowerBPM = 330
				self:queuecommand('UpdateLowerBPM')
			else
				CurrentLowerBPM = CurrentLowerBPM - 1
				self:queuecommand('UpdateLowerBPM')
			end
		end
		if DDSortMenuCursorPosition == 6 then
			if tonumber(CurrentUpperBPM) <= 49 then
				CurrentUpperBPM = 330
				self:queuecommand('UpdateUpperBPM')
			else
				CurrentUpperBPM = CurrentUpperBPM - 1
				self:queuecommand('UpdateUpperBPM')
			end
		end
		if DDSortMenuCursorPosition == 7 then
			if tonumber(CurrentLowerLength) == 0 then
				CurrentLowerLength = 3600
				self:queuecommand('UpdateLowerLength')
			--- go in increments of 30sec for songs less than 1 minute
			elseif tonumber(CurrentLowerLength) > 0 and tonumber(CurrentLowerLength) <= 60 then
				CurrentLowerLength = CurrentLowerLength - 30
				self:queuecommand('UpdateLowerLength')
			--- go in increments of 5sec for songs between 1min and 10min
			elseif tonumber(CurrentLowerLength) > 60 and tonumber(CurrentLowerLength) <= 600 then
				CurrentLowerLength = CurrentLowerLength - 5
				self:queuecommand('UpdateLowerLength')
			--- go in increments of 1min for songs between 10min and 30min
			elseif tonumber(CurrentLowerLength) > 600 and tonumber(CurrentLowerLength) <= 1800 then
				CurrentLowerLength = CurrentLowerLength - 60
				self:queuecommand('UpdateLowerLength')
			--- go in increments of 10min for songs longer than 30min
			elseif tonumber(CurrentLowerLength) > 1800 and tonumber(CurrentLowerLength) <= 3600 then
				CurrentLowerLength = CurrentLowerLength - 600
				self:queuecommand('UpdateLowerLength')
			end
		end
		if DDSortMenuCursorPosition == 8 then
			if tonumber(CurrentUpperLength) == 0 then
				CurrentUpperLength = 3600
				self:queuecommand('UpdateUpperLength')
			--- go in increments of 30sec for songs less than 1 minute
			elseif tonumber(CurrentUpperLength) > 0 and tonumber(CurrentUpperLength) <= 60 then
				CurrentUpperLength = CurrentUpperLength - 30
				self:queuecommand('UpdateUpperLength')
			--- go in increments of 5sec for songs between 1min and 10min
			elseif tonumber(CurrentUpperLength) > 60 and tonumber(CurrentUpperLength) <= 600 then
				CurrentUpperLength = CurrentUpperLength - 5
				self:queuecommand('UpdateUpperLength')
			--- go in increments of 1min for songs between 10min and 30min
			elseif tonumber(CurrentUpperLength) > 600 and tonumber(CurrentUpperLength) <= 1800 then
				CurrentUpperLength = CurrentUpperLength - 60
				self:queuecommand('UpdateUpperLength')
			--- go in increments of 10min for songs longer than 30min
			elseif tonumber(CurrentUpperLength) > 1800 and tonumber(CurrentUpperLength) <= 3600 then
				CurrentUpperLength = CurrentUpperLength - 600
				self:queuecommand('UpdateUpperLength')
			end
		end
	end,

	----- CONTROLS WHAT THE UPPER OPTIONS DO WHEN YOU PRESS RIGHT -----
	MoveSortMenuOptionRightMessageCommand=function(self)
		if DDSortMenuCursorPosition == 1 then
			if MainSortIndex == 6 then
				MainSortIndex = 1
				self:queuecommand('ScrollRightMainSort')
			else
				MainSortIndex = tonumber(MainSortIndex) + 1
				self:queuecommand('ScrollRightMainSort')
			end
		end
		if DDSortMenuCursorPosition == 2 then
			if SubSortIndex == 7 then
				SubSortIndex = 1
				self:queuecommand('ScrollRightSubSort')
			else
				SubSortIndex = tonumber(SubSortIndex) + 1
				self:queuecommand('ScrollRightSubSort')
			end
		end
		if DDSortMenuCursorPosition == 3 then
			if tonumber(CurrentLowerDifficulty) >= 30 then
				CurrentLowerDifficulty = 0
				self:queuecommand('UpdateLowerDifficulty')
			else
				CurrentLowerDifficulty = CurrentLowerDifficulty + 1
				self:queuecommand('UpdateLowerDifficulty')
			end
		end	
		if DDSortMenuCursorPosition == 4 then
			if tonumber(CurrentUpperDifficulty) >= 30 then
				CurrentUpperDifficulty = 0
				self:queuecommand('UpdateUpperDifficulty')
			else
				CurrentUpperDifficulty = CurrentUpperDifficulty + 1
				self:queuecommand('UpdateUpperDifficulty')
			end
		end	
		if DDSortMenuCursorPosition == 5 then
			if tonumber(CurrentLowerBPM) >= 330 then
				CurrentLowerBPM = 49
				self:queuecommand('UpdateLowerBPM')
			else
				CurrentLowerBPM = CurrentLowerBPM + 1
				self:queuecommand('UpdateLowerBPM')
			end
		end
		if DDSortMenuCursorPosition == 6 then
			if tonumber(CurrentUpperBPM) >= 330 then
				CurrentUpperBPM = 49
				self:queuecommand('UpdateUpperBPM')
			else
				CurrentUpperBPM = CurrentUpperBPM + 1
				self:queuecommand('UpdateUpperBPM')
			end
		end
		if DDSortMenuCursorPosition == 7 then
			if tonumber(CurrentLowerLength) == 3600 then
				CurrentLowerLength = 0
				self:queuecommand('UpdateLowerLength')
			--- go in increments of 30sec for songs less than 1 minute
			elseif tonumber(CurrentLowerLength) >= 0 and tonumber(CurrentLowerLength) < 60 then
				CurrentLowerLength = CurrentLowerLength + 30
				self:queuecommand('UpdateLowerLength')
			--- go in increments of 5sec for songs between 1min and 10min
			elseif tonumber(CurrentLowerLength) >= 60 and tonumber(CurrentLowerLength) < 600 then
				CurrentLowerLength = CurrentLowerLength + 5
				self:queuecommand('UpdateLowerLength')
			--- go in increments of 1min for songs between 10min and 30min
			elseif tonumber(CurrentLowerLength) >= 600 and tonumber(CurrentLowerLength) < 1800 then
				CurrentLowerLength = CurrentLowerLength + 60
				self:queuecommand('UpdateLowerLength')
			--- go in increments of 10min for songs longer than 30min
			elseif tonumber(CurrentLowerLength) >= 1800 and tonumber(CurrentLowerLength) < 3600 then
				CurrentLowerLength = CurrentLowerLength + 600
				self:queuecommand('UpdateLowerLength')
			end
		end
		if DDSortMenuCursorPosition == 8 then
			if tonumber(CurrentUpperLength) == 3600 then
				CurrentUpperLength = 0
				self:queuecommand('UpdateUpperLength')
			--- go in increments of 30sec for songs less than 1 minute
			elseif tonumber(CurrentUpperLength) >= 0 and tonumber(CurrentUpperLength) < 60 then
				CurrentUpperLength = CurrentUpperLength + 30
				self:queuecommand('UpdateUpperLength')
			--- go in increments of 5sec for songs between 1min and 10min
			elseif tonumber(CurrentUpperLength) >= 60 and tonumber(CurrentUpperLength) < 600 then
				CurrentUpperLength = CurrentUpperLength + 5
				self:queuecommand('UpdateUpperLength')
			--- go in increments of 1min for songs between 10min and 30min
			elseif tonumber(CurrentUpperLength) >= 600 and tonumber(CurrentUpperLength) < 1800 then
				CurrentUpperLength = CurrentUpperLength + 60
				self:queuecommand('UpdateUpperLength')
			--- go in increments of 10min for songs longer than 30min
			elseif tonumber(CurrentUpperLength) >= 1800 and tonumber(CurrentUpperLength) < 3600 then
				CurrentUpperLength = CurrentUpperLength + 600
				self:queuecommand('UpdateUpperLength')
			end
		end
	end,


----------------------------------------------------------------------------------------------------
--------------------------------------- The (mostly) numbers ---------------------------------------
----------------------------------------------------------------------------------------------------
	
	----- MAIN SORT TEXT OPTIONS -----
		Def.BitmapText{
			Font="Miso/_miso",
			InitCommand=function(self)
				self:diffuse(color("#FFFFFF"))
				self:horizalign(center)
				self:xy(SCREEN_CENTER_X + 50,SCREEN_CENTER_Y - 135)
				self:zoom(1.1)
				for i, v in ipairs(MainSort) do
					i = MainSortIndex
					v = MainSort[i]
					MainSortText = v
				end
				self:settext(MainSortText)
			end,
			
			RefreshMainSortCommand=function(self)
				for i, v in ipairs(MainSort) do
					i = MainSortIndex
					v = MainSort[i]
					MainSortText = v
				end
				self:settext(MainSortText)
			end,
		
			ScrollLeftMainSortCommand=function(self)
				for i, v in ipairs(MainSort) do
					i = MainSortIndex
					v = MainSort[i]
					MainSortText = v
				end
				self:settext(MainSortText)
			end,
			
			ScrollRightMainSortCommand=function(self)
				for i, v in ipairs(MainSort) do
					i = MainSortIndex
					v = MainSort[i]
					MainSortText = v
				end
				self:settext(MainSortText)
			end,
		},
	
	----- SUB SORT TEXT OPTIONS -----
		Def.BitmapText{
			Font="Miso/_miso",
			InitCommand=function(self)
				self:diffuse(color("#FFFFFF"))
				self:horizalign(center)
				self:xy(SCREEN_CENTER_X + 50,SCREEN_CENTER_Y - 110)
				self:zoom(1.1)
				for i, v in ipairs(SubSort) do
					i = SubSortIndex
					v = SubSort[i]
					SubSortText = v
				end
				self:settext(SubSortText)
			end,
			
			RefreshSubSortCommand=function(self)
				for i, v in ipairs(SubSort) do
					i = GetSubSortPreference()
					v = SubSort[i]
					SubSortText = v
				end
				self:settext(SubSortText)
			end,
		
			ScrollLeftSubSortCommand=function(self)
				for i, v in ipairs(SubSort) do
					i = SubSortIndex
					v = SubSort[i]
					SubSortText = v
				end
				self:settext(SubSortText)
			end,
			
			ScrollRightSubSortCommand=function(self)
				for i, v in ipairs(SubSort) do
					i = SubSortIndex
					v = SubSort[i]
					SubSortText = v
				end
				self:settext(SubSortText)
			end,
		},
	
	
	----- Lower bound Difficulty Filter -----
		Def.BitmapText{
			Font="Miso/_miso",
			InitCommand=function(self)
				self:diffuse(color("#FFFFFF"))
				self:horizalign(center)
				self:xy(SCREEN_CENTER_X + 34,SCREEN_CENTER_Y - 85)
				self:zoom(1.1)
				if tonumber(GetLowerDifficultyFilter()) == 0 then
					self:settext("none")
				else
					self:settext(GetLowerDifficultyFilter())
				end
			end,
			
			RefreshLowerDifficultyCommand=function(self)
				if tonumber(GetLowerDifficultyFilter()) == 0 then
					self:settext("none")
				else
					self:settext(GetLowerDifficultyFilter())
				end
			end,
		
			UpdateLowerDifficultyCommand=function(self)
				if tonumber(CurrentLowerDifficulty) == 0 then
					self:settext("none")
				else
					self:settext(CurrentLowerDifficulty)
				end
			end,
		},
		
		----- Upper bound Difficulty Filter -----
		Def.BitmapText{
			Font="Miso/_miso",
			InitCommand=function(self)
				self:diffuse(color("#FFFFFF"))
				self:horizalign(center)
				self:xy(SCREEN_CENTER_X + 115,SCREEN_CENTER_Y - 85)
				self:zoom(1.1)
				if tonumber(GetUpperDifficultyFilter()) == 0 then
					self:settext("none")
				else
					self:settext(GetUpperDifficultyFilter())
				end
			end,
		
			RefreshUpperDifficultyCommand=function(self)
				if tonumber(GetUpperDifficultyFilter()) == 0 then
					self:settext("none")
				else
					self:settext(GetUpperDifficultyFilter())
				end
			end,
		
		
			UpdateUpperDifficultyCommand=function(self)
				if tonumber(CurrentUpperDifficulty) == 0 then
					self:settext("none")
				else
					self:settext(CurrentUpperDifficulty)
				end
			end,
		},
		
	----- Lower bound BPM Filter -----
	Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			self:diffuse(color("#FFFFFF"))
			self:horizalign(center)
			self:xy(SCREEN_CENTER_X - 20,SCREEN_CENTER_Y - 60)
			self:zoom(1.1)
			if tonumber(GetLowerBPMFilter()) == 49 then
				self:settext("none")
			else
				self:settext(GetLowerBPMFilter())
			end
		end,
		
		RefreshLowerBPMCommand=function(self)
			if tonumber(GetLowerBPMFilter()) == 49 then
				self:settext("none")
			else
				self:settext(GetLowerBPMFilter())
			end
		end,
		
		
		UpdateLowerBPMCommand=function(self)
			if tonumber(CurrentLowerBPM) == 49 then
				self:settext("none")
			else
				self:settext(CurrentLowerBPM)
			end
		end,
		
		},
		
	----- Upper bound BPM Filter -----
	Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			self:diffuse(color("#FFFFFF"))
			self:horizalign(center)
			self:xy(SCREEN_CENTER_X + 60,SCREEN_CENTER_Y - 60)
			self:zoom(1.1)
			if tonumber(GetUpperBPMFilter()) == 49 then
				self:settext("none")
			else
				self:settext(GetUpperBPMFilter())
			end
		end,
		
		RefreshUpperBPMCommand=function(self)
			if tonumber(GetUpperBPMFilter()) == 49 then
				self:settext("none")
			else
				self:settext(GetUpperBPMFilter())
			end
		end,
		
		UpdateUpperBPMCommand=function(self)
			if tonumber(CurrentUpperBPM) == 49 then
				self:settext("none")
			else
				self:settext(CurrentUpperBPM)
			end
		end,
		
		},

	----- Lower bound Length Filter -----
	Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			self:diffuse(color("#FFFFFF"))
			self:horizalign(center)
			self:xy(SCREEN_CENTER_X + 16,SCREEN_CENTER_Y - 35)
			self:zoom(1.1)
			if tonumber(GetLowerLengthFilter()) == 0 then
				self:settext("none")
			elseif tonumber(GetLowerLengthFilter()) > 0 and tonumber(GetLowerLengthFilter()) < 600 then
				self:settext(SecondsToMSS(GetLowerLengthFilter()))
			elseif tonumber(GetLowerLengthFilter()) >= 600 and tonumber(GetLowerLengthFilter()) < 3600 then
				self:settext(SecondsToMMSS(GetLowerLengthFilter()))
			elseif tonumber(GetLowerLengthFilter()) == 3600 then
				self:settext("1:00:00")
			end
		end,
		
		RefreshLowerLengthCommand=function(self)
			if tonumber(GetLowerLengthFilter()) == 0 then
				self:settext("none")
			elseif tonumber(GetLowerLengthFilter()) > 0 and tonumber(GetLowerLengthFilter()) < 600 then
				self:settext(SecondsToMSS(GetLowerLengthFilter()))
			elseif tonumber(GetLowerLengthFilter()) >= 600 and tonumber(GetLowerLengthFilter()) < 3600 then
				self:settext(SecondsToMMSS(GetLowerLengthFilter()))
			elseif tonumber(GetLowerLengthFilter()) == 3600 then
				self:settext("1:00:00")
			end
		end,
		
		UpdateLowerLengthCommand=function(self)
			if tonumber(CurrentLowerLength) == 0 then
				self:settext("none")
			elseif tonumber(CurrentLowerLength) > 0 and tonumber(CurrentLowerLength) < 600 then
				self:settext(SecondsToMSS(CurrentLowerLength))
			elseif tonumber(CurrentLowerLength) >= 600 and tonumber(CurrentLowerLength) < 3600 then
				self:settext(SecondsToMMSS(CurrentLowerLength))
			elseif tonumber(CurrentLowerLength) == 3600 then
				self:settext("1:00:00")
			end
		end,
		
		},
		
	----- Upper bound Length Filter -----
	Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			self:diffuse(color("#FFFFFF"))
			self:horizalign(center)
			self:xy(SCREEN_CENTER_X + 115,SCREEN_CENTER_Y - 35)
			self:zoom(1.1)
			if tonumber(GetUpperLengthFilter()) == 0 then
				self:settext("none")
			elseif tonumber(GetUpperLengthFilter()) < 600 then
				self:settext(SecondsToMSS(GetUpperLengthFilter()))
			elseif tonumber(GetUpperLengthFilter()) >= 600 and tonumber(GetUpperLengthFilter()) < 3600 then
				self:settext(SecondsToMMSS(GetUpperLengthFilter()))
			elseif tonumber(GetUpperLengthFilter()) == 3600 then
				self:settext("1:00:00")
			end
		end,
		
		RefreshUpperLengthCommand=function(self)
			if tonumber(GetUpperLengthFilter()) == 0 then
				self:settext("none")
			elseif tonumber(GetUpperLengthFilter()) < 600 then
				self:settext(SecondsToMSS(GetUpperLengthFilter()))
			elseif tonumber(GetUpperLengthFilter()) >= 600 and tonumber(GetUpperLengthFilter()) < 3600 then
				self:settext(SecondsToMMSS(GetUpperLengthFilter()))
			elseif tonumber(GetUpperLengthFilter()) == 3600 then
				self:settext("1:00:00")
			end
		end,
		
		UpdateUpperLengthCommand=function(self)
			if tonumber(CurrentUpperLength) == 0 then
				self:settext("none")
			elseif tonumber(CurrentUpperLength) < 600 then
				self:settext(SecondsToMSS(CurrentUpperLength))
			elseif tonumber(CurrentUpperLength) >= 600 and tonumber(CurrentUpperLength) < 3600 then
				self:settext(SecondsToMMSS(CurrentUpperLength))
			elseif tonumber(CurrentUpperLength) == 3600 then
				self:settext("1:00:00")
			end
		end,
		
		},
}

return t