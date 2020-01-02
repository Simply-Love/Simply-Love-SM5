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
	local game_name = GAMESTATE:GetCurrentGame():GetName()
	-- "single" and  "versus" both map to "Single" here
	local style = "Single"

	if GAMESTATE:GetCurrentStyle():GetName() == "double" then
		style = "Double"
	end

	local steps_type = "StepsType_"..game_name:gsub("^%l", string.upper).."_"..style

	-- techno is a special case with steps_type like "StepsType_Techno_Single8"
	if game_name == "techno" then steps_type = steps_type.."8" end
	return steps_type
end