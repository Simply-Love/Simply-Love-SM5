return function(AllSteps)

	local StepsToShow, edits = {}, {}

	for stepchart in ivalues(AllSteps) do

		local difficulty = stepchart:GetDifficulty()

		if difficulty == "Difficulty_Edit" then
			-- gather edit charts into a separate table for now
			edits[#edits+1] = stepchart
		else
			-- use the reverse lookup functionality available to all SM enums
			-- to map a difficulty string to a number
			-- SM's enums are 0 indexed, so Beginner is 0, Challenge is 4, and Edit is 5
			-- for our purposes, increment by 1 here
			StepsToShow[ Difficulty:Reverse()[difficulty] + 1 ] = stepchart
			-- assigning a stepchart directly to numerical index like this^
			-- can leave "holes" in the indexing, or indexing might not start at 1
			-- so be sure to use pairs() instead of ipairs() if iterating over later
		end
	end

	-- if there are no edits we can safely return now
	-- the remainder of this function will not execute
	if #edits == 0 then return StepsToShow end

	-- -----------------------------------------------------------------------
	-- there were edits, we might need to do more work

	-- if only one player is joined
	if #GAMESTATE:GetHumanPlayers() <= 1 then
		local player = GAMESTATE:GetHumanPlayers()[1]
		local currentSteps = GAMESTATE:GetCurrentSteps(player)

		-- currentSteps can be nil while reloading SelectMusic after
		-- switching style (e.g. double → single) using SL's SortMenu
		if not currentSteps then return StepsToShow end

		-- there are edit stepcharts available for the current song
		-- but this player's current steps aren't an edit, so they are
		-- presumably looking at the normal (Beginner - Expert) range
		if not currentSteps:IsAnEdit() then return StepsToShow end

	-- both players are joined
	else
		-- but neither players' steps is an edit
		if not GAMESTATE:GetCurrentSteps(PLAYER_1):IsAnEdit() and not GAMESTATE:GetCurrentSteps(PLAYER_2):IsAnEdit() then
			-- so just return the "normal" stepcharts
			return StepsToShow
		end
	end

	-- -----------------------------------------------------------------------
	-- some shifting will be needed if we get this far

	-- if we get this far, one or both players' stepcharts is an edit
	-- we'll need to assess which stepcharts we want to display in our 5x20 grid
	for i, edit_chart in ipairs(edits) do
		StepsToShow[5+i] = edit_chart
	end

	if #GAMESTATE:GetHumanPlayers() <= 1 then
		local player = GAMESTATE:GetHumanPlayers()[1]
		local currentSteps = GAMESTATE:GetCurrentSteps(player)

		-- otherwise, currentSteps are an edit so let's shift what we show
		local edit_index = 0
		for i, edit_chart in ipairs(edits) do
			-- .sm files don't have a good way that is accessible to Lua to guarantee this edit chart is really
			-- the one you're looking for.  Comparing the (Description and ChartName and Meter) for matches
			-- seems to be as good as we can do (short of hashing the chart data which seems like overkill here).
			-- It is possible for two edit charts in an .sm file to have empty ChartNames, empty Descriptions,
			-- and matching meters.  :(
			if  edit_chart:GetDescription() == currentSteps:GetDescription()
			and edit_chart:GetChartName()   == currentSteps:GetChartName()
			and edit_chart:GetMeter()       == currentSteps:GetMeter()
			then
				edit_index = i
				break
			end
		end

		return {
			StepsToShow[1+edit_index],
			StepsToShow[2+edit_index],
			StepsToShow[3+edit_index],
			StepsToShow[4+edit_index],
			StepsToShow[5+edit_index]
		}

	-- if both players are joined
	else

		local indexP1, indexP2 = nil, nil
		-- use pairs() instead of ipairs() here because the StepsToShow table
		-- might not be fully filled in (e.g. missing Beginner and Easy steps at indices 1 and 2)
		-- and ipairs() will start at 1, increment up, and halt as soon as it hits a nil index
		for i,stepchart in pairs(StepsToShow) do
			if stepchart == GAMESTATE:GetCurrentSteps(PLAYER_1) then indexP1 = i end
			if stepchart == GAMESTATE:GetCurrentSteps(PLAYER_2) then indexP2 = i end
		end

		if (indexP1 and indexP2) then
			local lesserIndex  = math.min(indexP1, indexP2)
			local greaterIndex = math.max(indexP1, indexP2)

			-- if P1 and P2 are farther than 4 stepcharts apart (e.g. Beginner and Edit)
			if math.abs(indexP1-indexP2) >= 5 then
				-- inelegant but easy to understand :)
				return {
					StepsToShow[lesserIndex],
					StepsToShow[lesserIndex+1],
					StepsToShow[lesserIndex+2],
					StepsToShow[greaterIndex-1],
					StepsToShow[greaterIndex]
				}
			else
				-- some of these indices in StepsToShow might be nil
				-- but that's the desired behavior for this particular use-case
				return {
					StepsToShow[greaterIndex-4],
					StepsToShow[greaterIndex-3],
					StepsToShow[greaterIndex-2],
					StepsToShow[greaterIndex-1],
					StepsToShow[greaterIndex]
				}
			end
		end
	end

	return StepsToShow
end