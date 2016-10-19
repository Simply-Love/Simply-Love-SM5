local Players = GAMESTATE:GetHumanPlayers()
local num_panes = 3
local active_pane = {}

local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())

for player in ivalues(Players) do
	local pn = ToEnumShortString(player)
	active_pane[pn] = num_panes
end

local InputHandler = function(event)

	if not event.PlayerNumber or not event.button then
		return false
	end

	local af = SCREENMAN:GetTopScreen():GetChild("Overlay")
	local pn = ToEnumShortString(event.PlayerNumber)

	if not active_pane[pn] then
		return false
	end

	if event.type == "InputEventType_FirstPress" then

		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then

			af:GetChild(pn.."_AF_Lower"):queuecommand("HidePane")

			if event.GameButton == "MenuRight" then
				active_pane[pn] = ((active_pane[pn] + 1) % num_panes)
			elseif event.GameButton == "MenuLeft" then
				active_pane[pn] = ((active_pane[pn] - 1) % num_panes)
			end

			for i=1,num_panes do

				if style == "OnePlayerTwoSides" and active_pane[pn]+1 == 2 then
					af:queuecommand("Expand")
				else
					af:queuecommand("Shrink")
				end
			end

			af:GetChild(pn.."_AF_Lower"):GetChild("Pane"..active_pane[pn]+1):queuecommand("ShowPane")
		end
	end

	return false
end

return InputHandler