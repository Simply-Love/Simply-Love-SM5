local af = ...

local AutoStyle = ThemePrefs.Get("AutoStyle")
local Handle = {}

Handle.Start = function(event)
	MESSAGEMAN:Broadcast("StartButton")
	if not GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
		SCREENMAN:GetTopScreen():SetProfileIndex(event.PlayerNumber, -1)
	else
		SCREENMAN:GetTopScreen():Finish()
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