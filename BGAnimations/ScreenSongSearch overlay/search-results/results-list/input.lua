local args = ...
local isInputBlocked = args.isInputBlocked
local scroller = args.scroller
local resultsFrame = args.resultsFrame
local getCurrentSelectedResult = args.getCurrentSelectedResult
local setCurrentSelectedResult = args.setCurrentSelectedResult
local scheduleSongPreview = args.scheduleSongPreview

return function(event)
    local blockInput = isInputBlocked()

    if not (event and event.PlayerNumber and event.button and not blockInput) then
        return false
    end

    local selElementIndex, focusIndex = getCurrentSelectedResult()

    if event.type ~= "InputEventType_Release" then
        local numTotalItems = #scroller.info_set
        local maxRows = scroller.num_items

        if event.GameButton == "MenuRight" or event.GameButton == "MenuDown" then
            if selElementIndex < numTotalItems then
                focusIndex = scroller.focus_pos + 1
                selElementIndex = selElementIndex + 1

                if focusIndex <= maxRows then
                    scroller.focus_pos = focusIndex
                end

                setCurrentSelectedResult(selElementIndex, focusIndex)

                scroller:scroll_by_amount(focusIndex <= maxRows and 0 or 1)
            else
                scroller.focus_pos = 1
                scroller:scroll_by_amount(selElementIndex > maxRows and (maxRows - selElementIndex) or 0)
                selElementIndex = 1
                focusIndex = 1
                setCurrentSelectedResult(selElementIndex, focusIndex)
            end

            scheduleSongPreview(resultsFrame)
        elseif event.GameButton == "MenuLeft" or event.GameButton == "MenuUp" then
            if selElementIndex > 1 then
                focusIndex = scroller.focus_pos - 1
                selElementIndex = selElementIndex - 1

                if focusIndex >= 1 then
                    scroller.focus_pos = focusIndex
                end

                setCurrentSelectedResult(selElementIndex, focusIndex)

                scroller:scroll_by_amount(focusIndex >= 1 and 0 or -1)
            else
                selElementIndex = numTotalItems
                focusIndex = numTotalItems > maxRows and maxRows or numTotalItems
                scroller.focus_pos = focusIndex
                scroller:scroll_by_amount(numTotalItems > maxRows and (numTotalItems - maxRows) or 0)
                setCurrentSelectedResult(selElementIndex, focusIndex)
            end

            scheduleSongPreview(resultsFrame)
        elseif event.GameButton == "Start" then
            local elemData = scroller:get_info_at_focus_pos()
            local topScreen = SCREENMAN:GetTopScreen()

            resultsFrame:stoptweening()
            resultsFrame:GetParent():playcommand("PlaySongPreview", { song = nil })

            if not elemData.isExit then
                GAMESTATE:SetPreferredSong(elemData.song)

                -- some SortOrders reduce the number of songs currently displayed in the MusicWheel.
                -- GAMESTATE:SetPreferredSong() will correctly set the preferred song, but the MusicWheel
                -- may not currently have that song to display after screen reload.
                -- if we're in one of those SortOrders, change the SortOrder to Group as a workaround
                local current_sort_order = GAMESTATE:GetSortOrder()
                if (current_sort_order == "SortOrder_Preferred")
                    or (current_sort_order == "SortOrder_Popularity")
                    or (current_sort_order == "SortOrder_Recent") then
                    topScreen:GetMusicWheel():ChangeSort("SortOrder_Group")
                end

                resultsFrame.reloadMusicWheel = true
            end

            topScreen:StartTransitioningScreen("SM_GoToPrevScreen")
        end
    end
end
