local af = ...
if not af then return end

local num_panes = 2
local panes, active_pane = {}, {}

for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	local pn = ToEnumShortString(player)
	active_pane[pn] = 2
	local lower_af = af:GetChild(pn .. "_AF_Lower")

	panes[pn] = {}
	for i=1,num_panes do
		panes[pn][i] = lower_af:GetChild("Pane"..i)
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
				if active_pane[pn]+1 == i then
					panes[pn][i]:visible(true)
				else
					panes[pn][i]:visible(false)
				end
			end
		end
	end

	return false
end