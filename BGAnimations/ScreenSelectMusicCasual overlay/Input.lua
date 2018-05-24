local args = ...
local af = args.af
local GroupWheel = args.GroupWheel
local SongWheel = args.SongWheel
local OptionsWheel = args.OptionsWheel
local OptionRows = args.OptionRows


local Players = GAMESTATE:GetHumanPlayers()
local WheelWithFocus, ActiveOptionRow

local SwitchInputFocus = function(button)

	if button == "Start" then

		if WheelWithFocus == GroupWheel then
			WheelWithFocus = SongWheel

		elseif WheelWithFocus == SongWheel then
			WheelWithFocus = OptionsWheel
		end

	elseif button == "Select" or button == "Back" then

		if WheelWithFocus == SongWheel then
			WheelWithFocus = GroupWheel

		elseif WheelWithFocus == OptionsWheel then
			WheelWithFocus = SongWheel
		end

	end
end

local AllPlayersAreAtLastRow = function()
	for player in ivalues(Players) do
		if ActiveOptionRow[player] ~= #OptionRows then
			return false
		end
	end
	return true
end

-----------------------------------------------------
-- input handler
local t = {}
-----------------------------------------------------

local CloseCurrentFolder = function()
	t.Enabled = false
	WheelWithFocus.container:queuecommand("Hide")
	WheelWithFocus = GroupWheel
	WheelWithFocus.container:queuecommand("Unhide")
end

-----------------------------------------------------
-- start internal functions

t.Init = function()
	-- flag used to determind whether input is permitted
	-- false by default
	t.Enabled = false

	-- initialize so that GroupWheel has focus when the screen loads
	WheelWithFocus = GroupWheel

	-- table that P1 and P2's currently active option row (1 if hidden)
	ActiveOptionRow = {}

	for pn in ivalues(Players) do
		ActiveOptionRow[pn] = 1
	end
end

t.Handler = function(event)
	-- if any of these, don't attempt to handle input
	if not event or not event.PlayerNumber or not event.button then
		return false
	end

	if not GAMESTATE:IsPlayerEnabled(event.PlayerNumber) then
		return false
	end

	if t.Enabled == false then
		return false
	end

	if event.type ~= "InputEventType_Release" then

		if event.GameButton == "Back" then
			local topscreen = SCREENMAN:GetTopScreen()
			topscreen:SetNextScreenName( Branch.SSMCancel() )
			topscreen:StartTransitioningScreen("SM_GoToNextScreen")
		end

		--------------------------------------------------------------
		--------------------------------------------------------------
		-- handle wheel input
		if WheelWithFocus ~= OptionsWheel then

			-- navigate the wheel left and right
			if event.GameButton == "MenuRight" then
				WheelWithFocus:scroll_by_amount(1)
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			elseif event.GameButton == "MenuLeft" then
				WheelWithFocus:scroll_by_amount(-1)
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )

			-- navigate the wheel up and down
			elseif event.GameButton == "MenuUp" then
				WheelWithFocus:scroll_by_amount(-3)
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )
			elseif event.GameButton == "MenuDown" then
				WheelWithFocus:scroll_by_amount(3)
				SOUND:PlayOnce( THEME:GetPathS("MusicWheel", "change.ogg") )


			-- proceed to the next wheel
			elseif event.GameButton == "Start" then

				if WheelWithFocus:get_info_at_focus_pos() == "CloseThisFolder" then
					CloseCurrentFolder()
					return false
				end

				t.Enabled = false
				WheelWithFocus.container:queuecommand("Start")
				SwitchInputFocus(event.GameButton)

				if WheelWithFocus.container then
					WheelWithFocus.container:queuecommand("Unhide")
				else
					for pn in ivalues(Players) do
						WheelWithFocus[pn].container:queuecommand("Unhide")

						for i=1,#OptionRows do
							WheelWithFocus[pn][i].container:queuecommand("Unhide")
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
				WheelWithFocus[event.PlayerNumber][index]:scroll_by_amount(1)
				-- animate the right cursor
				WheelWithFocus[event.PlayerNumber].container:GetChild("item"..index):GetChild("Cursor"):GetChild("RightArrow"):playcommand("Press")


			elseif event.GameButton == "MenuLeft" then
				-- scroll to the previous opionrow_item in this optionrow
				WheelWithFocus[event.PlayerNumber][index]:scroll_by_amount(-1)
				-- animate the left cursor
				WheelWithFocus[event.PlayerNumber].container:GetChild("item"..index):GetChild("Cursor"):GetChild("LeftArrow"):playcommand("Press")



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
					local choice = WheelWithFocus[event.PlayerNumber][index]:get_info_at_focus_pos()
					local choices= OptionRows[index].choices
					local values = OptionRows[index].values

					OptionRows[index]:OnSave(event.PlayerNumber, choice, choices, values)

					WheelWithFocus[event.PlayerNumber]:scroll_by_amount(1)
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
					WheelWithFocus[event.PlayerNumber].container:GetChild("item"..index):GetChild("Cursor"):playcommand("ExitRow", {PlayerNumber=event.PlayerNumber})
				end

				-- if both players are done selecting options, animate both players' cusors
				if ActiveOptionRow[PLAYER_1] == #OptionRows and ActiveOptionRow[PLAYER_2] == #OptionRows then
					MESSAGEMAN:Broadcast("BothPlayersAreReady")
				end

			elseif event.GameButton == "Select" then

				t.Enabled = false
				for pn in ivalues(Players) do

					ActiveOptionRow[pn] = 1

					WheelWithFocus[pn].container:playcommand("Hide")

					for i=1,#OptionRows do
						WheelWithFocus[pn][i].container:queuecommand("Hide")
					end

					WheelWithFocus[pn]:scroll_to_pos(1)
				end
				MESSAGEMAN:Broadcast("SingleSongCanceled")
				SwitchInputFocus(event.GameButton)
				WheelWithFocus.container:queuecommand("Unhide")
			end
		end
	end


	return false
end

return t