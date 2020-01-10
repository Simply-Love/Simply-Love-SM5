---------------------------------------------------------------------------
-- helper function used to load tags and tagged songs
-- returns the contents of a txt file as an indexed table, split on newline
GetFileContents = function(path)
	local contents = ""

	if FILEMAN:DoesFileExist(path) then
		-- create a generic RageFile that we'll use to read the contents
		local file = RageFileUtil.CreateRageFile()
		-- the second argument here (the 1) signifies
		-- that we are opening the file in read-only mode
		if file:Open(path, 1) then
			contents = file:Read()
			file:Close()
		end
		-- destroy the generic RageFile now that we have the contents
		file:destroy()
	end

	-- split the contents of the file on newline
	-- to create a table of lines as strings
	local lines = {}
	for line in contents:gmatch("[^\r\n]+") do
		lines[#lines+1] = line
	end

	return lines
end

WriteFileContents = function(path, contents, createNew)
	local contents = contents
	local createNew = createNew or false
	if FILEMAN:DoesFileExist(path) or createNew then
		-- create a generic RageFile that we'll use to read the contents
		local file = RageFileUtil.CreateRageFile()
		-- the second argument here (the 1) signifies
		-- that we are opening the file in read-only mode
		if file:Open(path, 2) then
			file:Write(contents)
			file:Close()
		end
		-- destroy the generic RageFile now that we have the contents
		file:destroy()
	end
end

-- Splits a string by sep and returns a table
--TODO move this somewhere else
Split = function(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

---------------------------------------------------------------------------
-- a steps_type like "StepsType_Dance_Single" is needed so we can filter out steps that aren't suitable
-- (there has got to be a better way to do this...)
-- returns a String containing the steps type for the current game mode
GetStepsType = function()
	local steps_type = GAMESTATE:GetCurrentStyle():GetStepsType()
	return steps_type
end

-- Read the profile's Stats.xml and put the general data stuff into a table
-- Song and Course aren't filled in here
-- TODO this won't account for Stats prefixes
ParseStats = function(player)
	local pn = ToEnumShortString(player)
	local profileDir
	if pn == 'P1' then profileDir = 'ProfileSlot_Player1' else profileDir = 'ProfileSlot_Player2' end
	local path = PROFILEMAN:GetProfileDir(profileDir)..'Stats.xml'
	local contents = ""
	if FILEMAN:DoesFileExist(path) then
		contents = GetFileContents(path)
		-- split the contents of the file on newline
		-- to create a table of lines as strings
		local lines = {NumSongsPlayedByMeter={},NumStagesPassedByGrade={},NumSongsPlayedByStyle={},DefaultModifiers={},NumSongsPlayedByDifficulty={}}
		for line in ivalues(contents) do
			if string.find("</GeneralData>",line) then break end --stop when we get to the end of the general data. reading in all the song data crashed SM for me
			local key = string.gsub(line,"<([%w%p ]*)>[%w%p ]*</[%w%p ]*>?","%1") --look for lines with <XXX>YYY</XXX> and return XXX
			local value = string.gsub(line,"<[%w%p ]*>([%w%p ]*)</[%w%p ]*>","%1")--look for lines with <XXX>YYY</XXX> and return YYY
			--if fields are not opened and closed on the same line we need to add them in manually here TODO manually doing this seems wrong
			--NumSongsPlayedByPlayMode should get its own group but i don't care about it so... same with Song and Course 
			if string.find(key,"Meter%d+") then
				lines["NumSongsPlayedByMeter"][key] = value
			elseif string.find(key,"Tier%d+") then
				lines["NumStagesPassedByGrade"][key] = value
			elseif string.find(key,"^Style*") then
				lines["NumSongsPlayedByStyle"][key] = value
			elseif string.find(key,"^dance") then --TODO default modifiers for games besides dance won't show up here!
				lines["DefaultModifiers"][key] = value
			elseif string.find(key,"Beginner") or string.find(key,"Easy") or string.find(key,"Medium") or string.find(key,"Hard") or string.find(key,"Challenge") then
				lines["NumSongsPlayedByDifficulty"][key] = value
			elseif key ~= value then
				lines[key] = value
			end
		end
		return lines
	end
	return nil
end