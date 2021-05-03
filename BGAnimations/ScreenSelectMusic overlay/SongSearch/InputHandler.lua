local candidatesScroller = ...

local input = function(event)
    SM(event)
    if not (event and event.PlayerNumber and event.button) then
        return false
    end

    local overlay = SCREENMAN:GetTopScreen():GetChild("SongSearch")
    
    if event.type ~= "InputEventType_Release" then
		if event.GameButton == "MenuRight" or event.GameButton == "MenuDown" then
            SM("down")
            candidatesScroller:scroll_by_amount(1)
        elseif event.GameButton == "MenuLeft" or event.GameButton == "MenuUp" then
            SM("Up")
            candidatesScroller:scroll_by_amount(-1)
        elseif event.GameButton == "Start" then
            local focus = candidatesScroller:get_actor_item_at_focus_pos()
            SM(TableToString(focus))
        elseif event.GameButton == "Back" or event.GameButton == "Select" then
            overlay:queuecommand("DirectInputToEngine")
        end
    end
    return false
end

return input