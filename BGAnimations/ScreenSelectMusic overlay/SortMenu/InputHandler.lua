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

				-- Change the header text to reflect the newly selected GameMode.
				overlay:GetParent():GetChild("Header"):playcommand("UpdateHeaderText")

				-- Reload the SortMenu's available options and queue "HideSortMenu"
				-- which also returns input back away from Lua back to the engine.
				overlay:GetChild("SortMenu"):playcommand("On"):queuecommand("HideSortMenu")

			elseif focus.kind == "ChangeStyle" then
				-- If the MenuTimer is in effect, make sure to grab its current
				-- value before reloading the screen.
				if PREFSMAN:GetPreference("MenuTimer") then
					overlay:playcommand("ShowPressStartForOptions")
				end

				-- Get the style we want to change to...
				local new_style = focus.change:lower()

				-- ...and set it in the SL table and in the engine.
				SL.Global.Gamestate.Style = new_style
				GAMESTATE:SetCurrentStyle(new_style)

				-- finally, reload the screen.
				local topscreen = SCREENMAN:GetTopScreen()
				topscreen:SetNextScreenName("ScreenReloadSSM")
				topscreen:StartTransitioningScreen("SM_GoToNextScreen")
			end

		elseif event.GameButton == "Back" or event.GameButton == "Select" then
			overlay:queuecommand("HideSortMenu")
		end
	end

	return false
end

return input