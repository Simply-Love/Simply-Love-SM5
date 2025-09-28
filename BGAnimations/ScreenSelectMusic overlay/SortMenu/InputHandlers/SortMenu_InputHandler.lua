local sort_wheel = ...

-- this handles user input while in the SortMenu
local input = function(event)
	if not (event and event.PlayerNumber and event.button) then
		return false
	end

	local screen   = SCREENMAN:GetTopScreen()
	local overlay  = screen:GetChild("Overlay")
	local sortmenu = overlay:GetChild("SortMenu")

	SOUND:StopMusic()

	if event.type ~= "InputEventType_Release" then
		if event.GameButton == "MenuRight" or event.GameButton == "MenuDown" then
			sort_wheel:scroll_by_amount(1)
			sortmenu:playcommand("WheelMoved")
			sortmenu:GetChild("change_sound"):play()
			sortmenu:GetChild("arrow_cursor"):playcommand("Bump")

		elseif event.GameButton == "MenuLeft" or event.GameButton == "MenuUp" then
			sort_wheel:scroll_by_amount(-1)
			sortmenu:playcommand("WheelMoved")
			sortmenu:GetChild("change_sound"):play()
			sortmenu:GetChild("arrow_cursor"):playcommand("Bump")

		elseif event.GameButton == "Start" then
			local info  = sort_wheel:get_info_at_focus_pos()

			-- info[1] is a string of top_text like "Sort By", "Change Mode To", or "Feeling Salty?"
			-- info[2] is a string of bottom_text like "Group", "Casual", or "Test Input"
			-- info[3] is a function to be called if the user chooses this row
			-- info[4] is a boolean, indicating if this row is a folder (true) or choice (false)
			if (info[4] == true) then
				sortmenu:GetChild("toggle_folder_sound"):play()
			else
				sortmenu:GetChild("start_sound"):play()
			end

			if (type(info[3])=="function") then
				-- some row actions (e.g. add song to player favorites) need a PlayerNumber, so pass that
				-- to all action functions.  most will ignore it, and that's fine.
				info[3](event.PlayerNumber)
			end

		elseif event.GameButton == "Back" or event.GameButton == "Select" then
			overlay:queuecommand("DirectInputToEngine")
		end
	end
	return false
end

return input
