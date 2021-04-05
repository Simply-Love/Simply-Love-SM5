local player = ...
local args = ...
local GroupWheel = args.GroupWheel
local SongWheel = args.SongWheel
local DDStats = LoadActor('./DDStats.lua')
local nsj = GAMESTATE:GetNumSidesJoined()

local ChartUpdater = LoadActor("./UpdateChart.lua")

-- initialize Players to be any HumanPlayers at screen init
-- we'll update this later via latejoin if needed
local Players = GAMESTATE:GetHumanPlayers()

local ActiveOptionRow

local didSelectSong = false
isSortMenuVisible = false

-----------------------------------------------------
-- input handler
local t = {}
-----------------------------------------------------

local function GetLastStyle()
	local value
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		value = DDStats.GetStat(PLAYER_1, 'LastStyle')
	else
		value = DDStats.GetStat(PLAYER_2, 'LastStyle')
	end

	if value == nil then
		value = "Single"
	end

	return value
end


local function SetLastStyle(value)
	for i,playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
		DDStats.SetStat(playerNum, 'LastStyle', value)
		DDStats.Save(playerNum)
	end
end


local SwitchInputFocus = function(button)
	if button == "Start" then

		if t.WheelWithFocus == GroupWheel then
			t.WheelWithFocus = SongWheel

		elseif t.WheelWithFocus == SongWheel then
			didSelectSong = true
			SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
			MESSAGEMAN:Broadcast('ShowOptionsJawn')
		end
	elseif button == "Select" or button == "Back" then
		if t.WheelWithFocus == SongWheel then
			t.WheelWithFocus = GroupWheel
		end

	end
end

-- calls needed to close the current group folder and return to choosing a group
local CloseCurrentFolder = function()
	-- if focus is already on the GroupWheel, we don't need to do anything more
	if t.WheelWithFocus == GroupWheel then 
	NameOfGroup = GAMESTATE:GetCurrentSong():GetGroupName()
	return end

	-- otherwise...
	t.Enabled = false
	MESSAGEMAN:Broadcast("SwitchFocusToGroups")
	t.WheelWithFocus.container:queuecommand("Hide")
	t.WheelWithFocus = GroupWheel
	t.WheelWithFocus.container:queuecommand("Unhide")
end

t.AllowLateJoin = function()
	if GAMESTATE:GetCurrentStyle():GetName() ~= "single" then return false end
	if PREFSMAN:GetPreference("EventMode") then return true end
	if GAMESTATE:GetCoinMode() ~= "CoinMode_Pay" then return true end
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay" and PREFSMAN:GetPreference("Premium") == "Premium_2PlayersFor1Credit" then return true end
	return false
end

-----------------------------------------------------
-- start internal functions

t.Init = function()
	-- flag used to determine whether input is permitted
	-- false at initialization
	t.Enabled = false
	-- initialize which wheel gets focus to start based on whether or not
	-- GAMESTATE has a CurrentSong (it always should at screen init)
	t.WheelWithFocus = GAMESTATE:GetCurrentSong() and SongWheel or GroupWheel
	
end

local lastMenuUpPressTime = 0
local lastMenuDownPressTime = 0

