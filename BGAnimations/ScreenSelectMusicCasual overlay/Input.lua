local args = ...
local GroupWheel = args.GroupWheel
local SongWheel = args.SongWheel
local OptionsWheel = args.OptionsWheel
local OptionRows = args.OptionRows

-- initialize Players to be any HumanPlayers at screen init
-- we'll update this later via latejoin if needed
local Players = GAMESTATE:GetHumanPlayers()

local ActiveOptionRow

-----------------------------------------------------
-- input handler
local t = {}
-----------------------------------------------------

local SwitchInputFocus = function(button)

	if button == "Start" then

		if t.WheelWithFocus == GroupWheel then
			t.WheelWithFocus = SongWheel

		elseif t.WheelWithFocus == SongWheel then
			t.WheelWithFocus = OptionsWheel
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
	-- flag used to determind whether input is permitted
	-- false at initialization
	t.Enabled = false

	-- initialize which wheel gets focus to start based on whether or not
	-- GAMESTATE has a CurrentSong (it always should at screen init)
	t.WheelWithFocus = GAMESTATE:GetCurrentSong() and SongWheel or GroupWheel

	-- table that stores P1 and P2's currently active optionrow
	ActiveOptionRow = {
		[PLAYER_1] = 1,
		[PLAYER_2] = 1
	}

	t.CancelSongChoice = function()
		t.Enabled = false
		for pn in ivalues(Players) do

			-- reset the ActiveOptionRow for this player
			ActiveOptionRow[pn] = 1
			-- hide this player's OptionsWheel
			t.WheelWithFocus[pn].container:playcommand("Hide")
			-- hide this player's OptionRows
			for i=1,#OptionRows do
				t.WheelWithFocus[pn][i].container:queuecommand("Hide")
			end
			-- ensure that this player's OptionsWheel understands it has been reset
			t.WheelWithFocus[pn]:scroll_to_pos(1)
		end
		MESSAGEMAN:Broadcast("SingleSongCanceled")
		t.WheelWithFocus = SongWheel
		t.WheelWithFocus.container:queuecommand("Unhide")
	end
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

	if event.type ~= "InputEventType_Release" then

		if event.GameButton == "Back" then
			SCREENMAN:GetTopScreen():SetNextScreenName( Branch.SSMCancel() ):StartTransitioningScreen("SM_GoToNextScreen")
		end

		--------------------------------------------------------------
		--------------------------------------------------------------
		-- handle wheel input
		if t.WheelWithFocus ~= OptionsWheel then

			-- navigate the wheel left and right
			if event.GameButton == "MenuRight" or event.GameButton == "MenuDown" then
				t.WheelWithFocus:scroll_by_amount(1)
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
				if t.WheelWithFocus==SongWheel then
					SCREENMAN:GetTopScreen():GetChild("Overlay"):GetChild("SongWheelShared"):GetChild("Arrows"):GetChild("RightArrow"):finishtweening():playcommand("Press")
				end
			elseif event.GameButton == "MenuLeft" or event.GameButton == "MenuUp" then
				t.WheelWithFocus:scroll_by_amount(-1)
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
				if t.WheelWithFocus==SongWheel then
					SCREENMAN:GetTopScreen():GetChild("Overlay"):GetChild("SongWheelShared"):GetChild("Arrows"):GetChild("LeftArrow"):finishtweening():playcommand("Press")
				end


			-- proceed to the next wheel
			elseif event.GameButton == "Start" then

				if t.WheelWithFocus:get_info_at_focus_pos() == "CloseThisFolder" then
					CloseCurrentFolder()
					return false
				end

				t.Enabled = false
				t.WheelWithFocus.container:queuecommand("Start")
				SwitchInputFocus(event.GameButton)

				if t.WheelWithFocus.container then
					t.WheelWithFocus.container:queuecommand("Unhide")
				else
					for pn in ivalues(Players) do
						UnhideOptionRows(pn)
					end
				end

			-- back out of the current wheel to the previous wheel
			elseif event.GameButton == "Select" then
				CloseCurrentFolder()
			end

		--------------------------------------------------------------
		--------------------------------------------------------------
		-- handle simple options menu input

		else
			-- get the index of the active optionrow for this player
			local index = ActiveOptionRow[event.PlayerNumber]

			if event.GameButton == "MenuRight" then
				-- scroll to the next optionrow_item in this optionrow
				t.WheelWithFocus[event.PlayerNumber][index]:scroll_by_amount(1)
				-- animate the right cursor
				t.WheelWithFocus[event.PlayerNumber].container:GetChild("item"..index):GetChild("Cursor"):GetChild("RightArrow"):finishtweening():playcommand("Press")


			elseif event.GameButton == "MenuLeft" then
				-- scroll to the previous optionrow_item in this optionrow
				t.WheelWithFocus[event.PlayerNumber][index]:scroll_by_amount(-1)
				-- animate the left cursor
				t.WheelWithFocus[event.PlayerNumber].container:GetChild("item"..index):GetChild("Cursor"):GetChild("LeftArrow"):finishtweening():playcommand("Press")


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
					local topscreen = SCREENMAN:GetTopScreen()
					if topscreen then
						topscreen:StartTransitioningScreen("SM_GoToNextScreen")
					end
					return false
				end

				-- we want to proceed linearly to the last optionrow and then stop there
				if ActiveOptionRow[event.PlayerNumber] < #OptionRows then
					local choice = t.WheelWithFocus[event.PlayerNumber][index]:get_info_at_focus_pos()
					local choices= OptionRows[index].choices
					local values = OptionRows[index].values

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

			elseif event.GameButton == "Select" then
				t.CancelSongChoice()
			end
		end
	end


	return false
end

return t