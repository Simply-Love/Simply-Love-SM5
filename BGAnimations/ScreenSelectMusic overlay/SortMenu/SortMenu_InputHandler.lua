local sort_wheel = ...

local favesLoaded = false
-- this handles user input while in the SortMenu
local input = function(event)
	if not (event and event.PlayerNumber and event.button) then
		return false
	end
	SOUND:StopMusic()
	local screen   = SCREENMAN:GetTopScreen()
	local overlay  = screen:GetChild("Overlay")
	local sortmenu = overlay:GetChild("SortMenu")
	if event.type ~= "InputEventType_Release" then
		if event.GameButton == "MenuRight" or event.GameButton == "MenuDown" then
			sort_wheel:scroll_by_amount(1)
			sortmenu:GetChild("change_sound"):play()
		elseif event.GameButton == "MenuLeft" or event.GameButton == "MenuUp" then
			sort_wheel:scroll_by_amount(-1)
			sortmenu:GetChild("change_sound"):play()
		elseif event.GameButton == "Start" then
			sortmenu:GetChild("start_sound"):play()
			local focus = sort_wheel:get_actor_item_at_focus_pos()
			if focus.kind == "SortBy" then
				MESSAGEMAN:Broadcast('Sort',{order=focus.sort_by})
				overlay:queuecommand("DirectInputToEngine")

			-- the player wants to change modes, for example from ITG to FA+
			elseif focus.kind == "ChangeMode" then
				SL.Global.GameMode = focus.change
				SetGameModePreferences()
				THEME:ReloadMetrics()
				-- Broadcast that the SL GameMode has changed
				-- SSM's header will update its text and highscore names in the PaneDisplays will refresh
				MESSAGEMAN:Broadcast("SLGameModeChanged")
				-- Reload the SortMenu's available options and queue "DirectInputToEngine"
				-- to return input from Lua back to the engine and hide the SortMenu from view
				sortmenu:playcommand("AssessAvailableChoices"):queuecommand("DirectInputToEngine")
				-- the player is switching to casual mode which uses a different SelectMusic screen
				if focus.change == "Casual" then
					screen:SetNextScreenName("ScreenSelectMusicCasual")
					screen:StartTransitioningScreen("SM_GoToNextScreen")
				end
			-- the player wants to change styles, for example from single to double
			elseif focus.kind == "ChangeStyle" then
				-- If the MenuTimer is in effect, make sure to grab its current
				-- value before reloading the screen.
				if PREFSMAN:GetPreference("MenuTimer") then
					overlay:playcommand("ShowPressStartForOptions")
				end
				-- Get the style we want to change to
				local new_style = focus.change:lower()
				-- accommodate techno game
				if GAMESTATE:GetCurrentGame():GetName()=="techno" then new_style = new_style.."8" end
				-- set it in the engine
				GAMESTATE:SetCurrentStyle(new_style)
				-- Make sure we cancel the request if it's active before trying to switch screens.
				-- This prevents the "Stale ActorFrame" error.
				overlay:GetChild("PaneDisplayMaster"):GetChild("GetScoresRequester"):playcommand("Cancel")
				-- finally, reload the screen
				screen:SetNextScreenName("ScreenReloadSSM")
				screen:StartTransitioningScreen("SM_GoToNextScreen")
			elseif focus.new_overlay then
				if focus.new_overlay == "TestInput" then
					sortmenu:queuecommand("DirectInputToTestInput")
				elseif focus.new_overlay == "Leaderboard" then
					-- The leaderboard entry is removed altogether if the service isn't available.
					sortmenu:queuecommand("DirectInputToLeaderboard")
				elseif focus.new_overlay == "SongSearch" then
					-- Direct the input back to the engine, so that the ScreenTextEntry overlay
					-- works correctly.
					overlay:queuecommand("DirectInputToEngineForSongSearch")
				elseif focus.new_overlay == "LoadNewSongs" then
					-- Make sure we cancel the request if it's active before trying to switch screens.
					-- This prevents the "Stale ActorFrame" error.
					overlay:GetChild("PaneDisplayMaster"):GetChild("GetScoresRequester"):playcommand("Cancel")
					overlay:playcommand("DirectInputToEngine")
					SCREENMAN:SetNewScreen("ScreenReloadSongsSSM")
				elseif focus.new_overlay == "ViewDownloads" then
					-- Make sure we cancel the request if it's active before trying to switch screens.
					-- This prevents the "Stale ActorFrame" error.
					overlay:GetChild("PaneDisplayMaster"):GetChild("GetScoresRequester"):playcommand("Cancel")
					overlay:playcommand("DirectInputToEngine")
					SCREENMAN:SetNewScreen("ScreenViewDownloads")
				elseif focus.new_overlay == "SwitchProfile" then
					SL.Global.FastProfileSwitchInProgress = true

					-- Make sure we save any currently active profiles before potentially switching
					-- to different ones.
					GAMESTATE:SaveProfiles()
					PROFILEMAN:SaveMachineProfile()

					overlay:queuecommand("DirectInputToEngineForSelectProfile")
				elseif focus.new_overlay == "AddFavorite" then
					overlay:queuecommand("DirectInputToEngine")
					if GAMESTATE:GetCurrentSong() ~= nil then
						local playerName = PROFILEMAN:GetPlayerName(event.PlayerNumber)
						
						local dir = THEME:GetCurrentThemeDirectory() .. "Other/"
						local path = dir.. "SongManager " .. playerName .. "-favorites.txt"
						local f = RageFileUtil:CreateRageFile()
						local songPath = GAMESTATE:GetCurrentSong():GetSongDir():gsub("/Songs/", "")
						local songName = GAMESTATE:GetCurrentSong():GetMainTitle()
						
						if not FILEMAN:DoesFileExist(path) then
							if f:Open(path, 2) then
								f:Write(songPath)
								SM("Added " .. songName .. " to favorites!")
							end		
						else
							if f:Open(path, 1) then
								faves = f:Read()
								f:Close()
								
								local exists = false 
								local updated = ""
								for line in faves:gmatch('[^\r\n]+') do
									if string.len(line) > 0 then
										if line:find(songPath,1,true) ~= nil then
											exists = true
										else
											updated = updated .. line .. "\n"
										end
									end
								end
								if not exists then
									if f:Open(path, 2) then
										f:Write(updated .. songPath .. "\n")
										SM("Added " .. songName .. " to favorites!")
									end
								else
									if f:Open(path, 2) then
										f:Write(updated)
										SM("Removed " .. songName .. " from favorites")
									end
								end
							end
						end
						
						screen:GetMusicWheel():Move(1)
						screen:GetMusicWheel():Move(-1)
						screen:GetMusicWheel():Move(0)
						
						f:Close()
						f:destroy()
					else
						SM("Only songs can be favorited!")
					end
				elseif focus.new_overlay == "Favorites" then
					overlay:queuecommand("DirectInputToEngine")
					
					if GAMESTATE:GetSortOrder() == "SortOrder_Preferred" then favesLoaded = true end
					
					local playerName = PROFILEMAN:GetPlayerName(event.PlayerNumber)
					SONGMAN:SetPreferredSongs(playerName .. "-favorites.txt")
					screen:GetMusicWheel():ChangeSort("SortOrder_Preferred")
					if not favesLoaded then favesLoaded = true else
						screen:SetNextScreenName("ScreenSelectMusic")
						screen:StartTransitioningScreen("SM_GoToNextScreen")
					end
				end
			end

		elseif event.GameButton == "Back" or event.GameButton == "Select" then
			overlay:queuecommand("DirectInputToEngine")
		end
	end
	return false
end
return input
