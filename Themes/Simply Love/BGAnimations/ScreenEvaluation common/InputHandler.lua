local args = ...
local af = args.af
local num_panes = args.num_panes

if not af then return end

local panes, active_pane = {}, {}

local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())

for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	local pn = ToEnumShortString(player)
	panes[pn] = {}
	active_pane[pn] = num_panes

	for i=1,num_panes do
		table.insert(panes[pn], af:GetChild(pn.."_AF_Lower"):GetChild("Pane"..i))
	end
end

return function(event)

	if not event.PlayerNumber or not event.button then
		return false
	end

	local pn = ToEnumShortString(event.PlayerNumber)

	if event.type == "InputEventType_FirstPress" and panes[pn] then

		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
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

				panes[pn][i]:visible(false)
			end
			panes[pn][active_pane[pn]+1]:visible(true)
		end
	end

	return false
end