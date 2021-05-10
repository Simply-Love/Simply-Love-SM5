local playerProfiles = {}

local function getPlayerProfileDir(playerNum)
	local profileSlots = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}

	if not profileSlots[playerNum] then
		return nil
	end

	local dir = PROFILEMAN:GetProfileDir(profileSlots[playerNum])

	return dir .. 'DDStats.txt'
end

local function loadProfile(playerNum)
	dir = getPlayerProfileDir(playerNum)

	if dir == nil then
		return {}
	end

	if not FILEMAN:DoesFileExist(dir) then
		return {}
	end

	file = RageFileUtil:CreateRageFile()
	file:Open(dir, 1)
	local statsStr = file:Read()
	file:Close()
	file:destroy()

	local stats = {}

	while true do
		local equalsIndex, _ = statsStr:find('=')
		if equalsIndex == nil then break end

		local key = statsStr:sub(1, equalsIndex-1)
		statsStr = statsStr:sub(equalsIndex+1)

		local newlineIndex, _ = statsStr:find('\n')
		if newlineIndex == nil then
			newlineIndex = statsStr:len()
		end

		local value = statsStr:sub(1, newlineIndex-1)
		statsStr = statsStr:sub(newlineIndex+1)

		stats[key] = value
	end

	return stats
end

DDStats = {
	GetStat = function(playerNum, statName)
		local profileId = PROFILEMAN:GetProfile(playerNum):GetGUID()
		if playerProfiles[profileId] == nil then
			playerProfiles[profileId] = loadProfile(playerNum)
		end
		return playerProfiles[profileId][statName]
	end,
	SetStat = function(playerNum, statName, value)
		local profileId = PROFILEMAN:GetProfile(playerNum):GetGUID()
		if playerProfiles[profileId] == nil then
			playerProfiles[profileId] = loadProfile(playerNum)
		end
		playerProfiles[profileId][statName] = value
	end,
	Save = function(playerNum)
		local profileId = PROFILEMAN:GetProfile(playerNum):GetGUID()
		dir = getPlayerProfileDir(playerNum)

		if dir == nil then
			SCREENMAN:SystemMessage('Failed to save DDStats for ' .. playerNum .. '!')
			return
		end

		local keyValuePairs = {}
		for key, value in pairs(playerProfiles[profileId]) do
			keyValuePairs[#keyValuePairs+1] = {
				key=key,
				value=value,
			}
		end

		table.sort(keyValuePairs, function(a, b)
			return a.key < b.key
		end)

		file = RageFileUtil:CreateRageFile()
		file:Open(dir, 2)
		for keyValuePair in ivalues(keyValuePairs) do
			file:Write(keyValuePair.key .. '=' .. keyValuePair.value .. '\n')
		end
		file:Close()
		file:destroy()
	end,
}
