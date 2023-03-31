-- SM5 Favorites manager by leadbman & modified for RIO by Rhythm Lunatic
-- Modified and implemented by Crash Cringle

-- Inhibit Regular Expression magic characters ^$()%.[]*+-?)
local function strPlainText(strText)
	-- Prefix every non-alphanumeric character (%W) with a % escape character,
	-- where %% is the % escape, and %1 is original character
	return strText:gsub("(%W)","%%%1")
end

getFavoritesPath = function(player)
	local path = PROFILEMAN:GetProfileDir(ProfileSlot[PlayerNumber:Reverse()[player]+1]).."FavoriteSongs.txt";
	return path;
end

addOrRemoveFavorite = function(player)
	local profileName = PROFILEMAN:GetPlayerName(player)
	local path = getFavoritesPath(player)

	local songDir = GAMESTATE:GetCurrentSong():GetSongDir()
	local songTitle = GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
	local arr = split("/", songDir)
	local favoritesString = lua.ReadFile(path) or ""

	if not PROFILEMAN:IsPersistentProfile(player) then
		favoritesString = ""

	elseif favoritesString then
		--If song found in the player's favorites
		local checksong = string.match(favoritesString, strPlainText(arr[3].."/"..arr[4]))

		--Song found
		if checksong then
			favoritesString= string.gsub(favoritesString, strPlainText(arr[3].."/"..arr[4]).."\n", "")
			SCREENMAN:SystemMessage(songTitle.." removed from "..profileName.."'s Favorites.")
			SOUND:PlayOnce(THEME:GetPathS("", "Common invalid.ogg"))
		else
			favoritesString= favoritesString..arr[3].."/"..arr[4].."\n";
			SCREENMAN:SystemMessage(songTitle.." added to "..profileName.."'s Favorites.")
			SOUND:PlayOnce(THEME:GetPathS("", "_unlock.ogg"))
		end
	end

	-- write string to disk as txt file in player's profile directory
	local file = RageFileUtil.CreateRageFile()
	if file:Open(path, 2) then
		file:Write(favoritesString)
		file:Close()
		file:destroy()
	else
		Warn("**Could not open '" .. path .. "' to write current playing info.**")
	end
	generateFavoritesForMusicWheel()
end


generateFavoritesForMusicWheel = function()
	for pn in ivalues(GAMESTATE:GetEnabledPlayers()) do
		if PROFILEMAN:IsPersistentProfile(pn) then

			local profileName = PROFILEMAN:GetPlayerName(pn)
			local path = getFavoritesPath(pn)
			if FILEMAN:DoesFileExist(path) then
				local favs = lua.ReadFile(path)
				if favs:len() > 2 then
					-- split it on newline characters and add each line as a string
					-- to the listofavorites table
					for line in favs:gmatch("[^\r\n]+") do
						local song = SONGMAN:FindSong(line)
						if song then
							SL[ToEnumShortString(pn)].Favorites[#SL[ToEnumShortString(pn)].Favorites+1] = song
						end
						
					end
				end
			else
				SM("No favorites found at "..path)

				-- append a line like "---Lilley Pad's Favorites" to strToWrite
				local strToWrite = strToWrite .. ("---%s's Favorites\n"):format(profileName)
				if strToWrite ~= "" then
					local path = getFavoritesPath(pn)
					local file= RageFileUtil.CreateRageFile()
	
					if file:Open(path, 2) then
						file:Write(strToWrite)
						file:Close()
						file:destroy()
					else
						SM("Could not open '" .. path .. "' to write current playing info.")
					end
				end
			end
		end
	end
end
