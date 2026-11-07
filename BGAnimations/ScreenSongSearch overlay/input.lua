return function(event)
    if not (event and event.PlayerNumber and event.button) then
        return false
    end

    if event.type ~= "InputEventType_Release" then
        if event.GameButton == "Back" then
            SCREENMAN:GetTopScreen()
                :StartTransitioningScreen("SM_GoToPrevScreen")
        end
    end
end
