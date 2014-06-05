local ScreenOptions = SCREENMAN:GetTopScreen();

local t = Def.ActorFrame{
	InitCommand=cmd(xy,SCREEN_CENTER_X,0; diffusealpha,0;);
	OnCommand=cmd(linear,0.2;diffusealpha,1;);
	OffCommand=cmd(linear,0.2;diffusealpha,0);
	
	-- this is broadcast from [OptionRow] TitleGainFocusCommand in metrics.ini
	-- we use it to color the active OptionRow's title appropriately by PlayerColor()
	OptionRowChangedMessageCommand=function(self, params)
		
		-- there is always the possibility that a diffuseshift is still active
		-- cancel it now (and re-apply below, if applicable)
		params.Title:stopeffect();
		
		local CurrentRowIndexP1, CurrentRowIndexP2;
		
		-- if ScreenOptions is nil, get it now
		if not ScreenOptions then
			ScreenOptions = SCREENMAN:GetTopScreen();
		else			
			-- get the index of PLAYER_1's current row
			if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
				CurrentRowIndexP1 = ScreenOptions:GetCurrentRowIndex(PLAYER_1);
			end
			
			-- get the index of PLAYER_2's current row
			if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
				CurrentRowIndexP2 = ScreenOptions:GetCurrentRowIndex(PLAYER_2);				
			end
		end
			
		local optionRow = params.Title:GetParent():GetParent();
		
		-- color the active optionrow's title appropriately
		if optionRow:HasFocus(PLAYER_1) then
			params.Title:diffuse(PlayerColor(PLAYER_1));
		end
		
		if optionRow:HasFocus(PLAYER_2) then
			params.Title:diffuse(PlayerColor(PLAYER_2));
		end
			
		if CurrentRowIndexP1 == CurrentRowIndexP2 then
			params.Title:diffuseshift();
			params.Title:effectcolor1(PlayerColor(PLAYER_1));
			params.Title:effectcolor2(PlayerColor(PLAYER_2));
		end

	end;	
	
};

return t;