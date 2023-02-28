-- Everything related to ITL 2023
-- TODO: Put the common functions in Scripts dir
-- TODO: make a hash->path function

itlPathToHash = function(songpath,player)
	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}
	local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
	local path = dir.. "itl2023Songwheel.itl"
	
	if f:Open(path, 1) then
		existing = f:Read()
		scores = JsonDecode(existing)
		if scores.pathMap[songpath] ~= nil then
			f:Close()
			return scores.pathMap[songpath]
		end
		f:Close()
	end
	
	return nil
end
		

-- Read Score info from file
itlRead = function(hash,player)
	-- Get points
	-- Get max points
	-- Get clear type
	local profile_slot = {
		[PLAYER_1] = "ProfileSlot_Player1",
		[PLAYER_2] = "ProfileSlot_Player2"
	}
	local dir = PROFILEMAN:GetProfileDir(profile_slot[player])
	local path = dir.. "itl2023Songwheel.itl"
	
	if f:Open(path, 1) then
		existing = f:Read()
		scores = JsonDecode(existing)
		
		if scores.scoreMap[hash] ~= nil then
			-- SM(scores)
			f:Close()
			return scores.scoreMap[hash]
		end
		f:Close()
	end
	
	return nil
end