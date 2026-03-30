-- Lay out the per-player gameplay elements.
--
-- The algorithm starts by putting the judgment grapic and the combo counter at
-- a fixed position (the default position set in the fallback theme). After
-- that it adds gameplay elements around the judgment graphic, according to the
-- user options. The combo counter is moved out of the way if necessary.
function GetGameplayLayout(player, reverse)
    local mods = SL[ToEnumShortString(player)].ActiveModifiers

    -- default positions of combo and judgment graphic
    local comboY = _screen.cy + (reverse and -30 or 30)
    local judgmentY = _screen.cy + (reverse and 30 or -30)
    local judgmentHeight = 40

    local layout = {
        Combo = { y = comboY },
    }

    -- In casual mode none of the other elements are displayed, so shortcut.
    if SL.Global.GameMode == "Casual" then
        return layout
    end

    local topY = judgmentY - judgmentHeight/2
    local bottomY = judgmentY + judgmentHeight/2
	
	local hasErrorBar = false
	local ErrorBarTypes = { "Colorful", "Monochrome", "Text", "Highlight", "Average" }
	for i, barname in ipairs(ErrorBarTypes) do
		if mods[barname] then 
			hasErrorBar = true
			break
		end
	end

    if hasErrorBar then
        if mods.JudgmentGraphic == "None" then
            -- Display the error bar in place of the judgment graphic if it's
            -- disabled.
            layout.ErrorBar = { y = judgmentY, maxHeight = 30 }
        elseif mods.ErrorBarUp then
            layout.ErrorBar = { y = topY - 5, maxHeight = 10 }
            topY = topY - 15
        else
            layout.ErrorBar = { y = bottomY + 5, maxHeight = 10 }
            bottomY = bottomY + 15
        end
    end

    if mods.MeasureCounter ~= "None" then
        if mods.MeasureCounterUp then
            layout.MeasureCounter = { y = topY - 8 }
            topY = topY - 20
			if mods.BrokenRun then
				layout.MeasureCounter.y = layout.MeasureCounter.y - 16
			end
        else
            layout.MeasureCounter = { y = bottomY + 8 }
            bottomY = bottomY + 21
        end
    end

	if mods.MeasureCounter ~= "None" and mods.MeasureCounterUp and mods.HideLookahead then
		layout.SubtractiveScoring = { y = layout.MeasureCounter.y }
	elseif mods.MeasureCounter ~= "None" and  mods.MeasureCounterUp then
		layout.SubtractiveScoring = { y = bottomY + 8}
		bottomY = bottomY + 16
	else
		layout.SubtractiveScoring = { y = topY - 8 }
		topY = topY - 16
	end

    -- Move the combo counter out of the way if it overlaps with any gameplay
    -- element.
    if reverse then
        layout.Combo.y = math.min(layout.Combo.y, topY - 20)
    else
        layout.Combo.y = math.max(layout.Combo.y, bottomY + 20)
    end

    return layout
end

-- Called by the engine to set the combo counter position. Custom positioning
-- is necessary to prevent overlap with gameplay elements (error bar, measure
-- counter, subtractive scoring).
function ComboTransformCommand(self, params)
    local layout = GetGameplayLayout(params.Player, params.bReverse)

    -- X is relative to the center of the note field and Y is relative to the
    -- center of the screen, so we have to translate the coordinates.
    self:xy(0, layout.Combo.y - _screen.cy)
end
