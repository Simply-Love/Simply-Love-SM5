local candidatesScroller, af = ...

local input = function(event)
	if not (event and event.PlayerNumber and event.button) then
		return false
	end

	if event.type ~= "InputEventType_Release" then
		local index = candidatesScroller.info_pos
		local num_items = #candidatesScroller.info_set
		local num_rows = candidatesScroller.num_items
		if event.GameButton == "MenuRight" or event.GameButton == "MenuDown" then
			if index + num_rows - 1 < num_items and index < num_items then
				candidatesScroller:scroll_by_amount(1)
			end
		elseif event.GameButton == "MenuLeft" or event.GameButton == "MenuUp" then
			if 1 < index then
				candidatesScroller:scroll_by_amount(-1)
			end
		elseif event.GameButton == "Start" or event.GameButton == "Back" or event.GameButton == "Select" then
			SOUND:PlayOnce(THEME:GetPathS("Common", "Start"))
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
	return false
end

return input