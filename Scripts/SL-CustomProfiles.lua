local path =  THEME:GetThemeDisplayName() .. " UserPrefs.lua"

-- Hook called during profile load
function LoadProfileCustom(profile, dir)

	local fullFilename =  dir .. path
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

	if pn then
		if FILEMAN:DoesFileExist(fullFilename) then
			SL[pn].ActiveModifiers = LoadActor(fullFilename)
		end
	end

	return true
end

-- Hook called during profile save
function SaveProfileCustom(profile, dir)

	local fullFilename =  dir .. path
	local pn

	local Players = GAMESTATE:GetHumanPlayers()

	for player in ivalues(Players) do
		if profile == PROFILEMAN:GetProfile(player) then
			pn = ToEnumShortString(player)
		end
	end

	if pn then
		-- a generic ragefile
		local f = RageFileUtil.CreateRageFile()

		if f:Open(fullFilename, 2) then
			f:Write( "return " .. table.tostring(SL[pn].ActiveModifiers) )
		else
			local fError = f:GetError()
			Trace( "[FileUtils] Error writing to ".. fullFilename ..": ".. fError )
			f:ClearError()
		end

		f:destroy()
	end

	return true
end