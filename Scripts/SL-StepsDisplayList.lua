-- FIXME: The SM5 engine does supply a StepsDisplayList class for Lua, but its scoller-esque behavior
-- is mostly hardcoded, making it difficult to ALWAYS position easy charts at a specific y-value
-- and challenge charts at a different (but equally predictable) y-value.
--
-- I wrote this code back in April 2014 as part of bda06a0eee03a22b81b35dd12968b9d386a0fea7
-- to assist in organizing and displaying available stepcharts in ScreenSelectMusic in a
-- visually predictable fashion.  I noted then that songs with multiple edit charts caused
-- the custom steps list to "behave erratically" when both players were joined.  I imagine it
-- is still a problem.  "Tachyon Alpha/Delta Max" is probably a good test case.
--
-- This code should probably be ripped out and completely replaced at this point.

function GetStepsToDisplay(AllAvailableSteps)

	--gather any edit charts into a table
	local edits = {}
	local StepsToShow = {}

	for k,chart in ipairs(AllAvailableSteps) do

		local difficulty = chart:GetDifficulty()
		if GAMESTATE:IsCourseMode() then
			local index = GetYOffsetByDifficulty(difficulty)
			StepsToShow[index] = chart
		else
			if chart:IsAnEdit() then
				edits[#edits+1] = chart
			else
				local index = GetYOffsetByDifficulty(difficulty)
				StepsToShow[index] = chart
			end
		end
	end

	-- if there are no edits we can safely bail now
	if #edits == 0 then return StepsToShow end



	--THERE ARE EDITS, OH NO!
	--HORRIBLE HANDLING/LOGIC BELOW

	for k,edit in ipairs(edits) do
		StepsToShow[5+k] = edit
	end

	local currentStepsP1, currentStepsP2
	local finalReturn = {}

	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		currentStepsP1 = GAMESTATE:GetCurrentSteps(PLAYER_1)
	end

	if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		currentStepsP2 = GAMESTATE:GetCurrentSteps(PLAYER_2)
	end

	-- if only one player is joined
	if (currentStepsP1 and not currentStepsP2) or (currentStepsP2 and not currentStepsP1) then

		if (currentStepsP1 and not currentStepsP2) then
			currentSteps = currentStepsP1
		elseif (currentStepsP2 and not currentStepsP1) then
			currentSteps = currentStepsP2
		end

		-- if the current chart is an edit
		if currentSteps:IsAnEdit() then

			local currentIndex

			-- We've used GAMESTATE:GetCurrentSteps(pn) to get the current chart
			-- use a for loop to match that "current chart" against each chart
			-- in our charts table; we want the index of the current chart
			for k,chart in pairs(StepsToShow) do
				if chart:GetChartName()==currentSteps:GetChartName() then
					currentIndex = tonumber(k)
				end
			end

			local frIndex = 5

			-- "i" will decrement here
			-- if there is one edit chart, it will assign charts to finalReturn like
			-- [5]Edit, [4]Challenge, [3]Hard, [2]Medium, [1]Easy
			--
			-- if there are two edit charts, it will assign charts to finalReturn like
			-- [5]Edit, [4]Edit, [3]Challenge, [2]Hard, [1]Medium
			-- and so on
			for i=currentIndex, currentIndex-4, -1 do
				finalReturn[frIndex] = StepsToShow[i]
				frIndex = frIndex - 1
			end

		-- else we are somewhere in the normal five difficulties
		-- and are, for all intents and purposes, uninterested in any edits for now
		-- so remove all edits from the table we're returning
		else

			for k,chart in pairs(StepsToShow) do
				if chart:IsAnEdit() then
					StepsToShow[k] = nil
				end
			end

			return StepsToShow
		end


	-- elseif both players are joined
	-- This can get complicated if P1 is on beginner and P2 is on an edit
	-- AND there is a full range of charts between
	-- we'll have to hide SOMETHING...
	elseif (currentStepsP1 and currentStepsP2) then

		if not currentStepsP1:IsAnEdit() and not currentStepsP2:IsAnEdit() then
			for k,chart in pairs(StepsToShow) do
				if chart:IsAnEdit() then
					StepsToShow[k] = nil
				end
			end
			return StepsToShow
		end


		local currentIndexP1, currentIndexP2

		-- how broad is the range of charts for this song?
		-- (where beginner=1 and edit=6+)
		-- and how far apart are P1 and P2 currently?

		for k,chart in pairs(StepsToShow) do

			if chart == currentStepsP1 then
				currentIndexP1 = k
			end

			if chart == currentStepsP2 then
				currentIndexP2 = k
			end
		end

		if (currentIndexP1 and currentIndexP2) then

			local difference = math.abs(currentIndexP1-currentIndexP2)

			local greaterIndex, lesserIndex
			if currentIndexP1 > currentIndexP2 then
				greaterIndex = currentIndexP1
				lesserIndex = currentIndexP2
			else
				greaterIndex = currentIndexP2
				lesserIndex = currentIndexP1
			end

			if difference > 4 then

				local frIndex=1
				for i=lesserIndex, lesserIndex+2 do
					finalReturn[frIndex] = StepsToShow[i]
					frIndex = frIndex + 1
				end
				for i=greaterIndex-1, greaterIndex do
					finalReturn[frIndex] = StepsToShow[i]
					frIndex = frIndex + 1
				end

			else
				local frIndex = 5
				for i=greaterIndex, greaterIndex-4, -1 do
					finalReturn[frIndex] = StepsToShow[i]
					frIndex = frIndex - 1
				end
			end
		end
	end

	return finalReturn
end