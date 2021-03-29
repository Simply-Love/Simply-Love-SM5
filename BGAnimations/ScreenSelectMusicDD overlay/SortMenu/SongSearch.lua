local wheel
local screen

t = Def.ActorFrame{
	OnCommand=function(self)
		-- we are going to be using the screen and the wheel,
		-- but we will need them when the top screen is not ScreenSelectMusic
		-- so we have to get them here before any search happens
		screen = SCREENMAN:GetTopScreen()
		wheel = screen:GetMusicWheel()
	end,
	FilterMessageCommand=function(self)
		self:queuecommand('SearchSong')
	end,
	SearchSongCommand=function(self)
                SCREENMAN:AddNewScreenToTop("ScreenTextEntry");
                local songSearch = {
                        Question = "Song name",
                        MaxInputLength = 255,
                        OnOK = function(answer)
				-- A song is a match if either the whole search query is a substring of
				-- its full title (title+subtitle) or if each word in the search query
				-- is found in at least one of its charts' AuthorCredit + Description
				-- This search is case insensitive
                                local results = {}
                                for i, Song in ipairs(SONGMAN:GetAllSongs()) do
					local match = false
                                        title = Song:GetDisplayFullTitle():lower()
					-- the query "xl grind" will match a song called "Axle Grinder" no matter
					-- what the chart info says
                                        if title:match(answer:lower()) then
                                                results[#results+1] = Song
						match = true
                                        end
					if not match then
						for i, steps in ipairs(Song:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType())) do
							local chartStr = steps:GetAuthorCredit().." "..steps:GetDescription()
							match = true
							-- the query "br xo fs" will match any song with at least one chart that
							-- has "br", "xo" and "fs" in its AuthorCredit + Description
							for word in answer:gmatch("%S+") do
								if not chartStr:lower():match(word:lower()) then
									match = false
									break
								end
							end
							if match then
								results[#results+1] = Song
							end
						end
					end
                                end

				-- here we create a file in the "Other/" folder in the theme for the 
				-- search. you'll have to use an external tool to clean this folder since
				-- the theme can't delete files
                                if #results > 0 then
                                        filepath = THEME:GetCurrentThemeDirectory().."Other/SongManager SearchResults.txt"
                                        f = RageFileUtil.CreateRageFile()
                                        f:Open(filepath, 2) -- 2 = write
                                        f:PutLine("---Search Results") -- folder name
                                        for i, song in ipairs(results) do
                                                f:PutLine(song:GetGroupName().."/"..song:GetDisplayFullTitle()) -- song
                                        end
                                        f:Close()
                                        f:destroy()
                                        SONGMAN:SetPreferredSongs("SearchResults.txt")
                                        wheel:ChangeSort("SortOrder_Preferred")
					screen:SetNextScreenName("ScreenSelectMusic")
					screen:StartTransitioningScreen("SM_GoToNextScreen")
                                end
                        end,
                };
                SCREENMAN:GetTopScreen():Load(songSearch);
        end,
}

return t