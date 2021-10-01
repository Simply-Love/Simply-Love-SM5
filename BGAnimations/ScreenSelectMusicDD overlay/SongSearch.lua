local t = Def.ActorFrame{
	OnCommand=function(self)
		screen = SCREENMAN:GetTopScreen()
		if SongSearchSSMDD == true then
			SongSearchSSMDD = false
			SongSearchAnswer = nil
		end	
	end,

	SongSearchSSMDDMessageCommand = function(self)
		SCREENMAN:AddNewScreenToTop("ScreenTextEntry");
		local songSearch = {
			Question = "\nSEARCH FOR:\nSongs\nSong Artists\nStep Artists",
			MaxInputLength = 52,
			OnOK = function(answer)
				--- has to sleep in order to be able to reload because #StepmaniaMoment
				--- If the player doesn't enter any text and just presses enter just reload the screen to the normal wheel
				if answer ~= "" then
					local results = 0
					local SongsAvailable = {}
					for groupName, group in pairs (pruned_songs_by_group) do
						for song in ivalues (group) do
							SongsAvailable[#SongsAvailable+1] = song
						end
					end
					for i,song in ipairs(SongsAvailable) do
						local match = false
						local title = song:GetDisplayFullTitle():lower()
						local steps_type = GAMESTATE:GetCurrentStyle():GetStepsType()
						-- the query "xl grind" will match a song called "Axle Grinder" no matter
						-- what the chart info says
						if title:match(answer:lower()) then
							if title ~= "Random-Portal" and title ~= "RANDOM-PORTAL" then
								match = true
								results = results + 1
							end
						end
						
						-- This code works, but the code in Setup.lua does not so do not use this for the moment.
						if not match then
							for i, steps in ipairs(song:GetStepsByStepsType(steps_type)) do
								local chartStr = steps:GetAuthorCredit().." "..steps:GetDescription()
								-- the query "br xo fs" will match any song with at least one chart that
								-- has "br", "xo" and "fs" in its AuthorCredit + Description
								for word in answer:gmatch("%S+") do
									if chartStr:lower():match(word:lower()) then
										if chartStr ~= "Random-Portal" and chartStr ~= "RANDOM-PORTAL" then
											FoundChart = chartStr
											match = true
											results = results + 1
										end
									else
										match = false
										break
									end
								end
							end
						end
					end
					if results > 0 then
						SongSearchSSMDD = true
						SongSearchAnswer = answer
						SongSearchWheelNeedsResetting = true
						--SearchResultsYo = results
						self:sleep(0.25):queuecommand("ReloadScreen")
					else
						SongSearchSSMDD = false
						SongSearchAnswer = nil
						SongSearchWheelNeedsResetting = false
						SM("No songs found!")
					end
				else
					SongSearchSSMDD = false
					SongSearchAnswer = nil
					SongSearchWheelNeedsResetting = false
					self:sleep(0.25):queuecommand("ReloadScreen")
				end
				
			end,
			};
			SCREENMAN:GetTopScreen():Load(songSearch)
	end,
	
	ReloadScreenCommand=function(self)
		screen:SetNextScreenName("ScreenReloadSSMDD")
		screen:StartTransitioningScreen("SM_GoToNextScreen")
	end,
}

return t