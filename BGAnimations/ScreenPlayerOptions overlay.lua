-- initialize speed mods from preferences
local currentMod = {
	P1 = getenv("SpeedModP1") or "1.00x";
	P2 = getenv("SpeedModP2") or "1.00x";
};

local ScreenOptions;

-- SpeedModItems is a table that will contain the BitMapText Actors
-- for the SpeedModNew OptionRow for both P1 and P2
local SpeedModItems = {nil, nil};

-- Cursors is a table that will contain the Cusor ActorFrames
-- for both P1 and P2
local Cursors = {};

local t = Def.ActorFrame{
	InitCommand=cmd(xy,SCREEN_CENTER_X,0;);
	OnCommand=cmd(diffusealpha,0; linear,0.2;diffusealpha,1; queuecommand,"Capture");
	OffCommand=cmd(linear,0.2;diffusealpha,0);
	CaptureCommand=function(self)
		
		ScreenOptions = SCREENMAN:GetTopScreen();
		
		-- reset for editmode OptionsMenu
		SpeedModItems = {nil, nil};
		
		-- The bitmaptext actors for P1 and P2 speedmod are both named "Item"
		SpeedModItems[1] = ScreenOptions:GetOptionRow(1):GetChild(""):GetChild("Item")[1];
		SpeedModItems[2] = ScreenOptions:GetOptionRow(1):GetChild(""):GetChild("Item")[2];
		

		-- Do similarly to grab cursors for P1 and P2.
		-- We'll want both so we can update the width of each appropriately.
		ScreenOptions:GetChild("Container"):RunCommandsOnChildren(
			function(self)			
				if self:GetName() == "Cursor" then		
					Cursors[#Cursors+1] = self;
				end
			end
		);
			
		if SpeedModItems[1] and GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			self:playcommand("SetP1");
		end
		if SpeedModItems[2] and GAMESTATE:IsPlayerEnabled(PLAYER_2) then
			self:playcommand("SetP2");
		end

	end;
	
	-- Commands for PLAYER_1 speedmod
	SpeedModTypeP1SetMessageCommand=function(self,params)
					
		local usertype = getenv("SpeedModTypeP1");
		local newtype = params.Type
	
		if usertype ~= newtype then
			if newtype == "C" then
				currentMod.P1 = "C200"
			elseif newtype == "x" then
				currentMod.P1 = "1.5x"
			end
		
			setenv("SpeedModTypeP1", newtype);				
			setenv("SpeedModP1",currentMod.P1);
		
			ApplySpeedMod("P1");
			self:queuecommand("SetP1");
		end
	end;

	SpeedModP1SetMessageCommand=function(self)
		setenv("SpeedModP1", currentMod.P1);
		ApplySpeedMod("P1");
	end;
	SetP1Command=function(self)
		SpeedModItems[1]:settext( currentMod.P1 );
		self:GetChild("P1SpeedModHelper"):settext(DisplaySpeedMod( currentMod.P1 ));
	end;
	MenuLeftP1MessageCommand=function(self)
		if SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_1) == 1 then
			currentMod.P1 = decrement(currentMod.P1);
			SpeedModItems[1]:settext( currentMod.P1 );
			self:GetChild("P1SpeedModHelper"):settext(DisplaySpeedMod( currentMod.P1 ));
		end	
	end;
	MenuRightP1MessageCommand=function(self)
		if SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_1) == 1 then
			currentMod.P1 = increment(currentMod.P1);
			SpeedModItems[1]:settext( currentMod.P1 );
			self:GetChild("P1SpeedModHelper"):settext(DisplaySpeedMod( currentMod.P1 ));
		end
	end;
	
	
	-- Commands for PLAYER_2 speedmod
	SpeedModTypeP2SetMessageCommand=function(self, params)

		local usertype = getenv("SpeedModTypeP2");
		local newtype = params.Type
		
		if usertype ~= newtype then
			if newtype == "C" then
				currentMod.P2 = "C200"
			elseif newtype == "x" then
				currentMod.P2 = "1.5x"
			end
			
			setenv("SpeedModTypeP2", newtype);
			setenv("SpeedModP2",currentMod.P2);
			
			ApplySpeedMod("P2");
			self:queuecommand("SetP2");
		end
	end;
	SpeedModP2SetMessageCommand=function(self)
		setenv("SpeedModP2", currentMod.P2);
		ApplySpeedMod("P2");
	end;
	SetP2Command=function(self)
		SpeedModItems[2]:settext( currentMod.P2 );
		self:GetChild("P2SpeedModHelper"):settext(DisplaySpeedMod( currentMod.P2 ));
	end;
	MenuLeftP2MessageCommand=function(self)
		if SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_2) == 1 then
			currentMod.P2 = decrement(currentMod.P2);
			SpeedModItems[2]:settext( currentMod.P2 );
			self:GetChild("P2SpeedModHelper"):settext(DisplaySpeedMod( currentMod.P2 ));
		end	
	end;
	MenuRightP2MessageCommand=function(self)
		if SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_2) == 1 then
			currentMod.P2 = increment( currentMod.P2 );
			SpeedModItems[2]:settext( currentMod.P2 );
			self:GetChild("P2SpeedModHelper"):settext(DisplaySpeedMod( currentMod.P2 ));
		end
	end;



	-- this is broadcast from [OptionRow] TitleGainFocusCommand in metrics.ini
	-- we use it to color the active OptionRow's title appropriately by PlayerColor()
	OptionRowChangedMessageCommand=function(self, params)
				
		local CurrentRowIndexP1, CurrentRowIndexP2;
		
		-- there is always the possibility that a diffuseshift is still active
		-- cancel it now (and re-apply below, if applicable)
		params.Title:stopeffect();
		
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
			
		if CurrentRowIndexP1 and CurrentRowIndexP2 then
			if CurrentRowIndexP1 == CurrentRowIndexP2 then
				params.Title:diffuseshift();
				params.Title:effectcolor1(PlayerColor(PLAYER_1));
				params.Title:effectcolor2(PlayerColor(PLAYER_2));
			end
		end

	end;
};

				
if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
	-- the display that does math for you up at the top
	t[#t+1] = LoadFont("_wendy small")..{
		Name="P1SpeedModHelper";
		Text="";
		InitCommand=cmd(diffuse,PlayerColor(PLAYER_1); zoom,0.5; x,-100; addy,48; diffusealpha,0;);
		OnCommand=cmd(linear,0.4;diffusealpha,1);
	};	
end



if GAMESTATE:IsPlayerEnabled(PLAYER_2) then	
	-- the display that does math for you up at the top
	t[#t+1] = LoadFont("_wendy small")..{
		Name="P2SpeedModHelper";
		Text="";
		InitCommand=cmd(diffuse,PlayerColor(PLAYER_2); zoom,0.5; x,150; addy,48;diffusealpha,0;);
		OnCommand=cmd(linear,0.4;diffusealpha,1);
	};
	
end

return t;