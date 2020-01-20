local args = ...
local GroupWheel = args.GroupWheel
local SongWheel = args.SongWheel
local OptionsWheel = args.OptionsWheel
local OptionRows = args.OptionRows

-- initialize Players to be any HumanPlayers at screen init
-- we'll update this later via latejoin if needed
local Players = GAMESTATE:GetHumanPlayers()

local ActiveOptionRow = 1

-----------------------------------------------------
-- input handler
local Handler = {}

Handler['OptionsWheel'] = {}
-----------------------------------------------------

local SwitchInputFocus = function(button, params)

	if button == "Start" then

		if Handler.WheelWithFocus == GroupWheel then
			Handler.WheelWithFocus = SongWheel
			SL.Global.GroupToSong = true
		elseif Handler.WheelWithFocus == SongWheel then
			Handler.WheelWithFocus = OptionsWheel
			MESSAGEMAN:Broadcast("SetOptionPanes")
			for pn in ivalues(Players) do
				Handler.WheelWithFocus[pn].container:GetChild("item"..#OptionRows):GetChild("Cursor"):playcommand("ExitRow", {PlayerNumber=pn})
				MESSAGEMAN:Broadcast("ShowPlayerOptionsPane"..SL.Global['ActivePlayerOptionsPane'..PlayerNumber:Reverse()[pn]]+1, {PlayerNumber=pn})
			end
		end

	elseif button == "Select" or button == "Back" then

		if Handler.WheelWithFocus == SongWheel then
			Handler.WheelWithFocus = GroupWheel

		elseif Handler.WheelWithFocus == OptionsWheel then
			Handler.WheelWithFocus = SongWheel
		end

	end
end

-- determine whether all human players are done selecting song options
-- and have their cursors at the glowing green START button
Handler.AllPlayersAreAtLastRow = function()
	for player in ivalues(Players) do
		if ActiveOptionRow[player] ~= #OptionRows then
			return false
		end
	end
	return true
end

-- calls needed to close the current group folder and return to choosing a group
local CloseCurrentFolder = function()
	-- if focus is already on the GroupWheel, we don't need to do anything more
	if Handler.WheelWithFocus == GroupWheel then return end

	-- otherwise...
	t.Enabled = false
	Handler.WheelWithFocus.container:queuecommand("Hide")
	Handler.WheelWithFocus = GroupWheel
	Handler.WheelWithFocus.container:queuecommand("Unhide")
end

local UnhideOptionRows = function(pn)
	-- unhide optionrows for this player
	Handler.WheelWithFocus[pn].container:queuecommand("Unhide")

	-- unhide optionrowitems for this player
	for i=1,#OptionRows do
		Handler.WheelWithFocus[pn][i].container:queuecommand("Unhide")
	end
end

Handler.AllowLateJoin = function()
	if GAMESTATE:GetCurrentStyle():GetName() ~= "single" then return false end
	if PREFSMAN:GetPreference("EventMode") then return true end
	if GAMESTATE:GetCoinMode() ~= "CoinMode_Pay" then return true end
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay" and PREFSMAN:GetPreference("Premium") == "Premium_2PlayersFor1Credit" then return true end
	return false
end

-- See if the current song has a chart for a given difficulty
-- If no difficulty is given it uses the last seen difficulty
DifficultyExists = function(player, validate, difficulty)
	local pn = player or GAMESTATE:GetMasterPlayerNumber()
	local validate = validate or false
	local song = GAMESTATE:GetCurrentSong()
	local diff = difficulty or args['DifficultyIndex'..PlayerNumber:Reverse()[pn]] --use DifficultyIndex from params_for_input if no difficulty is supplied
	if song then 
		if validate then if song:GetOneSteps(GetStepsType(),diff) and ValidateChart(song,song:GetOneSteps(GetStepsType(),diff)) then 
			return true end
		elseif song:GetOneSteps(GetStepsType(),diff) then 
			return true
		else return false end
	end
end

-- Looks for the next easiest difficulty. Returns nil if none can be found
-- If validate is true then it checks that the chart also passes all filters 
-- (used to automatically select a valid chart when switching songs if filters are enabled)
NextEasiest = function(player, validate, difficulty)
	local pn = player
	local validate = validate or false
	local song = GAMESTATE:GetCurrentSong()
	local diff = difficulty or args['DifficultyIndex'..PlayerNumber:Reverse()[pn]] --use DifficultyIndex from params_for_input if no difficulty is supplied
	diff = diff - 1 --the current difficulty will always be there so we want to start from the next lowest
	if song then
	local t = {}
		for i=diff,0,-1 do
			if validate then if song:GetOneSteps(GetStepsType(),i) and ValidateChart(song,song:GetOneSteps(GetStepsType(),i)) then 
				return song:GetOneSteps(GetStepsType(),i) end
			elseif song:GetOneSteps(GetStepsType(),i) then 
				return song:GetOneSteps(GetStepsType(),i) 
			end
		end
		return nil
	end
end

-- Looks for the next hardest difficulty. Returns nil if none can be found
-- If validate is true then it checks that the chart also passes all filters 
-- (used to automatically select a valid chart when switching songs if filters are enabled)
NextHardest = function(player, validate, difficulty)
	local pn = player
	local validate = validate or false
	local song = GAMESTATE:GetCurrentSong()
	local diff = difficulty or args['DifficultyIndex'..PlayerNumber:Reverse()[pn]] --use DifficultyIndex from params_for_input if no difficulty is supplied
	diff = diff + 1 --the current difficulty will always be there so we want to start from the next highest
	if song then
		for i=diff,5 do
			if validate then if song:GetOneSteps(GetStepsType(),i) and ValidateChart(song,song:GetOneSteps(GetStepsType(),i)) then 
				return song:GetOneSteps(GetStepsType(),i) end
			elseif song:GetOneSteps(GetStepsType(),i) then 
				return song:GetOneSteps(GetStepsType(),i) 
			end
		end
		return nil
	end
end

Handler.ResetHeldButtons = function()
	HeldButtons["MenuLeft"] = false
	HeldButtons["MenuRight"] = false
	HeldButtons["MenuUp"] = false
	HeldButtons["MenuDown"] = false
end
-----------------------------------------------------
-- start internal functions

Handler.Init = function()
	-- flag used to determine whether input is permitted
	-- false at initialization
	Handler.Enabled = false

	-- initialize which wheel gets focus to start based on whether or not
	-- GAMESTATE has a CurrentSong (it always should at screen init)
	Handler.WheelWithFocus = GAMESTATE:GetCurrentSong() and SongWheel or GroupWheel
	
	-- table that stores P1 and P2's currently active optionrow
	ActiveOptionRow = {
		[PLAYER_1] = #OptionRows,
		[PLAYER_2] = #OptionRows
	}
	
	Handler.CancelSongChoice = function()
		Handler.Enabled = false
		for pn in ivalues(Players) do

			-- reset the ActiveOptionRow for this player
			ActiveOptionRow[pn] = #OptionRows
			-- hide this player's OptionsWheel
			Handler.WheelWithFocus[pn].container:playcommand("Hide")
			-- hide this player's OptionRows
			for i=1,#OptionRows do
				Handler.WheelWithFocus[pn][i].container:queuecommand("Hide")
			end
			-- ensure that this player's OptionsWheel understands it has been reset
			Handler.WheelWithFocus[pn]:scroll_to_pos(#OptionRows)
		end
		MESSAGEMAN:Broadcast("SingleSongCanceled")
		Handler.WheelWithFocus = SongWheel
		Handler.WheelWithFocus.container:queuecommand("Unhide")
	end
	
	-- table that stores what buttons are held down to look for multi-button input
	HeldButtons = {
		["MenuLeft"] = false,
		["MenuRight"] = false,
		["MenuUp"] = false,
		["MenuDown"] = false
	}
end

-----------------------------------------------------------------------------------------------
-- Input on SongWheel and GroupWheel
-----------------------------------------------------------------------------------------------

Handler.MenuRight=function(event)
	-- Scroll right with MenuRight
	Handler.WheelWithFocus:scroll_by_amount(1)
	if HeldButtons["MenuLeft"] == true then --left and right are held at the same time so open the sort menu
		MESSAGEMAN:Broadcast("DirectInputToSortMenu")
		Handler.Enabled = false
		Handler.ResetHeldButtons()
	else --navigate the wheel right
		SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
	end
	return false
end

Handler.MenuLeft=function(event)
	Handler.WheelWithFocus:scroll_by_amount(-1)
	if HeldButtons["MenuRight"] == true then --left and right are held at the same time so open the sort menu
		MESSAGEMAN:Broadcast("DirectInputToSortMenu")
		Handler.Enabled = false
		Handler.ResetHeldButtons()
	else -- navigate the wheel left
		SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
	end
	return false
end

Handler.MenuUp=function(event)
-- change difficulty with MenuUp
	local song = GAMESTATE:GetCurrentSong() -- don't do anything if we're on Close This Folder
	-- don't do anything if there's no easier difficulty or we're not on the songwheel or we're on Close This Folder
	if Handler.WheelWithFocus==SongWheel and song and NextEasiest(event.PlayerNumber) then
		SOUND:PlayOnce( THEME:GetPathS("ScreenSelectMusic", "difficulty easier.redir") )
		GAMESTATE:SetCurrentSteps( event.PlayerNumber, NextEasiest(event.PlayerNumber) )
		args['DifficultyIndex'..PlayerNumber:Reverse()[event.PlayerNumber]] = Difficulty:Reverse()[GAMESTATE:GetCurrentSteps(event.PlayerNumber):GetDifficulty()]
		-- if we change the difficulty we want to update things like grades we show on the music wheel and
		-- the song information in \PerPlayer\PaneDisplay. These are controlled by StepsHaveChangedMessageCommand which
		-- SongMT broadcasts. We can indirectly call it by using scroll_by_amount(0) which will go nowhere 
		-- but still call transform and therefore StepsHaveChangedMessageCommand
		Handler.WheelWithFocus:scroll_by_amount(0)
	end
	return false
end

Handler.MenuDown=function(event)
--change difficulty with down	
--TODO doesn't work well with edits
	local song = GAMESTATE:GetCurrentSong() 
	-- do nothing if there's no harder difficulty or we're not on the songwheel or we're on Close This Folder
	if Handler.WheelWithFocus==SongWheel and song and NextHardest(event.PlayerNumber) then
		SOUND:PlayOnce( THEME:GetPathS("ScreenSelectMusic", "difficulty harder.redir") )
		GAMESTATE:SetCurrentSteps( event.PlayerNumber, NextHardest(event.PlayerNumber) )
		args['DifficultyIndex'..PlayerNumber:Reverse()[event.PlayerNumber]] = Difficulty:Reverse()[GAMESTATE:GetCurrentSteps(event.PlayerNumber):GetDifficulty()]
		-- if we change the difficulty we want to update things like grades we show on the music wheel and
		-- the song information in \PerPlayer\PaneDisplay. These are controlled by StepsHaveChangedMessageCommand which
		-- SongMT broadcasts. We can indirectly call it by using scroll_by_amount(0) which will go nowhere 
		-- but still call transform and therefore StepsHaveChangedMessageCommand
		Handler.WheelWithFocus:scroll_by_amount(0)
	end
	return false
end

Handler.Start=function(event)
	-- proceed to the next wheel
	if Handler.WheelWithFocus == SongWheel and Handler.WheelWithFocus:get_info_at_focus_pos().song == "CloseThisFolder" then
		SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
		CloseCurrentFolder()
		return false
	end
	Handler.Enabled = false
	Handler.WheelWithFocus.container:queuecommand("Start")
	SwitchInputFocus(event.GameButton,{PlayerNumber=event.PlayerNumber})
	if Handler.WheelWithFocus.container then --going from group to song
		SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
		Handler.WheelWithFocus.container:queuecommand("Unhide")
	else --going from song to options
		SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
		for pn in ivalues(Players) do
			UnhideOptionRows(pn)
		end
	end
	return false
end

Handler.Select=function(event)
-- back out of the current wheel to the previous wheel if we're on the songwheel. if we're on the groupwheel then back out to main menu
	if Handler.WheelWithFocus == SongWheel then 
		CloseCurrentFolder() 
		SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
	elseif event.GameButton == "Back" then
		SCREENMAN:GetTopScreen():SetNextScreenName( Branch.SSMCancel() ):StartTransitioningScreen("SM_GoToNextScreen") 
	end
	return false
end
Handler.Back = Handler.Select

-----------------------------------------------------------------------------------------------
-- Input on OptionsWheel
-----------------------------------------------------------------------------------------------

Handler['OptionsWheel'].MenuRight = function(event)
	if not args.EnteringSong then
		-- get the index of the active optionrow for this player
		local index = ActiveOptionRow[event.PlayerNumber]
		if index ~= #OptionRows then
			SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			-- The OptionRowItem for changing display doesn't do anything. So we broadcast a message with which pane to display.
			-- Then we increment the wheel normally so the option displays what pane we're looking at. Can't use the save/load
			-- thing because that only saves when you go to start instead of with every change. Maybe look in to this. 
			-- Probably not a good idea to assume this will be in row 2 all the time. TODO
			if ActiveOptionRow[event.PlayerNumber] == 2 then
				MESSAGEMAN:Broadcast("HidePlayerOptionsPane"..SL.Global['ActivePlayerOptionsPane'..PlayerNumber:Reverse()[event.PlayerNumber]]+1,{PlayerNumber=event.PlayerNumber})
				SL.Global['ActivePlayerOptionsPane'..PlayerNumber:Reverse()[event.PlayerNumber]] = (SL.Global['ActivePlayerOptionsPane'..PlayerNumber:Reverse()[event.PlayerNumber]] + 1) % 3
				MESSAGEMAN:Broadcast("ShowPlayerOptionsPane"..SL.Global['ActivePlayerOptionsPane'..PlayerNumber:Reverse()[event.PlayerNumber]]+1,{PlayerNumber=event.PlayerNumber})
			end
			-- scroll to the next optionrow_item in this optionrow
			Handler.WheelWithFocus[event.PlayerNumber][index]:scroll_by_amount(1)
			-- animate the right cursor
			Handler.WheelWithFocus[event.PlayerNumber].container:GetChild("item"..index):GetChild("Cursor"):GetChild("RightArrow"):finishtweening():playcommand("Press")
		end
	end
	return false
end
		
Handler['OptionsWheel'].MenuLeft = function(event)
	if not args.EnteringSong then
		local index = ActiveOptionRow[event.PlayerNumber]
		if index ~= #OptionRows then
			SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			if ActiveOptionRow[event.PlayerNumber] == 2 then
				MESSAGEMAN:Broadcast("HidePlayerOptionsPane"..SL.Global['ActivePlayerOptionsPane'..PlayerNumber:Reverse()[event.PlayerNumber]]+1,{PlayerNumber=event.PlayerNumber})
				SL.Global['ActivePlayerOptionsPane'..PlayerNumber:Reverse()[event.PlayerNumber]] = (SL.Global['ActivePlayerOptionsPane'..PlayerNumber:Reverse()[event.PlayerNumber]] - 1) % 3
				MESSAGEMAN:Broadcast("ShowPlayerOptionsPane"..SL.Global['ActivePlayerOptionsPane'..PlayerNumber:Reverse()[event.PlayerNumber]]+1,{PlayerNumber=event.PlayerNumber})
			end
			-- scroll to the previous optionrow_item in this optionrow
			Handler.WheelWithFocus[event.PlayerNumber][index]:scroll_by_amount(-1)
			-- animate the left cursor
			Handler.WheelWithFocus[event.PlayerNumber].container:GetChild("item"..index):GetChild("Cursor"):GetChild("LeftArrow"):finishtweening():playcommand("Press")
		end
	end
	return false
end

Handler['OptionsWheel'].MenuUp = function(event)		
	if not args.EnteringSong then
		if ActiveOptionRow[event.PlayerNumber] > 1 then
			local index = ActiveOptionRow[event.PlayerNumber]
			-- set the currently active option row, bounding it to not go below 1
			ActiveOptionRow[event.PlayerNumber] = math.max(index-1, 1)
			-- scroll up to previous optionrow for this player
			Handler.WheelWithFocus[event.PlayerNumber]:scroll_by_amount( -1 )
			MESSAGEMAN:Broadcast("CancelBothPlayersAreReady")
		end
	end
	return false
end

Handler['OptionsWheel'].MenuDown = function(event)
	if not args.EnteringSong then
		local index = ActiveOptionRow[event.PlayerNumber]
		-- we want to proceed linearly to the last optionrow and then stop there
		if ActiveOptionRow[event.PlayerNumber] < #OptionRows then
			local index = ActiveOptionRow[event.PlayerNumber]
			local choice = Handler.WheelWithFocus[event.PlayerNumber][index]:get_info_at_focus_pos()
			local choices= OptionRows[index]:Choices()
			local values = OptionRows[index].Values()

			OptionRows[index]:OnSave(event.PlayerNumber, choice, choices, values)

			Handler.WheelWithFocus[event.PlayerNumber]:scroll_by_amount(1)
		end

		-- update the index, bounding it to not exceed the number of rows
		index = math.min(index+1, #OptionRows)

		-- set the currently active option row to the updated index
		ActiveOptionRow[event.PlayerNumber] = index

		-- if all available players are now at the final row (start icon), animate cursors spinning
		if Handler.AllPlayersAreAtLastRow() then
			MESSAGEMAN:Broadcast("BothPlayersAreReady")
		end
	end
	return false
end

Handler['OptionsWheel'].Start = function(event)
	local index = ActiveOptionRow[event.PlayerNumber]
	-- if both players are ALREADY here (before changing the row)
	-- it means it's time to start gameplay
	if event.GameButton == "Start" and Handler.AllPlayersAreAtLastRow() then
		SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
		local topscreen = SCREENMAN:GetTopScreen()
		if topscreen then
			--ScreenTransition goes on for two seconds. If we get another Start in that time they want to go to options
			if args.EnteringSong == false then
				MESSAGEMAN:Broadcast("ScreenTransition")
			else
				MESSAGEMAN:Broadcast("GoToOptions")
			end
		end
		return false
	else Handler['OptionsWheel'].MenuDown(event) end --if we're not entering a song then Start does the same thing as Down
	return false
end

Handler['OptionsWheel'].Select = function(event)	
	if args.EnteringSong == false then
			SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "sort.ogg") )
			Handler.CancelSongChoice()
	end
	return false
end
Handler['OptionsWheel'].Back = Handler['OptionsWheel'].Select

Handler.Handler = function(event)
	if Handler.Enabled == false or not event or not event.PlayerNumber or not event.button then return false end
	if not GAMESTATE:IsSideJoined(event.PlayerNumber) then
		if not Handler.AllowLateJoin() then return false end
		-- latejoin
		if event.GameButton == "Start" then
			GAMESTATE:JoinPlayer( event.PlayerNumber )
			Players = GAMESTATE:GetHumanPlayers()
			if Handler.WheelWithFocus == OptionsWheel then
				UnhideOptionRows(event.PlayerNumber)
				MESSAGEMAN:Broadcast("SwitchFocusToSingleSong")
			end
			MESSAGEMAN:Broadcast("PlayerJoined",{player=event.PlayerNumber})
		end
		return false
	end
	if event.type == "InputEventType_Release" then
		HeldButtons[event.GameButton] = false
		return false
	else
		HeldButtons[event.GameButton] = true
		if Handler[event.GameButton] then 
			if Handler.WheelWithFocus ~= OptionsWheel then Handler[event.GameButton](event) 
			else Handler['OptionsWheel'][event.GameButton](event) end
		end
	end
	return false
end

return Handler