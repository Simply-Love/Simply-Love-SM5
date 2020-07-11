local af, num_panes = unpack(...)

if not af
or type(num_panes) ~= "number"
then
	return
end

-- -----------------------------------------------------------------------

local panes, active_pane = {}, {}

local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
local players = GAMESTATE:GetHumanPlayers()

local mpn = GAMESTATE:GetMasterPlayerNumber()

-- since we're potentially retrieving from player profile
-- perform some rudimentary validation
-- clamp both values to be within permitted ranges and don't allow them to be the same

local primary_i   = clamp(SL[ToEnumShortString(mpn)].EvalPanePrimary,   1, num_panes)
local secondary_i = clamp(SL[ToEnumShortString(mpn)].EvalPaneSecondary, 1, num_panes)

-- -----------------------------------------------------------------------

for controller=1,2 do

	panes[controller] = {}

	-- Iterate through all potential panes, and only add the non-nil ones to the
	-- list of panes we want to consider.
	for i=1,num_panes do
		local pane_str = ("Pane%i_SideP%i"):format(i, controller)
		local pane = af:GetChild("Panes"):GetChild(pane_str)

		if pane ~= nil then
			-- single, double
			if #players==1 then
				if ("P"..controller)==ToEnumShortString(mpn) then
					pane:visible(i == primary_i)
					active_pane[1] =  primary_i

				elseif ("P"..controller)==ToEnumShortString(OtherPlayer[mpn]) then
					pane:visible(i == secondary_i)
					active_pane[2] =  secondary_i

				end

			-- versus
			else
				pane:visible(i == 1)
				active_pane[controller] = 1
			end

		 	table.insert(panes[controller], pane)
		end
	end
end

-- -----------------------------------------------------------------------
local OtherController = {
	GameController_1 = "GameController_2",
	GameController_2 = "GameController_1"
}

return function(event)

	if not (event and event.PlayerNumber and event.button) then return false end

	local  cn = tonumber(ToEnumShortString(event.controller))
	local ocn = tonumber(ToEnumShortString(OtherController[event.controller]))

	if event.type == "InputEventType_FirstPress" and panes[cn] then

		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
			if event.GameButton == "MenuRight" then
				active_pane[cn] = ((active_pane[cn]    ) % #panes[cn]) + 1
				-- don't allow duplicate panes to show in single/double
				-- if the above change would result in duplicate panes, increment again
				if #players==1 and active_pane[cn] == active_pane[ocn] then
					active_pane[cn] = ((active_pane[cn]    ) % #panes[cn]) + 1
				end

			elseif event.GameButton == "MenuLeft" then
				active_pane[cn] = ((active_pane[cn] - 2) % #panes[cn]) + 1
				-- don't allow duplicate panes to show in single/double
				-- if the above change would result in duplicate panes, decrement again
				if #players==1 and active_pane[cn] == active_pane[ocn] then
					active_pane[cn] = ((active_pane[cn] - 2) % #panes[cn]) + 1
				end
			end


			-- double
			if style == "OnePlayerTwoSides" then
				-- if this controller is switching to Pane2, which takes over both pane widths
				if panes[cn][active_pane[cn]]:GetChild(""):GetCommand("ExpandForDouble") then

					for i=1,2 do
						for pane in ivalues(panes[i]) do
							pane:visible(false)
						end
					end
					panes[cn][active_pane[cn]]:visible(true)

				-- if this controller is switching panes while the OTHER controller was viewing Pane2
				elseif panes[ocn][active_pane[ocn]]:GetChild(""):GetCommand("ExpandForDouble") then
					panes[ocn][active_pane[ocn]]:visible(false)
					panes[cn][active_pane[cn]]:visible(true)
					-- atribitarily choose to decrement other controller pane
					active_pane[ocn] = ((active_pane[ocn] - 2) % #panes[ocn]) + 1
					if active_pane[cn] == active_pane[ocn] then
						active_pane[ocn] = ((active_pane[ocn] - 2) % #panes[ocn]) + 1
					end
					panes[ocn][active_pane[ocn]]:visible(true)

				else

					-- hide all panes for this side
					for i=1,#panes[cn] do
						panes[cn][i]:visible(false)
					end
					-- show the panes we want on both sides
					panes[cn][active_pane[cn]]:visible(true)
					panes[ocn][active_pane[ocn]]:visible(true)
				end


			-- single, versus
			else
				-- hide all panes for this side
				for i=1,#panes[cn] do
					panes[cn][i]:visible(false)
				end
				-- only show the pane we want on this side
				panes[cn][active_pane[cn]]:visible(true)
			end

			af:queuecommand("PaneSwitch")
		end
	end

	if PREFSMAN:GetPreference("OnlyDedicatedMenuButtons") and event.type ~= "InputEventType_Repeat" then
		MESSAGEMAN:Broadcast("TestInputEvent", event)
	end

	return false
end