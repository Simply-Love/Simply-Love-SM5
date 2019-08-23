local args = ...
local af = args.af
local num_panes = args.num_panes

if not af then return end

local panes, active_pane = {}, {}

local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())

for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	local pn = ToEnumShortString(player)
	panes[pn] = {}

	-- Iterate through all potential panes, and only add the non-nil ones to the
	-- list of panes we want to consider.
	for i=1,num_panes do
		if af:GetChild(pn.."_AF_Lower"):GetChild("Pane"..i) ~= nil then
		 	table.insert(panes[pn], af:GetChild(pn.."_AF_Lower"):GetChild("Pane"..i))
		end
	end

	active_pane[pn] = #panes[pn]
end

return function(event)

	if SL.Global.GameMode == "Casual" then return false end
	if not (event and event.PlayerNumber and event.button) then return false end

	local pn = ToEnumShortString(event.PlayerNumber)

	if event.type == "InputEventType_FirstPress" and panes[pn] then

		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
			if event.GameButton == "MenuRight" then
				active_pane[pn] = ((active_pane[pn] + 1) % #panes[pn])
			elseif event.GameButton == "MenuLeft" then
				active_pane[pn] = ((active_pane[pn] - 1) % #panes[pn])
			end

			for i=1,#panes[pn] do
				if style == "OnePlayerTwoSides" and panes[pn][active_pane[pn]+1]:GetCommand("ExpandForDouble") then
					af:queuecommand("Expand")
				else
					af:queuecommand("Shrink")
				end

				panes[pn][i]:visible(false)
			end
			panes[pn][active_pane[pn]+1]:visible(true)
		end
	end

	if GAMESTATE:IsEventMode() and PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") and event.type ~= "InputEventType_Repeat" then
		MESSAGEMAN:Broadcast("TestInputEvent", event)
	end

	return false
end