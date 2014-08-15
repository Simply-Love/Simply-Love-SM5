local ScreenOptions = SCREENMAN:GetTopScreen()

return Def.ActorFrame{
	-- this is broadcast from [OptionRow] TitleGainFocusCommand in metrics.ini
	-- we use it to color the active OptionRow's title appropriately by PlayerColor()
	OptionRowChangedMessageCommand=function(self, params)
		local CurrentRowIndex = {P1, P2}
		
		-- There is always the possibility that a diffuseshift is still active;
		-- cancel it now (and re-apply below, if applicable).
		params.Title:stopeffect()
	
		-- if ScreenOptions is nil, get it now
		if not ScreenOptions then
			ScreenOptions = SCREENMAN:GetTopScreen()
		else
			-- get the index of PLAYER_1's current row
			if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
				CurrentRowIndex.P1 = ScreenOptions:GetCurrentRowIndex(PLAYER_1)
			end
		
			-- get the index of PLAYER_2's current row
			if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
				CurrentRowIndex.P2 = ScreenOptions:GetCurrentRowIndex(PLAYER_2)
			end
		end
		
		local optionRow = params.Title:GetParent():GetParent();
	
		-- color the active optionrow's title appropriately
		if optionRow:HasFocus(PLAYER_1) then
			params.Title:diffuse(PlayerColor(PLAYER_1))
		end
	
		if optionRow:HasFocus(PLAYER_2) then
			params.Title:diffuse(PlayerColor(PLAYER_2))
		end
		
		if CurrentRowIndex.P1 and CurrentRowIndex.P2 then
			if CurrentRowIndex.P1 == CurrentRowIndex.P2 then
				params.Title:diffuseshift()
				params.Title:effectcolor1(PlayerColor(PLAYER_1))
				params.Title:effectcolor2(PlayerColor(PLAYER_2))
			end
		end

	end
}