local candidatesScroller = ...

local input = function(event)
	if not (event and event.PlayerNumber and event.button) then
		return false
	end

	local overlay = SCREENMAN:GetTopScreen():GetChild("Overlay"):GetChild("SongSearch")

	if event.type ~= "InputEventType_Release" then
		local info = candidatesScroller:get_info_at_focus_pos()
		local index = type(info)=="table" and info.index or 0
		local num_items = type(info)=="table" and info.totalItems or candidatesScroller.num_items
		if event.GameButton == "MenuRight" or event.GameButton == "MenuDown" then
			candidatesScroller:scroll_by_amount(1)
		elseif event.GameButton == "MenuLeft" or event.GameButton == "MenuUp" then
			candidatesScroller:scroll_by_amount(-1)
		elseif event.GameButton == "Start" then
			local focus = candidatesScroller:get_actor_item_at_focus_pos()
			local songOrExit = focus.song_name.songOrExit
			if type(songOrExit) ~= "string" then
				GAMESTATE:SetPreferredSong(songOrExit)
				local screen = SCREENMAN:GetTopScreen()
				screen:SetNextScreenName("ScreenReloadSSM")
				screen:StartTransitioningScreen("SM_GoToNextScreen")
			end
			overlay:queuecommand("DirectInputToEngine")
		elseif event.GameButton == "Back" or event.GameButton == "Select" then
			overlay:queuecommand("DirectInputToEngine")
		end
	end
	return false
end

return input