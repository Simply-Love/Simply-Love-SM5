local path =  "UserPrefs/" .. THEME:GetThemeDisplayName() .. "/"

-- Hook called during profile load
function LoadProfileCustom(profile, dir)

	local PrefPath =  dir .. path
	local pn

	-- we've been passed a profile object as the variable "profile"
	-- see if it matches against anything returned by PROFILEMAN:GetProfile(pn)
	local Players = GAMESTATE:GetHumanPlayers()

	if Players then
		for player in ivalues(Players) do
			if profile == PROFILEMAN:GetProfile(player) then
				pn = ToEnumShortString(player)
			end
		end
	end


	-- ...and then, if a player profile exists, read .cfg files from it
	if pn then

		local f = RageFileUtil.CreateRageFile()
		local setting

		for k,v in pairs( SL[pn].ActiveModifiers ) do

			local fullFilename = PrefPath..k..".cfg"

			if f:Open(fullFilename,1) then

				-- RageFile's Read() method always returns a string
				setting = f:Read()

				-- but maybe we don't want a string; attempt to convert
				if setting == "true" then setting = true
				elseif setting == "false" then setting = false
				end

				SL[pn].ActiveModifiers[k] = setting
			else
				local fError = f:GetError()
				Trace( "[FileUtils] Error reading ".. fullFilename ..": ".. fError )
				f:ClearError()
			end
		end

		-- don't destroy the RageFile until we've tried to load all custom options
		-- and set them to the env table to make them accessible from anywhere in SM
		f:destroy()
	end

	return true
end

-- Hook called during profile save
function SaveProfileCustom(profile, dir)

	local PrefPath =  dir .. path
	local pn

	local Players = GAMESTATE:GetHumanPlayers()

	for player in ivalues(Players) do
		if profile == PROFILEMAN:GetProfile(player) then
			pn = ToEnumShortString(player)
		end
	end

	if pn then
		-- a generic ragefile (?)
		local f = RageFileUtil.CreateRageFile()

		-- then loop through the prefs, saving one .cfg file per available setting
		-- if a particular value is nil, nothing gets written
		for k,v in pairs( SL[pn].ActiveModifiers ) do

			local fullFilename = PrefPath..k..".cfg"

			if f:Open(fullFilename, 2) then

				-- if a setting exists (it should) write that to the .cfg file
				if v ~= nil then
					f:Write( tostring( v ) )
				end
			else
				local fError = f:GetError()
				Trace( "[FileUtils] Error writing to ".. fullFilename ..": ".. fError )
				f:ClearError()
			end
		end

		-- again, don't destroy the file until after we're done looping
		-- through all possible custom options
		f:destroy()
	end

	return true
end