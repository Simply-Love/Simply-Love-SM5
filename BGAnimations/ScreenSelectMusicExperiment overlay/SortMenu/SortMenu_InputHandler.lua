local sort_wheel = ...

-- this handles user input while in the SortMenu
local function input(event)
	if not (event and event.PlayerNumber and event.button) then
		return false
	end
	SOUND:StopMusic()

	local screen   = SCREENMAN:GetTopScreen()
	local overlay  = screen:GetChild("Overlay")
	local sortmenu = overlay:GetChild("SortMenu")

	if event.type ~= "InputEventType_Release" then

		if event.GameButton == "MenuRight" then
			sort_wheel:scroll_by_amount(1)
			sortmenu:GetChild("change_sound"):play()

		elseif event.GameButton == "MenuLeft" then
			sort_wheel:scroll_by_amount(-1)
			sortmenu:GetChild("change_sound"):play()

		elseif event.GameButton == "Start" then
			sortmenu:GetChild("start_sound"):play()
			local focus = sort_wheel:get_actor_item_at_focus_pos()

			if focus.kind == "SortBy" then
				if focus.sort_by == "Tag" and #GetGroups("Tag") <= 1 then
					SM("Create tags to use this sort type")
				else
					SL.Global.GroupType = focus.sort_by
					MESSAGEMAN:Broadcast("GroupTypeChanged")
					overlay:queuecommand("DirectInputToEngine")
				end
			-- the player wants to adjust filters
			elseif focus.kind == "Adjust" then
				--go to filters screen
				screen:SetNextScreenName("ScreenFilterOptions")
				screen:StartTransitioningScreen("SM_GoToNextScreen")
			elseif focus.kind == "Text" then
				SM("Add search function")
				overlay:queuecommand("DirectInputToEngine")
			elseif focus.new_overlay then
				if focus.new_overlay == "TestInput" then
					sortmenu:queuecommand("DirectInputToTestInput")
				elseif focus.new_overlay == "Song Tags" then
					overlay:queuecommand("DirectInputToTagMenu")
				elseif focus.new_overlay == "Order" then
					overlay:queuecommand("DirectInputToOrderMenu")
				end
			end

		elseif event.GameButton == "Back" or event.GameButton == "Select" then
			overlay:queuecommand("DirectInputToEngine")
		end
	end

	return false
end

return input