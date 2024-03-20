-- Inhibit Regular Expression magic characters ^$()%.[]*+-?)
local function strPlainText(strText)
    -- Prefix every non-alphanumeric character (%W) with a % escape character,
    -- where %% is the % escape, and %1 is original character
    return strText:gsub("(%W)", "%%%1")
end

getFavoritesPath = function(player)
    local path = PROFILEMAN:GetProfileDir(
                     ProfileSlot[PlayerNumber:Reverse()[player] + 1]) ..
                     "favorites.txt";
    return path;
end

addOrRemoveFavorite = function(player)
    local profileName = PROFILEMAN:GetPlayerName(player) == "" and ToEnumShortString(player) or PROFILEMAN:GetPlayerName(player)
    local path = getFavoritesPath(player)

    -- Only attempt to add/remove a favorite if over a valid song
    if GAMESTATE:GetCurrentSong() then
        local songDir = GAMESTATE:GetCurrentSong():GetSongDir()

        local songTitle = GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
        local arr = split("/", songDir)
        songDir = arr[3] .. "/" .. arr[4]
        local favoritesString = lua.ReadFile(path) or ""

        if not PROFILEMAN:IsPersistentProfile(player) then
            favoritesString = ""

        elseif favoritesString then
            -- If song found in the player's favorites
            local checksong = string.match(favoritesString, strPlainText(arr[3] .. "/" .. arr[4]))

            -- Song found
            if checksong then
                favoritesString = string.gsub(favoritesString, strPlainText(arr[3] .. "/" .. arr[4]) .. "\n", "")
                -- We need to now remove the song from the global list of favorites to remove
                -- any indicators in the music wheel.
                -- Add some error handling *just in case* the song doesn't technically exist for some reason
                if SONGMAN:FindSong(songDir) then
                    local song = SONGMAN:FindSong(songDir)
                    local foundIndex = FindInTable(song, SL[ToEnumShortString(player)].Favorites)
                    table.remove(SL[ToEnumShortString(player)].Favorites, foundIndex)
                end
                SCREENMAN:SystemMessage( songTitle .. " removed from " .. profileName .. "'s Favorites.")
            else
                favoritesString = favoritesString .. arr[3] .. "/" .. arr[4] .. "\n";

                SCREENMAN:SystemMessage(songTitle .. " added to " .. profileName .. "'s Favorites.")
            end
        end

        -- write string to disk as txt file in player's profile directory
        local file = RageFileUtil.CreateRageFile()
        if file:Open(path, 2) then
            file:Write(favoritesString)
            file:Close()
            file:destroy()
        else
            Warn("**Could not open '" .. path ..
                     "' to write current playing info.**")
        end
        -- Update favorites listing
        generateFavoritesForMusicWheel()
    end
end

generateFavoritesForMusicWheel = function()

    for pn in ivalues(GAMESTATE:GetEnabledPlayers()) do
        SL[ToEnumShortString(pn)].Favorites = {}
        if PROFILEMAN:IsPersistentProfile(pn) then
            local strToWrite = ""
            -- declare listofavorites inside the loop so that P1 and P2 can have independent lists
            local listofavorites = {}
            local profileName = PROFILEMAN:GetPlayerName(pn) == "" and ToEnumShortString(pn) or PROFILEMAN:GetPlayerName(pn) 
            local path = getFavoritesPath(pn)

            if FILEMAN:DoesFileExist(path) then
                local favs = lua.ReadFile(path)

                -- the txt file has been read into a string as `favs`
                -- ensure it isn't empty
                if favs:len() > 2 then

                    -- If the first line of the Favorites file doesn't begin with --- then it means 
                    -- Either the player just added their first favorite or the player's file was in legacy favorite format
                    -- In both cases let's ensure that going forward the first line is the header defining the Favorite's section Name
                    -- By default we set this to the {Profile Display Name}'s Favorites
                    if not favs:find("^---") then
                        listofavorites[1] = {
                            Name = ("%s's Favorites\n"):format(
                                             profileName),
                            Songs = {}
                        }
                    end
                    
                    -- split it on newline characters and add each line as a string
                    -- to the listofavorites table accordingly
                    for line in favs:gmatch("[^\r\n]+") do
                        --- If the line starts with "---" it's a header, so don't add it to the list of songs
                        if line:find("^---") then
                            -- You could modify the FavoriteSongs.txt file to create custom sections when using the Preferred Sort (Favorites)
                            -- Any line that begins with --- will be treated as the start of a new section
                            -- i.e. ---Cringle's Super Cool Stamina Playlist

                            -- Newly favorited songs will be added to your bottom-most section.
                            -- This is only relevant if you have modified your favorites file for custom sections.
                            listofavorites[#listofavorites + 1] = {
                                Name = line:gsub("---", ""),
                                Songs = {}
                            }
                        else
                            listofavorites[#listofavorites].Songs[#listofavorites[#listofavorites].Songs + 1] = {
                                Path = line,
                                Title = SONGMAN:FindSong(line) and SONGMAN:FindSong(line):GetDisplayMainTitle() or nil
                            }
                            SL[ToEnumShortString(pn)].Favorites[#SL[ToEnumShortString(pn)].Favorites + 1] = SONGMAN:FindSong(line)
                        end
                    end

                    -- sort alphabetically
                    -- table.sort(listofavorites, function(a, b)
                    --     return a.Name:lower() < b.Name:lower()
                    -- end)
                    for i = 1, #listofavorites do
                        table.sort(listofavorites[i].Songs, function(a, b)
                            if a.Title == nil then
                                return false
                            elseif b.Title == nil then
                                return true
                            end
                            return a.Title:lower() < b.Title:lower()
                        end)
                    end

                    -- append each group/song string to the overall strToWrite
                    for fav, _ in ivalues(listofavorites) do
                        strToWrite = strToWrite .. ("---%s\n"):format(fav.Name)
                        for song, i in ivalues(fav.Songs) do
                            strToWrite = strToWrite .. ("%s\n"):format(song.Path)
                        end
                    end
                end
            else
                -- SM("No favorites found at "..path)
            end

            if strToWrite ~= "" then
                local path = getFavoritesPath(pn)
                local file = RageFileUtil.CreateRageFile()
                if file:Open(path, 2) then
                    file:Write(strToWrite)
                    file:Close()
                    file:destroy()
                else
                    SM("Could not open '" .. path ..
                           "' to write current playing info.")
                end
            end
        end
    end
end
