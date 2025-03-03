local af, num_panes = unpack(...)

if not af
or type(num_panes) ~= "number"
then
	return
end

-- -----------------------------------------------------------------------
-- local variables

local panes, active_pane = {}, {}

local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
local players = GAMESTATE:GetHumanPlayers()

local mpn = GAMESTATE:GetMasterPlayerNumber()

-- since we're potentially retrieving from player profile
-- perform some rudimentary validation by clamping both
-- values to be within permitted ranges
-- FIXME: num_panes won't be accurate if any panes were nil,
--        so this is more like "validation" than validation

local primary_i   = clamp(SL[ToEnumShortString(mpn)].EvalPanePrimary,   1, num_panes)
local secondary_i = clamp(SL[ToEnumShortString(mpn)].EvalPaneSecondary, 1, num_panes)

-- -----------------------------------------------------------------------
-- initialize local tables (panes, active_pane) for the the input handling function to use

for controller=1,2 do

	panes[controller] = {}

	-- Iterate through all potential panes, and only add the non-nil ones to the
	-- list of panes we want to consider.
	for i=1,num_panes do

		local pane = af:GetChild("Panes"):GetChild( ("Pane%i_SideP%i"):format(i, controller) )

		if pane ~= nil then
			-- single, double
			-- initialize the side ("controller") the player is joined as to their profile's EvalPanePrimary
			-- and the other side as their profile's EvalPaneSecondary
			if #players==1 then
				if ("P"..controller)==ToEnumShortString(mpn) then
					if i == primary_i then
						pane:visible(true)
						active_pane[controller] = #panes[controller] + 1
					else
						pane:visible(false)
					end
				elseif ("P"..controller)==ToEnumShortString(OtherPlayer[mpn]) then
					if i == secondary_i then
						pane:visible(true)
						active_pane[controller] = #panes[controller] + 1
					else
						pane:visible(false)
					end
				end

			-- versus
			else
				-- initialize this player's active_pane to their profile's EvalPanePrimary
				-- will be 1 if no profile/"Guest" profile
				local p = clamp(SL["P"..controller].EvalPanePrimary, 1, num_panes)
				pane:visible(i == p)
				active_pane[controller] = p
			end

		 	table.insert(panes[controller], pane)
		end
	end
end

-- -----------------------------------------------------------------------
-- don't allow double to initialize into a configuration like
-- EvalPanePrimary=3
-- EvalPaneSecondary=4
-- because Pane3 is full-width in double and the other pane is supposed to be hidden when it is visible

if style == "OnePlayerTwoSides" then
	local cn  = PlayerNumber:Reverse()[mpn] + 1
	local ocn = (cn % 2) + 1

	-- if the player wanted their primary pane to be something that is full-width in double
	if panes[cn][active_pane[cn]]:GetChild(""):GetCommand("ExpandForDouble") then
		-- hide all panes for the other controller
		for pane in ivalues(panes[ocn]) do
			pane:visible(false)
		end
		-- and only show the one full-width pane
		panes[cn][active_pane[cn]]:visible(true)
	end

	-- if the player wanted their secondary pane to be something that is full-width in double
	if panes[cn][active_pane[ocn]]:GetChild(""):GetCommand("ExpandForDouble") then
		-- arbitrarily opt to hide the secondary pane
		panes[ocn][active_pane[ocn]]:visible(false)

		-- and show the next available pane that doesn't match primary and isn't also full-width
		for i=1,#panes[ocn] do
			active_pane[ocn] = (active_pane[ocn] % #panes[ocn]) + 1

			if active_pane[ocn] ~= active_pane[cn]
			and not panes[cn][active_pane[ocn]]:GetChild(""):GetCommand("ExpandForDouble")
			then
				panes[ocn][active_pane[ocn]]:visible(true)
				break
			end
		end
	end
end

-- -----------------------------------------------------------------------
-- input handling function

local OtherController = {
	GameController_1 = "GameController_2",
	GameController_2 = "GameController_1"
}

return function(event)

	if not (event and event.PlayerNumber and event.button) then return false end

	-- get a "controller number" and an "other controller number"
	-- if the input event came from GameController_1, cn will be 1 and ocn will be 2
	-- if the input event came from GameController_2, cn will be 2 and ocn will be 1
	--
	-- we'll use these integers to index the active_pane table, which keeps track
	-- of which pane is currently showing on each side
	local  cn = tonumber(ToEnumShortString(event.controller))
	local ocn = tonumber(ToEnumShortString(OtherController[event.controller]))


	if event.type == "InputEventType_FirstPress" and panes[cn] then

		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
			if event.GameButton == "MenuRight" then
				active_pane[cn] = (active_pane[cn] % #panes[cn]) + 1
				-- don't allow duplicate panes to show in single/double
				-- if the above change would result in duplicate panes, increment again
				if #players==1 and active_pane[cn] == active_pane[ocn] then
					active_pane[cn] = (active_pane[cn] % #panes[cn]) + 1
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
				-- if this controller is switching to Pane3 or Pane6, both of which take over both pane widths
				if panes[cn][active_pane[cn]]:GetChild(""):GetCommand("ExpandForDouble") then

					-- hide all panes for both controllers
					for controller=1,2 do
						for pane in ivalues(panes[controller]) do
							pane:visible(false)
						end
					end
					-- and only show the one full-width pane
					panes[cn][active_pane[cn]]:visible(true)


				-- if this controller is switching panes while the OTHER controller was viewing Pane3 or Pane6
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