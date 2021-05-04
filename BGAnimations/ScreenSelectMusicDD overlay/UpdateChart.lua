local difficulties = {
	'Difficulty_Beginner',
	'Difficulty_Easy',
	'Difficulty_Medium',
	'Difficulty_Hard',
	'Difficulty_Challenge',
	'Difficulty_Edit',
}

local difficultyToIndex={}
for k,v in pairs(difficulties) do
   difficultyToIndex[v]=k
end

local curDifficultyIndices = {}

local function GetStartingDifficultyIndex(playerNumber)
	local curSteps = GAMESTATE:GetCurrentSteps(playerNumber)

	if curSteps ~= nil then
		local difficulty = curSteps:GetDifficulty()
		local index = difficultyToIndex[difficulty]
		if index ~= nil then
			return index
		end
	end

	local difficulty = DDStats.GetStat(playerNumber, 'LastDifficulty')

	if difficulty ~= nil then
		local index = difficultyToIndex[difficulty]
		
		if index ~= nil then
			return index
		end
	end

	return 5
end

local function UpdateChart(playerNum, difficultyChange)
	local song = GAMESTATE:GetCurrentSong()
	if song == nil then
		return
	end

	local stepses = SongUtil.GetPlayableSteps(song)
	if #stepses == 0 then
		return
	end

	-- If we're sorted by difficulty and difficultyChange == 0,
	-- try to keep the same meter
	if GetMainSortPreference() == 6 and difficultyChange == 0 then
		local targetMeter = tonumber(NameOfGroup)

		local oldDifficulty = difficulties[curDifficultyIndices[playerNum]];
		local matchingSteps = nil
		-- Check for meter AND difficulty match
		for steps in ivalues(stepses) do
			if steps:GetMeter() == targetMeter and steps:GetDifficulty() == oldDifficulty then
				matchingSteps = steps
				break
			end
		end

		if matchingSteps == nil then
			for steps in ivalues(stepses) do
				if steps:GetMeter() == targetMeter then
					matchingSteps = steps
					break
				end
			end
		end

		if matchingSteps ~= nil then
			curDifficultyIndices[playerNum] = difficultyToIndex[matchingSteps:GetDifficulty()]
			GAMESTATE:SetCurrentSteps(playerNum, matchingSteps)
			return
		end
	end

	local oldDifficultyIndex = curDifficultyIndices[playerNum]

	if oldDifficultyIndex == nil then
		oldDifficultyIndex = GetStartingDifficultyIndex(playerNum)
	end

	local selectedSteps = nil

	local editCount = 0

	for steps in ivalues(stepses) do
		local stepsDifficulty = steps:GetDifficulty()
		local stepsDifficultyIndex = difficultyToIndex[stepsDifficulty]

		if stepsDifficulty == 'Difficulty_Edit' then
			stepsDifficultyIndex = stepsDifficultyIndex + editCount
			editCount = editCount + 1
		end

		local isValid
		if difficultyChange > 0 then
			isValid = stepsDifficultyIndex > oldDifficultyIndex
		elseif difficultyChange < 0 then
			isValid = stepsDifficultyIndex < oldDifficultyIndex
		else
			isValid = true
		end
		if isValid then
			if selectedSteps == nil then
				selectedSteps = steps
				curDifficultyIndices[playerNum] = stepsDifficultyIndex
			else
				local selectedDifficultyIndex = difficultyToIndex[selectedSteps:GetDifficulty()]
				local selectedDifference = math.abs(selectedDifficultyIndex-oldDifficultyIndex)
				local stepsDifference = math.abs(stepsDifficultyIndex-oldDifficultyIndex)

				if stepsDifference < selectedDifference then
					selectedSteps = steps
					curDifficultyIndices[playerNum] = stepsDifficultyIndex
				end
			end
		end
	end

	if selectedSteps ~= nil then
		GAMESTATE:SetCurrentSteps(playerNum, selectedSteps)
	end
end


return {
	UpdateCharts=function()
		for _, playerNum in ipairs(GAMESTATE:GetHumanPlayers()) do
			UpdateChart(playerNum, 0)
		end
	end,
	IncreaseDifficulty=function(playerNum)
		UpdateChart(playerNum, 1)
	end,
	DecreaseDifficulty=function(playerNum)
		UpdateChart(playerNum, -1)
	end,
}