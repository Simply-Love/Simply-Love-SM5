local args = ...
local isInputBlocked = args.isInputBlocked
local getParamSelected = args.getParamSelected
local setParamSelected = args.setParamSelected
local numParams = args.numParams
local searchFieldFrame = args.searchFieldFrame

return function(event)
    local blockInput = isInputBlocked()

    if not (event and event.PlayerNumber and event.button and not blockInput) then
        return false
    end

    local paramSelected = getParamSelected()

    if event.type ~= "InputEventType_Release" then
        if event.GameButton == "MenuLeft" or event.GameButton == "MenuUp" then
            -- sounds.prevRow:play()
            if paramSelected < 2 then
                paramSelected = numParams
            else
                paramSelected = paramSelected - 1
            end

            setParamSelected(paramSelected)
            searchFieldFrame:queuecommand("SelectElement")
        elseif event.GameButton == "MenuRight" or event.GameButton == "MenuDown" then
            -- sounds.nextRow:play()
            if paramSelected == numParams then
                paramSelected = 1
            else
                paramSelected = paramSelected + 1
            end

            setParamSelected(paramSelected)
            searchFieldFrame:queuecommand("SelectElement")
        elseif event.GameButton == "Start" and event.type == "InputEventType_FirstPress" then
            searchFieldFrame:queuecommand("StartElementAction")
        end
    end
end
