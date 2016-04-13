local sort_wheel = ...

-- this handles user input
local function input(event)
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type ~= "InputEventType_Release" then
		local overlay = SCREENMAN:GetTopScreen():GetChild("Overlay")

		if event.GameButton == "MenuRight" then
			sort_wheel:scroll_by_amount(1)
			overlay:GetChild("SortMenu"):GetChild("change_sound"):play()

		elseif event.GameButton == "MenuLeft" then
			sort_wheel:scroll_by_amount(-1)
			overlay:GetChild("SortMenu"):GetChild("change_sound"):play()

		elseif event.GameButton == "Start" then
			overlay:GetChild("SortMenu"):GetChild("start_sound"):play()
			local focus = sort_wheel:get_actor_item_at_focus_pos()

			if focus.kind == "SortBy" then
				MESSAGEMAN:Broadcast('Sort',{order=focus.sort_by})
				overlay:queuecommand("HideSortMenu")

			elseif focus.kind == "ChangeMode" then
				SL.Global.GameMode = focus.change
				SetGameModePreferences()
				THEME:ReloadMetrics()
				overlay:queuecommand("HideSortMenu")

			elseif focus.kind == "ChangeStyle" then
				local new_style = focus.change:lower()

				-- local old_style = GAMESTATE:GetCurrentStyle():GetName()
				-- if old_style == "versus" then
				-- 	local other_player = PlayerNumber[(PlayerNumber:Reverse()[event.PlayerNumber]+1)%2+1]
				-- 	GAMESTATE:UnjoinPlayer( other_player )
				-- end

				SL.Global.Gamestate.Style = new_style
				GAMESTATE:SetCurrentStyle(new_style)
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenReloadSSM")
				SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
			end

		elseif event.GameButton == "Back" or event.GameButton == "Select" then
			overlay:queuecommand("HideSortMenu")
		end
	end

	return false
end

return input