t.Handler = function(event)
	-- if any of these, don't attempt to handle input
	if t.Enabled == false or not event or not event.PlayerNumber or not event.button then
		return false
	end
	
	if isSortMenuVisible == false then
		if event.type ~= "InputEventType_Release" then
			if event.GameButton == "Select" then
				MESSAGEMAN:Broadcast("InitializeDDSortMenu")
				if GAMESTATE:GetCurrentSong() ~= nil then
					DDStats.SetStat(PLAYER_1, 'LastSong', GAMESTATE:GetCurrentSong():GetSongDir())
				end
			end
		end
	end
	
	
	if isSortMenuVisible then
		if event.type ~= "InputEventType_Release" then
			if GAMESTATE:IsSideJoined(event.PlayerNumber) then
				if event.GameButton == "Select" or event.GameButton == "Back" then
					if IsSortMenuInputToggled == false then
						if SortMenuNeedsUpdating == true then
							SortMenuNeedsUpdating = false
							MESSAGEMAN:Broadcast("ToggleSortMenu")
							MESSAGEMAN:Broadcast("ReloadSSMDD")
							isSortMenuVisible = false
							
						elseif SortMenuNeedsUpdating == false then
							isSortMenuVisible = false
							SOUND:PlayOnce( THEME:GetPathS("ScreenPlayerOptions", "cancel all.ogg") )
							MESSAGEMAN:Broadcast("ToggleSortMenu")
						end
					else end
				end
				if event.GameButton == "Start" then
					if DDSortMenuCursorPosition == 9 then
						SortMenuNeedsUpdating = true
					end	
					if DDSortMenuCursorPosition == 10 then
						SortMenuNeedsUpdating = true
					end	
					if DDSortMenuCursorPosition == 13 then
						local current_style = GAMESTATE:GetCurrentStyle():GetStyleType()
						if current_style == "StyleType_OnePlayerOneSide" then
							SetLastStyle("Double")
							GAMESTATE:SetCurrentStyle("Double")
						else
							SetLastStyle("Single")
							GAMESTATE:SetCurrentStyle("Single")
						end
						MESSAGEMAN:Broadcast("ReloadSSMDD")
					end
				end
				
				if event.GameButton == "MenuLeft" or event.GameButton == "MenuUp" then
					MESSAGEMAN:Broadcast("MoveCursorLeft")
					SOUND:PlayOnce( THEME:GetPathS("", "_prev row.ogg") )
					
				end
				
				if event.GameButton == "MenuRight" or event.GameButton == "MenuDown" then
					MESSAGEMAN:Broadcast("MoveCursorRight")
					SOUND:PlayOnce( THEME:GetPathS("", "_next row.ogg") )
				end
				
				if IsSortMenuInputToggled == true then
					if event.GameButton == "Start" then
						MESSAGEMAN:Broadcast("SetSortMenuTopStats")
					end
				end
						if IsSortMenuInputToggled == true then
							if event.GameButton == "Start" then
								MESSAGEMAN:Broadcast("SortMenuOptionSelected")
								SOUND:PlayOnce( THEME:GetPathS("common", "start.ogg") )
							end
						elseif event.GameButton == "Start" then
							MESSAGEMAN:Broadcast("SortMenuOptionSelected")
							SOUND:PlayOnce( THEME:GetPathS("common", "start.ogg") )
						end
				
				---- This stops the cursor from moving when selecting a variable option
				---- Like filtering bpms/difficulties/etc
				if IsSortMenuInputToggled == true then
					if event.GameButton == "MenuLeft" or event.GameButton == "MenuUp" then
						MESSAGEMAN:Broadcast("MoveSortMenuOptionLeft")
					elseif event.GameButton == "MenuRight" or event.GameButton == "MenuDown"then
						MESSAGEMAN:Broadcast("MoveSortMenuOptionRight")
					elseif event.GameButton == "Select" or event.GameButton == "Back" then
						SOUND:PlayOnce( THEME:GetPathS("common", "invalid.ogg") )
						MESSAGEMAN:Broadcast("ToggleSortMenuMovement")
					end
				end
			else end
		end
		
		return false
	end


	if not GAMESTATE:IsSideJoined(event.PlayerNumber) then
		if not t.AllowLateJoin() then return false end

		-- latejoin
		if event.GameButton == "Start" then
			GAMESTATE:JoinPlayer( event.PlayerNumber )
			Players = GAMESTATE:GetHumanPlayers()
		end
		return false
	end

	if event.type ~= "InputEventType_Release" then

		if event.GameButton == "Back" then
			if didSelectSong then
				didSelectSong = false
				MESSAGEMAN:Broadcast('HideOptionsJawn')
				return false
			end
		
			SCREENMAN:GetTopScreen():SetNextScreenName( Branch.SSMCancel() ):StartTransitioningScreen("SM_GoToNextScreen")
		end
		--------------------------------------------------------------
		
		if event.GameButton == "Select" then
			if nsj ~= 2 then
				isSortMenuVisible = true
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "sort.ogg") )
				stop_music()
				MESSAGEMAN:Broadcast("ToggleSortMenu")
			else end
		end
		UpdateGroupWheelMessageCommand = function(self)
			t.WheelWithFocus:scroll_by_amount(1)
			SCREENMAN:SystemMessage("hello")
		end
		--------------------------------------------------------------
		-- proceed to the next wheel
		if event.GameButton == "Start" then
			if didSelectSong then
				SCREENMAN:SetNewScreen("ScreenPlayerOptions")
				return false
			end

			if t.WheelWithFocus:get_info_at_focus_pos() == "CloseThisFolder" then
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
				CloseCurrentFolder()
				return false
			end

			if t.WheelWithFocus == GroupWheel then
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
			end

			t.WheelWithFocus.container:queuecommand("Start")
			SwitchInputFocus(event.GameButton)

			if t.WheelWithFocus.container then
				t.WheelWithFocus.container:queuecommand("Unhide")
			end
		elseif didSelectSong then
			return false
		-- navigate the wheel left and right
		elseif event.GameButton == "MenuRight" then
			t.WheelWithFocus:scroll_by_amount(1)
			SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )

			ChartUpdater.UpdateCharts()
		elseif event.GameButton == "MenuLeft" then
			t.WheelWithFocus:scroll_by_amount(-1)
			SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )

			ChartUpdater.UpdateCharts()
		elseif event.GameButton == "MenuUp" then
			local t = GetTimeSinceStart()
			local dt = t - lastMenuUpPressTime
			lastMenuUpPressTime = t
			if dt < 0.5 then
				SOUND:PlayOnce( THEME:GetPathS("", "_easier.ogg") )
				ChartUpdater.DecreaseDifficulty(event.PlayerNumber)
				lastMenuUpPressTime = 0
			end
		elseif event.GameButton == "MenuDown" then
			local t = GetTimeSinceStart()
			local dt = t - lastMenuDownPressTime
			lastMenuDownPressTime = t
			if dt < 0.5 then
				SOUND:PlayOnce( THEME:GetPathS("", "_harder.ogg") )
				ChartUpdater.IncreaseDifficulty(event.PlayerNumber)
				lastMenuDownPressTime = 0
			end
		end
	end


	return false
end

return t