local args = ...
local GroupWheel = args.GroupWheel
local SongWheel = args.SongWheel
local OptionsWheel = args.OptionsWheel
local OptionRows = args.OptionRows


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
local AllPlayersAreAtLastRow = function()
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

-----------------------------------------------------
-- start internal functions

t.Init = function()
	-- flag used to determind whether input is permitted
	-- false by default
	t.Enabled = false

	-- initialize so that GroupWheel has focus when the screen loads
	t.WheelWithFocus = GAMESTATE:GetCurrentSong() and SongWheel or GroupWheel

	-- table that stores P1 and P2's currently active optionrow
	ActiveOptionRow = {}

	for pn in ivalues(Players) do
		ActiveOptionRow[pn] = 1
	end
end

t.Handler = function(event)
	-- if any of these, don't attempt to handle input
	if t.Enabled == false or not event or not event.PlayerNumber or not event.button then
		return false
	end

	if not GAMESTATE:IsPlayerEnabled(event.PlayerNumber) then
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
			if event.GameButton == "MenuRight" then
				t.WheelWithFocus:scroll_by_amount(1)
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			elseif event.GameButton == "MenuLeft" then
				t.WheelWithFocus:scroll_by_amount(-1)
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )

			-- navigate the wheel up and down
			elseif event.GameButton == "MenuUp" then
				t.WheelWithFocus:scroll_by_amount(t.WheelWithFocus==GroupWheel and -3 or -1)
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			elseif event.GameButton == "MenuDown" then
				t.WheelWithFocus:scroll_by_amount(t.WheelWithFocus==GroupWheel and 3 or 1)
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )


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
						t.WheelWithFocus[pn].container:queuecommand("Unhide")

						for i=1,#OptionRows do
							t.WheelWithFocus[pn][i].container:queuecommand("Unhide")
						end
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
				-- scroll to the next opionrow_item in this optionrow
				t.WheelWithFocus[event.PlayerNumber][index]:scroll_by_amount(1)
				-- animate the right cursor
				t.WheelWithFocus[event.PlayerNumber].container:GetChild("item"..index):GetChild("Cursor"):GetChild("RightArrow"):playcommand("Press")


			elseif event.GameButton == "MenuLeft" then
				-- scroll to the previous opionrow_item in this optionrow
				t.WheelWithFocus[event.PlayerNumber][index]:scroll_by_amount(-1)
				-- animate the left cursor
				t.WheelWithFocus[event.PlayerNumber].container:GetChild("item"..index):GetChild("Cursor"):GetChild("LeftArrow"):playcommand("Press")



			elseif event.GameButton == "Start" or event.GameButton == "MenuDown" then

				-- if both players are ALREADY here (before changing the row)
				-- it means it's time to start gameplay
				if event.GameButton == "Start" and AllPlayersAreAtLastRow() then
					local topscreen = SCREENMAN:GetTopScreen()
					if topscreen then topscreen:StartTransitioningScreen("SM_GoToNextScreen") end
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

				-- update the index
				index = index + 1
				-- prevent out of bounds by stopping at the last row
				if index > #OptionRows then index = #OptionRows end
				-- set the currently active option row to the updated index
				ActiveOptionRow[event.PlayerNumber] = index

				-- handle cursor position shifting for exit row as needed
				if index == #OptionRows then
					-- local arrow_direction = event.PlayerNumber == PLAYER_1 and "Left" or "Right"
					t.WheelWithFocus[event.PlayerNumber].container:GetChild("item"..index):GetChild("Cursor"):playcommand("ExitRow", {PlayerNumber=event.PlayerNumber})
				end

				-- if all available players are done selecting options, animate cursors
				if AllPlayersAreAtLastRow() then
					MESSAGEMAN:Broadcast("BothPlayersAreReady")
				end

			elseif event.GameButton == "Select" then

				t.Enabled = false
				for pn in ivalues(Players) do

					ActiveOptionRow[pn] = 1

					t.WheelWithFocus[pn].container:playcommand("Hide")

					for i=1,#OptionRows do
						t.WheelWithFocus[pn][i].container:queuecommand("Hide")
					end

					t.WheelWithFocus[pn]:scroll_to_pos(1)
				end
				MESSAGEMAN:Broadcast("SingleSongCanceled")
				SwitchInputFocus(event.GameButton)
				t.WheelWithFocus.container:queuecommand("Unhide")
			end
		end
	end


	return false
end

return t