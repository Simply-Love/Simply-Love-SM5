local args = ...
local af = args[1]
local num_pages = args[2]
local page = 1

local left_arrow = af:GetChild("LeftArrow")
local right_arrow = af:GetChild("RightArrow")

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
			page = clamp(page + buttons[event.GameButton], 1, num_pages)

			af:finishtweening():queuecommand("Hide"):queuecommand("ShowPage"..page)
			af:GetChild("PageNumber"):finishtweening():playcommand("Update",{page=page})

			if left_arrow and right_arrow then
				left_arrow:visible( page > 1 )
				right_arrow:visible( page < num_pages )
			end
		end
	end
end

return InputHandler