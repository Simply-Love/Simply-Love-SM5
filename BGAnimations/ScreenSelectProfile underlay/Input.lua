local args = ...
local af = args.af
local scrollers = args.Scrollers
local profile_data = args.ProfileData
local nsj = GAMESTATE:GetNumSidesJoined()
local IsP1Ready = false
local IsP2Ready = false

-- we need to calculate how many dummy rows the scroller was "padded" with
-- (to achieve the desired transform behavior since I am not mathematically
-- perspicacious enough to have done so otherwise).
-- we'll use index_padding to get the correct info out of profile_data.
local index_padding = 0
for profile in ivalues(profile_data) do
	if profile.index == nil or profile.index <= 0 then
		index_padding = index_padding + 1
	end
end

local Handle = {}

Handle.Start = function(event)
	local topscreen = SCREENMAN:GetTopScreen()

	-- if the input event came from a side that is not currently registered as a human player, we'll either
	-- want to reject the input (we're in Pay mode and there aren't enough credits to join the player),
	-- or we'll use ScreenSelectProfile's inscrutably custom SetProfileIndex() method to join the player.
	if not GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
		-- pass -1 to SetProfileIndex() to join that player
		-- see ScreenSelectProfile.cpp for details
		nsj = 2
		topscreen:SetProfileIndex(event.PlayerNumber, -1)
	else
		if nsj == 1 then
			-- we only bother checking scrollers to see if both players are
			-- trying to choose the same profile if there are scrollers because
			-- there are local profiles.  If there are no local profiles, there are
			-- no scrollers to compare.
			if PROFILEMAN:GetNumLocalProfiles() > 0
			-- and if both players have joined and neither is using a memorycard
			and #GAMESTATE:GetHumanPlayers() > 1 and not GAMESTATE:IsAnyHumanPlayerUsingMemoryCard() then
				-- and both players are trying to choose the same profile
				if scrollers[PLAYER_1]:get_info_at_focus_pos().index == scrollers[PLAYER_2]:get_info_at_focus_pos().index
				-- and that profile they are both trying to choose isn't [GUEST]
				and scrollers[PLAYER_1]:get_info_at_focus_pos().index ~= 0 then
					-- broadcast an InvalidChoice message to play the "Common invalid" sound
					-- and "shake" the playerframe for the player that just pressed start
					MESSAGEMAN:Broadcast("InvalidChoice", {PlayerNumber=event.PlayerNumber})
					return
				end
			end

			-- otherwise, play the StartButton sound
			MESSAGEMAN:Broadcast("StartButton")
			-- and queue the OffCommand for the entire screen
			topscreen:queuecommand("Off"):sleep(0.4)
		elseif nsj == 2 then
			if event.PlayerNumber == "PlayerNumber_P1" and IsP1Ready == false then
				IsP1Ready = true
				MESSAGEMAN:Broadcast("StartButton")
				MESSAGEMAN:Broadcast("P1ProfileReady")
			elseif  event.PlayerNumber == "PlayerNumber_P2" and IsP2Ready == false then
				IsP2Ready = true
				MESSAGEMAN:Broadcast("StartButton")
				MESSAGEMAN:Broadcast("P2ProfileReady")
			end
			if IsP1Ready and IsP2Ready then
				-- we only bother checking scrollers to see if both players are
			-- trying to choose the same profile if there are scrollers because
			-- there are local profiles.  If there are no local profiles, there are
			-- no scrollers to compare.
			if PROFILEMAN:GetNumLocalProfiles() > 0
			-- and if both players have joined and neither is using a memorycard
			and #GAMESTATE:GetHumanPlayers() > 1 and not GAMESTATE:IsAnyHumanPlayerUsingMemoryCard() then
				-- and both players are trying to choose the same profile
				if scrollers[PLAYER_1]:get_info_at_focus_pos().index == scrollers[PLAYER_2]:get_info_at_focus_pos().index
				-- and that profile they are both trying to choose isn't [GUEST]
				and scrollers[PLAYER_1]:get_info_at_focus_pos().index ~= 0 then
					-- broadcast an InvalidChoice message to play the "Common invalid" sound
					-- and "shake" the playerframe for the player that just pressed start
					if event.PlayerNumber == "PlayerNumber_P1" then
						IsP1Ready = false
						MESSAGEMAN:Broadcast("P1ProfileUnReady")
					elseif event.PlayerNumber == "PlayerNumber_P2" then
						IsP2Ready = false
						MESSAGEMAN:Broadcast("P2ProfileUnReady")
					end
					MESSAGEMAN:Broadcast("InvalidChoice", {PlayerNumber=event.PlayerNumber})
					return
				end
			end

			-- otherwise, play the StartButton sound
			MESSAGEMAN:Broadcast("StartButton")
			-- and queue the OffCommand for the entire screen
			topscreen:queuecommand("Off"):sleep(0.4)
			end
		end
	end
