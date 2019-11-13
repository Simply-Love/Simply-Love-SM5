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
local t = {}
-----------------------------------------------------

local SwitchInputFocus = function(button, params)

	if button == "Start" then

		if t.WheelWithFocus == GroupWheel then
			t.WheelWithFocus = SongWheel
			SL.Global.GroupToSong = true
		elseif t.WheelWithFocus == SongWheel then
			t.WheelWithFocus = OptionsWheel
			MESSAGEMAN:Broadcast("SetOptionPanes")
			MESSAGEMAN:Broadcast("ShowPlayerOptionsPane"..SL.Global.ActivePlayerOptionsPane+1)
			t.WheelWithFocus[params.PlayerNumber].container:GetChild("item"..#OptionRows):GetChild("Cursor"):playcommand("ExitRow", {PlayerNumber=params.PlayerNumber})
		end

	elseif button == "Select" or button == "Back" then

		if t.WheelWithFocus == SongWheel then
			t.WheelWithFocus = GroupWheel

		elseif t.WheelWithFocus == OptionsWheel then
			t.WheelWithFocus = SongWheel
		end

	end
end

-- determine whether all human players are done selecting song options
-- and have their cursors at the glowing green START button
t.AllPlayersAreAtLastRow = function()
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
	if t.WheelWithFocus == GroupWheel then return end

	-- otherwise...
	t.Enabled = false
	t.WheelWithFocus.container:queuecommand("Hide")
	t.WheelWithFocus = GroupWheel
	t.WheelWithFocus.container:queuecommand("Unhide")
end

local UnhideOptionRows = function(pn)
	-- unhide optionrows for this player
	t.WheelWithFocus[pn].container:queuecommand("Unhide")

	-- unhide optionrowitems for this player
	for i=1,#OptionRows do
		t.WheelWithFocus[pn][i].container:queuecommand("Unhide")
	end
end

--TODO for now no late joining. single player only.
t.AllowLateJoin = function()
	if true then return false end
	if GAMESTATE:GetCurrentStyle():GetName() ~= "single" then return false end
	if PREFSMAN:GetPreference("EventMode") then return true end
	if GAMESTATE:GetCoinMode() ~= "CoinMode_Pay" then return true end
	if GAMESTATE:GetCoinMode() == "CoinMode_Pay" and PREFSMAN:GetPreference("Premium") == "Premium_2PlayersFor1Credit" then return true end
	return false
end

t.DifficultyExists = function(difficulty)
	local song = GAMESTATE:GetCurrentSong()
	local diff = difficulty or args.DifficultyIndex --use DifficultyIndex from params_for_input if no difficulty is supplied
	if song then 
		if song:GetOneSteps(GetStepsType(),diff) then return true
		else return false end
	end
end

t.NextEasiest = function(difficulty)
	local song = GAMESTATE:GetCurrentSong()
	local diff = difficulty or args.DifficultyIndex --use DifficultyIndex from params_for_input if no difficulty is supplied
	diff = diff - 1 --the current difficulty will always be there so we want to start from the next lowest
	if song then
	local t = {}
		for i=diff,0,-1 do
			if song:GetOneSteps(GetStepsType(),i) then return song:GetOneSteps(GetStepsType(),i) end
		end
		return nil
	end
end

t.NextHardest = function(difficulty)
	local song = GAMESTATE:GetCurrentSong()
	local diff = difficulty or args.DifficultyIndex --use DifficultyIndex from params_for_input if no difficulty is supplied
	diff = diff + 1 --the current difficulty will always be there so we want to start from the next highest
	if song then
		for i=diff,5 do
			if song:GetOneSteps(GetStepsType(),i) then return song:GetOneSteps(GetStepsType(),i) end
		end
		return nil
	end
end

t.ResetHeldButtons = function()
	HeldButtons["MenuLeft"] = false
	HeldButtons["MenuRight"] = false
	HeldButtons["MenuUp"] = false
	HeldButtons["MenuDown"] = false
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
	-- table that stores P1 and P2's currently active optionrow
	ActiveOptionRow = {
		[PLAYER_1] = #OptionRows,
		[PLAYER_2] = #OptionRows
	}
	
	t.CancelSongChoice = function()
		t.Enabled = false
		for pn in ivalues(Players) do

			-- reset the ActiveOptionRow for this player
			ActiveOptionRow[pn] = #OptionRows
			-- hide this player's OptionsWheel
			t.WheelWithFocus[pn].container:playcommand("Hide")
			-- hide this player's OptionRows
			for i=1,#OptionRows do
				t.WheelWithFocus[pn][i].container:queuecommand("Hide")
			end
			-- ensure that this player's OptionsWheel understands it has been reset
			t.WheelWithFocus[pn]:scroll_to_pos(#OptionRows)
		end
		MESSAGEMAN:Broadcast("SingleSongCanceled")
		t.WheelWithFocus = SongWheel
		t.WheelWithFocus.container:queuecommand("Unhide")
	end
	
	-- table that stores what buttons are held down to look for multi-button input
	HeldButtons = {
		["MenuLeft"] = false,
		["MenuRight"] = false,
		["MenuUp"] = false,
		["MenuDown"] = false
	}
end

t.Handler = function(event)
	-- if any of these, don't attempt to handle input
	if t.Enabled == false or not event or not event.PlayerNumber or not event.button then
		return false
	end

	if not GAMESTATE:IsSideJoined(event.PlayerNumber) then
		if not t.AllowLateJoin() then return false end

		-- latejoin
		if t.WheelWithFocus == OptionsWheel and event.GameButton == "Start" then
			GAMESTATE:JoinPlayer( event.PlayerNumber )
			Players = GAMESTATE:GetHumanPlayers()
			UnhideOptionRows(event.PlayerNumber)
		end
		return false
	end
	if event.type == "InputEventType_Release" then
		HeldButtons[event.GameButton] = false
	else
		HeldButtons[event.GameButton] = true
		--------------------------------------------------------------
		--------------------------------------------------------------
		-- handle wheel input (not on options wheel)
		if t.WheelWithFocus ~= OptionsWheel then
			-- Scroll right with MenuRight
			if event.GameButton == "MenuRight" then
				t.WheelWithFocus:scroll_by_amount(1)
				if HeldButtons["MenuLeft"] == true then --left and right are held at the same time so open the sort menu
					MESSAGEMAN:Broadcast("DirectInputToSortMenu")
					t.ResetHeldButtons()
					return false
				else --navigate the wheel right
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
					-- This currently does nothing because the arrows in SongWheelShared are disabled
					--if t.WheelWithFocus==SongWheel then
					--	SCREENMAN:GetTopScreen():GetChild("Overlay"):GetChild("SongWheelShared"):GetChild("Arrows"):GetChild("RightArrow"):finishtweening():playcommand("Press")
					--end
				end
			-- Scroll left with MenuLeft
			elseif event.GameButton == "MenuLeft" then
				t.WheelWithFocus:scroll_by_amount(-1)
				if HeldButtons["MenuRight"] == true then --left and right are held at the same time so open the sort menu
					MESSAGEMAN:Broadcast("DirectInputToSortMenu")
					t.ResetHeldButtons()
					return false
				else -- navigate the wheel left
	
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
					-- This currently does nothing because the arrows in SongWheelShared are disabled
					--if t.WheelWithFocus==SongWheel then
					--	SCREENMAN:GetTopScreen():GetChild("Overlay"):GetChild("SongWheelShared"):GetChild("Arrows"):GetChild("LeftArrow"):finishtweening():playcommand("Press")
					--end
				end
			-- change difficulty with MenuUp
			elseif event.GameButton == "MenuUp" then
				local song = GAMESTATE:GetCurrentSong() -- don't do anything if we're on Close This Folder
				-- don't do anything if there's no easier difficulty or we're not on the songwheel or we're on Close This Folder
				if t.WheelWithFocus==SongWheel and song and t.NextEasiest() then
					SOUND:PlayOnce( THEME:GetPathS("ScreenSelectMusic", "difficulty easier.redir") )
					GAMESTATE:SetCurrentSteps( 0, t.NextEasiest() )
					args.DifficultyIndex = Difficulty:Reverse()[GAMESTATE:GetCurrentSteps(0):GetDifficulty()]
					-- if we change the difficulty we want to update things like grades we show on the music wheel and
					-- the song information in \PerPlayer\PaneDisplay. These are controlled by StepsHaveChangedMessageCommand which
					-- SongMT broadcasts. We can indirectly call it by using scroll_by_amount(0) which will go nowhere 
					-- but still call transform and therefore StepsHaveChangedMessageCommand
					t.WheelWithFocus:scroll_by_amount(0)
				end
			--change difficulty with down	
			elseif event.GameButton == "MenuDown" then
				local song = GAMESTATE:GetCurrentSong() --TODO doesn't work well with edits
				-- do nothing if there's no harder difficulty or we're not on the songwheel or we're on Close This Folder
				if t.WheelWithFocus==SongWheel and song and t.NextHardest() then
					SOUND:PlayOnce( THEME:GetPathS("ScreenSelectMusic", "difficulty harder.redir") )
					GAMESTATE:SetCurrentSteps( 0, t.NextHardest() )
					args.DifficultyIndex = Difficulty:Reverse()[GAMESTATE:GetCurrentSteps(0):GetDifficulty()]
					-- if we change the difficulty we want to update things like grades we show on the music wheel and
					-- the song information in \PerPlayer\PaneDisplay. These are controlled by StepsHaveChangedMessageCommand which
					-- SongMT broadcasts. We can indirectly call it by using scroll_by_amount(0) which will go nowhere 
					-- but still call transform and therefore StepsHaveChangedMessageCommand
					t.WheelWithFocus:scroll_by_amount(0)
				end
			-- proceed to the next wheel
			elseif event.GameButton == "Start" then
				if t.WheelWithFocus:get_info_at_focus_pos() == "CloseThisFolder" then
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					CloseCurrentFolder()
					return false
				end

				t.Enabled = false
				t.WheelWithFocus.container:queuecommand("Start")
				SwitchInputFocus(event.GameButton,{PlayerNumber=event.PlayerNumber})

				if t.WheelWithFocus.container then --going from group to song
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
					t.WheelWithFocus.container:queuecommand("Unhide")
				else --going from song to options
					SOUND:PlayOnce( THEME:GetPathS("Common", "start.ogg") )
					for pn in ivalues(Players) do
						UnhideOptionRows(pn)
					end
					
				end

			-- back out of the current wheel to the previous wheel if we're on the songwheel. if we're on the groupwheel then back out to main menu
			elseif event.GameButton == "Select" or event.GameButton == "Back" then
				if t.WheelWithFocus == SongWheel then 
					CloseCurrentFolder() 
					SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "expand.ogg") )
				elseif event.GameButton == "Back" then
					SCREENMAN:GetTopScreen():SetNextScreenName( Branch.SSMCancel() ):StartTransitioningScreen("SM_GoToNextScreen") 
				end
			end
	--------------------------------------------------------------
		--------------------------------------------------------------
		-- handle simple options menu input

		else
			-- get the index of the active optionrow for this player
			local index = ActiveOptionRow[event.PlayerNumber]
			if event.GameButton == "MenuRight" then
				if index ~= #OptionRows then
					-- The OptionRowItem for changing display doesn't do anything. So we broadcast a message with which pane to display.
					-- Then we increment the wheel normally so the option displays what pane we're looking at. Can't use the save/load
					-- thing because that only saves when you go to start instead of with every change. Maybe look in to this. 
					-- Probably not a good idea to assume this will be in row 2 all the time. TODO
					if ActiveOptionRow[event.PlayerNumber] == 2 then
						MESSAGEMAN:Broadcast("HidePlayerOptionsPane"..SL.Global.ActivePlayerOptionsPane+1)
						SL.Global.ActivePlayerOptionsPane = (SL.Global.ActivePlayerOptionsPane + 1) % 3
						MESSAGEMAN:Broadcast("ShowPlayerOptionsPane"..SL.Global.ActivePlayerOptionsPane+1)
					end
					-- scroll to the next optionrow_item in this optionrow
					t.WheelWithFocus[event.PlayerNumber][index]:scroll_by_amount(1)
					-- animate the right cursor
					t.WheelWithFocus[event.PlayerNumber].container:GetChild("item"..index):GetChild("Cursor"):GetChild("RightArrow"):finishtweening():playcommand("Press")
				end
			elseif event.GameButton == "MenuLeft" then
				if index ~= #OptionRows then
					if ActiveOptionRow[event.PlayerNumber] == 2 then
						MESSAGEMAN:Broadcast("HidePlayerOptionsPane"..SL.Global.ActivePlayerOptionsPane+1)
						SL.Global.ActivePlayerOptionsPane = (SL.Global.ActivePlayerOptionsPane - 1) % 3
						MESSAGEMAN:Broadcast("ShowPlayerOptionsPane"..SL.Global.ActivePlayerOptionsPane+1)
					end
					-- scroll to the previous optionrow_item in this optionrow
					t.WheelWithFocus[event.PlayerNumber][index]:scroll_by_amount(-1)
					-- animate the left cursor
					t.WheelWithFocus[event.PlayerNumber].container:GetChild("item"..index):GetChild("Cursor"):GetChild("LeftArrow"):finishtweening():playcommand("Press")
				end

			elseif event.GameButton == "MenuUp" then

				if ActiveOptionRow[event.PlayerNumber] > 1 then
					-- set the currently active option row, bounding it to not go below 1
					ActiveOptionRow[event.PlayerNumber] = math.max(index-1, 1)
					-- scroll up to previous optionrow for this player
					t.WheelWithFocus[event.PlayerNumber]:scroll_by_amount( -1 )
					MESSAGEMAN:Broadcast("CancelBothPlayersAreReady")
				end

			elseif event.GameButton == "Start" or event.GameButton == "MenuDown" then

				-- if both players are ALREADY here (before changing the row)
				-- it means it's time to start gameplay
				if event.GameButton == "Start" and t.AllPlayersAreAtLastRow() then
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
				end

				-- we want to proceed linearly to the last optionrow and then stop there
				if ActiveOptionRow[event.PlayerNumber] < #OptionRows then
					local choice = t.WheelWithFocus[event.PlayerNumber][index]:get_info_at_focus_pos()
					local choices= OptionRows[index]:Choices()
					local values = OptionRows[index].Values()

					OptionRows[index]:OnSave(event.PlayerNumber, choice, choices, values)

					t.WheelWithFocus[event.PlayerNumber]:scroll_by_amount(1)
				end

				-- update the index, bounding it to not exceed the number of rows
				index = math.min(index+1, #OptionRows)

				-- set the currently active option row to the updated index
				ActiveOptionRow[event.PlayerNumber] = index

				-- handle cursor position shifting for exit row as needed
				if index == #OptionRows then
					t.WheelWithFocus[event.PlayerNumber].container:GetChild("item"..index):GetChild("Cursor"):playcommand("ExitRow", {PlayerNumber=event.PlayerNumber})
				end

				-- if all available players are now at the final row (start icon), animate cursors spinning
				if t.AllPlayersAreAtLastRow() then
					MESSAGEMAN:Broadcast("BothPlayersAreReady")
				end

			elseif event.GameButton == "Select" or event.GameButton == "Back" then
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "sort.ogg") )
				t.CancelSongChoice()
			end
		end
	end
	return false
end

return t