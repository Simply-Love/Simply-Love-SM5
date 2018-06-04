local af = ...

local AutoStyle = ThemePrefs.Get("AutoStyle")
local mpn = GAMESTATE:GetMasterPlayerNumber()

local Handle = {}

Handle.Start = function(event)
	local topscreen = SCREENMAN:GetTopScreen()

	if not GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
		topscreen:SetProfileIndex(event.PlayerNumber, -1)
	else

		-- if both players have joined
		if #GAMESTATE:GetHumanPlayers() > 1 then
			-- and both players are trying to choose the same profile
			if topscreen:GetProfileIndex(PLAYER_1) == topscreen:GetProfileIndex(PLAYER_2)
			and not (MEMCARDMAN:GetCardState(PLAYER_1)~='MemoryCardState_none' and MEMCARDMAN:GetCardState(PLAYER_2)~='MemoryCardState_none') then
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
	end
end
Handle.Center = Handle.Start


Handle.MenuLeft = function(event)
	if GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
		local index = SCREENMAN:GetTopScreen():GetProfileIndex(event.PlayerNumber)

		if index > 1 then
			if SCREENMAN:GetTopScreen():SetProfileIndex(event.PlayerNumber, index - 1 ) then
				MESSAGEMAN:Broadcast("DirectionButton")
				af:queuecommand('UpdateInternal2')
			end
		end
	end
end
Handle.MenuUp = Handle.MenuLeft
Handle.DownLeft = Handle.MenuLeft

Handle.MenuRight = function(event)
	if GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
		local index = SCREENMAN:GetTopScreen():GetProfileIndex(event.PlayerNumber)

		if index > 0 then
			if SCREENMAN:GetTopScreen():SetProfileIndex(event.PlayerNumber, index + 1 ) then
				MESSAGEMAN:Broadcast("DirectionButton")
				af:queuecommand('UpdateInternal2')
			end
		end
	end
end
Handle.MenuDown = Handle.MenuRight
Handle.DownRight = Handle.MenuRight

Handle.Back = function(event)
	if GAMESTATE:GetNumPlayersEnabled()==0 then
		SCREENMAN:GetTopScreen():Cancel()
	else
		MESSAGEMAN:Broadcast("BackButton")
		SCREENMAN:GetTopScreen():SetProfileIndex(event.PlayerNumber, -2)
	end
end


local InputHandler = function(event)
	if not event or not event.button then return false end
	if (AutoStyle=="single" or AutoStyle=="double") and event.PlayerNumber ~= mpn then return false	end

	if event.type == "InputEventType_FirstPress" then
		if Handle[event.GameButton] then Handle[event.GameButton](event) end
	end
end

return InputHandler