end
Handle.Center = Handle.Start


Handle.MenuLeft = function(event)
	-- don't allow player to change profiles if they're ready.
	if event.PlayerNumber == "PlayerNumber_P1" and IsP1Ready then return end
	if event.PlayerNumber == "PlayerNumber_P2" and IsP2Ready then return end
	
	if GAMESTATE:IsHumanPlayer(event.PlayerNumber) and MEMCARDMAN:GetCardState(event.PlayerNumber) == 'MemoryCardState_none' then
		local info = scrollers[event.PlayerNumber]:get_info_at_focus_pos()
		local index = type(info)=="table" and info.index or 0

		if index - 1 >= 0 then
			MESSAGEMAN:Broadcast("DirectionButton")
			scrollers[event.PlayerNumber]:scroll_by_amount(-1)

			local data = profile_data[index+index_padding-1]
			local frame = af:GetChild(ToEnumShortString(event.PlayerNumber) .. 'Frame')
			frame:GetChild("SelectedProfileText"):settext(data and data.displayname or "")
			frame:GetChild("ReadyText"):settext(data and data.displayname.."\nREADY" or "READY"):y(data and 45 or 40)
			frame:playcommand("Set", data)
		end
	end
end
Handle.MenuUp = Handle.MenuLeft
Handle.DownLeft = Handle.MenuLeft

Handle.MenuRight = function(event)
	-- don't allow player to change profiles if they're ready.
	if event.PlayerNumber == "PlayerNumber_P1" and IsP1Ready then return end
	if event.PlayerNumber == "PlayerNumber_P2" and IsP2Ready then return end
	
	if GAMESTATE:IsHumanPlayer(event.PlayerNumber) and MEMCARDMAN:GetCardState(event.PlayerNumber) == 'MemoryCardState_none' then
		local info = scrollers[event.PlayerNumber]:get_info_at_focus_pos()
		local index = type(info)=="table" and info.index or 0

		if index+1 <= PROFILEMAN:GetNumLocalProfiles() then
			MESSAGEMAN:Broadcast("DirectionButton")
			scrollers[event.PlayerNumber]:scroll_by_amount(1)

			local data = profile_data[index+index_padding+1]
			local frame = af:GetChild(ToEnumShortString(event.PlayerNumber) .. 'Frame')
			frame:GetChild("SelectedProfileText"):settext(data and data.displayname or "")
			frame:GetChild("ReadyText"):settext(data and data.displayname.."\nREADY" or "READY"):y(data and 45 or 40)
			frame:playcommand("Set", data)
		end
	end
end
Handle.MenuDown = Handle.MenuRight
Handle.DownRight = Handle.MenuRight

Handle.Back = function(event)
	if GAMESTATE:GetNumPlayersEnabled()==0 then
		SCREENMAN:GetTopScreen():Cancel()
	elseif event.PlayerNumber == "PlayerNumber_P1" and IsP1Ready then
		IsP1Ready = false
		MESSAGEMAN:Broadcast("BackButton")
		MESSAGEMAN:Broadcast("P1ProfileUnReady")
	elseif event.PlayerNumber == "PlayerNumber_P2" and IsP2Ready then
		IsP2Ready = false
		MESSAGEMAN:Broadcast("BackButton")
		MESSAGEMAN:Broadcast("P2ProfileUnReady")
	elseif not IsP1Ready and not IsP2Ready then
		nsj = 1
		MESSAGEMAN:Broadcast("BackButton")
		-- ScreenSelectProfile:SetProfileIndex() will interpret -2 as
		-- "Unjoin this player and unmount their USB stick if there is one"
		-- see ScreenSelectProfile.cpp for details
		SCREENMAN:GetTopScreen():SetProfileIndex(event.PlayerNumber, -2)
	end
end


local InputHandler = function(event)
	if not event or not event.button then return false end

	if event.type ~= "InputEventType_Release" then
		if Handle[event.GameButton] then Handle[event.GameButton](event) end
	end
end

return InputHandler