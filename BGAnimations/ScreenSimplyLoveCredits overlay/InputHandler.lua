local args = ...
local af = args[1]
local pages = args[2]
local page = 1
local next_page

-- assume that the player has dedicated MenuButtons
local buttons = {
	-- previous page
	MenuLeft = -1,
	MenuUp = -1,
	-- next page
	MenuRight = 1,
	MenuDown = 1,
}

-- if OnlyDedicatedMenuButtons is disabled, add in support for navigating this screen with gameplay buttons
if not PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") then
	-- previous page
	buttons.Left=-1
	buttons.Up=-1
	-- next page
	buttons.Right=1
	buttons.Down=1
end


local InputHandler = function(event)
	if not event.PlayerNumber or not event.button then return false end

	if event.type == "InputEventType_FirstPress" then
		if event.GameButton=="Start" or event.GameButton=="Back" then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end

		if buttons[event.GameButton] ~= nil then
			next_page = page + buttons[event.GameButton]

			if next_page > 0 and next_page < pages+1 then
				page = next_page
				af:stoptweening():queuecommand("Hide"):queuecommand("ShowPage"..page)
				af:playcommand("Update",{page=page})
			end
		end
	end
end

return InputHandler