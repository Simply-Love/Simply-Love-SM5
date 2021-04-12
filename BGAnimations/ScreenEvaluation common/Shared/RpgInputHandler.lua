-- This handles user input while in displaying the RPG information.
local function input(event)
	if not (event and event.PlayerNumber and event.button) then
		return false
	end
	-- Don't handle input for a non-joined player.
	if not GAMESTATE:IsSideJoined(event.PlayerNumber) then
		return false
	end

	local screen   = SCREENMAN:GetTopScreen()
	local overlay  = screen:GetChild("Overlay"):GetChild("ScreenEval Common")

	-- Broadcast event data using MESSAGEMAN for the RPG overlay to listen for.
	if event.type ~= "InputEventType_Repeat" then
		MESSAGEMAN:Broadcast("RpgInputEvent", event)
	end

	-- Pressing Start or Back (typically Esc on a keyboard) will queue "DirectInputToEngine"
	-- but only if the event.type is not a Release.
	if (event.GameButton == "Start" or event.GameButton == "Back") and event.type ~= "InputEventType_Release" then
        overlay:GetChild("AutoSubmitMaster"):GetChild("RpgOverlay"):visible(false)
		overlay:queuecommand("DirectInputToEngine")
	end

	return false
end

return input