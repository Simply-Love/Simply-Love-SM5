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
	DifficultyMessageCommand=function(self)
		self:queuecommand('SongDifficulty')
	end,
	SongDifficultyCommand=function(self)
		SCREENMAN:AddNewScreenToTop("ScreenTextEntry");
		local songSearch = {
			Question = "Song Difficulty",
			MaxInputLength = 2,
			OnOK = function(SongDifficulty)
				SongDifficulty = tonumber(SongDifficulty)
				filepath = THEME:GetCurrentThemeDirectory().."Other/SongManager Difficulty.txt"
				f = RageFileUtil.CreateRageFile()
				f:Open(filepath, 2) -- 2 = write
	
				local results = {}
				for i, Song in ipairs(SONGMAN:GetAllSongs()) do
					local match = false
					for i, steps in ipairs(Song:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType())) do
						local chartDiff = steps:GetMeter()
						if chartDiff == SongDifficulty then
							match = true
						end
					end
					
					if match then
						results[#results+1] = Song
					end
				end

						-- here we create a file in the "Other/" folder in the theme for the 
						-- search. you'll have to use an external tool to clean this folder since
						-- the theme can't delete files
				if #results > 0 then
					f:PutLine("---"..SongDifficulty) -- folder name
					for i, song in ipairs(results) do
						f:PutLine(song:GetGroupName().."/"..song:GetDisplayFullTitle()) -- song
					end
					f:PutLine('')
				end
		
				f:Close()
				f:destroy()
				SONGMAN:SetPreferredSongs("Difficulty.txt")
				wheel:ChangeSort("SortOrder_Preferred")
				screen:SetNextScreenName("ScreenSelectMusic")
				screen:StartTransitioningScreen("SM_GoToNextScreen")
			end
		}
		SCREENMAN:GetTopScreen():Load(songSearch);
	end
}
	

return t






	--[[	filepath = THEME:GetCurrentThemeDirectory().."Other/SongManager Difficulty.txt"
			SONGMAN:SetPreferredSongs("Difficulty.txt")
			wheel:ChangeSort("SortOrder_Preferred")
			screen:SetNextScreenName("ScreenSelectMusic")
			screen:StartTransitioningScreen("SM_GoToNextScreen") ]]--