local sort_wheel = ...

-- local favorites_set = false

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
				MESSAGEMAN:Broadcast('Sort', { order = focus.sort_by })
				MESSAGEMAN:Broadcast('ResetHeaderText')
				overlay:queuecommand("DirectInputToEngine")

				-- the player wants to change modes, for example from ITG to FA+
			elseif focus.kind == "ChangeMode" then
				SL.Global.GameMode = focus.change
				for player in ivalues(GAMESTATE:GetHumanPlayers()) do
					ApplyMods(player)
				end
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
				if GAMESTATE:GetCurrentGame():GetName() == "techno" then new_style = new_style .. "8" end
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
						local profileSlot = {
							["PlayerNumber_P1"] = "ProfileSlot_Player1",
							["PlayerNumber_P2"] = "ProfileSlot_Player2"
						}
						local profileDir = PROFILEMAN:GetProfileDir(profileSlot[event.PlayerNumber])
						local path = profileDir .. "favorites.txt"

						local f = RageFileUtil:CreateRageFile()
						local songPath = GAMESTATE:GetCurrentSong():GetSongDir():gsub("/Songs/", ""):sub(1, -2)
						local songTitle = GAMESTATE:GetCurrentSong():GetDisplayMainTitle()
						local exists = false

						if not FILEMAN:DoesFileExist(path) then
							if f:Open(path, 2) then
								f:Write(songPath)
							end
						else
							title_to_path = {}
							titles = {}

							not_found_paths = {}

							if f:Open(path, 1) then
								favorites_str = f:Read()
								f:Close()
								for foundPath in favorites_str:gmatch("[^\r\n]+") do
									if #foundPath > 0 then
										if foundPath == songPath then
											-- Path already exists in favorites, that means we are
											-- instead removing it from favorites.
											exists = true
										else
											local song = SONGMAN:FindSong(foundPath)
											if song ~= nil then
												foundTitle = song:GetDisplayMainTitle()
												table.insert(titles, foundTitle)
												if title_to_path[foundTitle] == nil then
													title_to_path[foundTitle] = {}
												end
												table.insert(title_to_path[foundTitle], foundPath)
											else
												-- Still keep track of the paths not found. It's
												-- possible someone is playing with a USB on a different
												-- machine which might not have all the content.
												table.insert(not_found_paths, foundPath)
											end
										end
									end
								end

								-- If the song path was not found in the favorites, then we are
								-- adding it.
								if not exists then
									table.insert(titles, songTitle)
									if title_to_path[songTitle] == nil then
										title_to_path[songTitle] = {}
									end
									table.insert(title_to_path[songTitle], songPath)
								end

								-- Sort the titles and paths so that we always write the
								-- favorites in a deterministic order.
								table.sort(titles)
								for k,v in pairs(title_to_path) do
									table.sort(v)
								end
							end

							local contents = ""
							for title in ivalues(titles) do
								for path in ivalues(title_to_path[title]) do
									if #contents > 0 then
										contents = contents .. "\n"
									end
									contents = contents .. path
								end
							end

							for path in ivalues(not_found_paths) do
								if #contents > 0 then
									contents = contents .. "\n"
								end
								contents = contents .. path
							end

							if f:Open(path, 2) then
								f:Write(contents)
							end
							MESSAGEMAN:Broadcast("FavoritesChanged", {Player=event.PlayerNumber, SongPath=songPath, Remove=exists} )
						end

						-- Nudge the wheel a bit so that that the icon is correctly updated.
						screen:GetMusicWheel():Move(1)
						screen:GetMusicWheel():Move(-1)
						screen:GetMusicWheel():Move(0)

						f:Close()
						f:destroy()
					end
				elseif focus.new_overlay == "Favorites" then
					local profileSlot = {
						["PlayerNumber_P1"] = "ProfileSlot_Player1",
						["PlayerNumber_P2"] = "ProfileSlot_Player2"
					}
					local profileDir = PROFILEMAN:GetProfileDir(profileSlot[event.PlayerNumber])
					local pn = ToEnumShortString(event.PlayerNumber)
					local path = profileDir .. "favorites.txt"

					local favorites_set = false
					if FILEMAN:DoesFileExist(path) then
						-- The 2nd argument, isAbsolute, is ITGmania 0.6.0 specific. It
						-- allows absolute paths to be used for the favorites file which is
						-- how it works to load from the profile directory.
						SONGMAN:SetPreferredSongs(path, --[[isAbsolute=]]true)
						favorites_set = true
					else
						SM(ToEnumShortString(event.PlayerNumber).." has no favorites!")
					end

					if favorites_set then
						MESSAGEMAN:Broadcast("SetHeaderText", { Text = pn.."  Favorites" })
						-- Ideally the below should just work, but because of some engine bug,
						-- we need to reload the screen for the favorites to be correctly
						-- loaded consistently.
						-- TODO(teejusb): Fix this in the engine.
						-- MESSAGEMAN:Broadcast("Sort", { order = "Preferred" })
						
						screen:GetMusicWheel():ChangeSort("SortOrder_Preferred")
						screen:SetNextScreenName("ScreenSelectMusic")
						screen:StartTransitioningScreen("SM_GoToNextScreen")

					end
					overlay:queuecommand("DirectInputToEngine")
				end
			end

		elseif event.GameButton == "Back" or event.GameButton == "Select" then
			overlay:queuecommand("DirectInputToEngine")
		end
	end
	return false
end
return input
