---------------------------------------------
-- SMOKE AND MIRRORS, JEN! SMOKE AND MIRRORS!
---------------------------------------------

-- initialize speed mods from preferences
local currentMod = {
	P1 = getenv("SpeedModP1") or "1x";
	P2 = getenv("SpeedModP2") or "1x";
};

local ScreenOptions = SCREENMAN:GetTopScreen();

local t = Def.ActorFrame{
	InitCommand=cmd(xy,SCREEN_CENTER_X,0);
	OnCommand=cmd(diffusealpha,0; linear,0.2;diffusealpha,1);
	OffCommand=cmd(linear,0.2;diffusealpha,0);
	
	-- this is broadcast from [OptionRow] TitleGainFocusCommand in metrics.ini
	-- we use it to color the active OptionRow's title appropriately by PlayerColor()
	OptionRowChangedMessageCommand=function(self, params)
				
		local CurrentRowIndexP1, CurrentRowIndexP2;
		local dummySpeedModTitle = self:GetChild("DummySpeedModTitle");
		
		-- there is always the possibility that a diffuseshift is still active
		-- cancel it now (and re-apply below, if applicable)
		params.Title:stopeffect();
		dummySpeedModTitle:stopeffect();
		dummySpeedModTitle:diffuse(Color.White);
		
		-- if ScreenOptions is nil, get it now
		if not ScreenOptions then
			ScreenOptions = SCREENMAN:GetTopScreen();
		else			
			-- get the index of PLAYER_1's current row
			if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
				CurrentRowIndexP1 = ScreenOptions:GetCurrentRowIndex(PLAYER_1);
				if CurrentRowIndexP1 == 1 then
					dummySpeedModTitle:diffuse(PlayerColor(PLAYER_1));
				end
			end
			
			-- get the index of PLAYER_2's current row
			if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
				CurrentRowIndexP2 = ScreenOptions:GetCurrentRowIndex(PLAYER_2);
				if CurrentRowIndexP2 == 1 then
					dummySpeedModTitle:diffuse(PlayerColor(PLAYER_2));
				end
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
			
			if CurrentRowIndexP1 == 1 then
				dummySpeedModTitle:diffuseshift();
				dummySpeedModTitle:effectcolor1(PlayerColor(PLAYER_1));
				dummySpeedModTitle:effectcolor2(PlayerColor(PLAYER_2));
			end
		end

	end;
	
	
	LoadFont("_misoreg hires")..{
		Name="DummySpeedModTitle";
		Text="";
		InitCommand=cmd(diffusealpha,0; zoom,0.8; halign,0 );
		OnCommand=function(self)
			local x = WideScale(-215,-315);
			local y = 112;
			self:xy(x, y);		
			self:settext( "(".. GetDisplayBPMs() .. ")" );
			self:sleep(0.1);
			self:linear(0.2);
			self:diffusealpha(1);
		end;
	};
};

	
if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
	
	
	-- dummy optionRow item...
	t[#t+1] = LoadFont("_misoreg hires")..{
		Name="P1SpeedModDummyText";
		Text="";
		InitCommand=cmd(zoom,0.8;shadowlength,1;shadowcolor,color("0,0,0,0.8");strokecolor,color("0,0,0,0.2") );
		OnCommand=function(self) 
			local x = WideScale(-78,-100);
			local y = 112;
			self:xy(x, y);
			self:queuecommand("Set");
		end;
		SpeedModTypeP1SetMessageCommand=function(self,params)

			local usertype = getenv("SpeedModTypeP1");
			local newtype = params.Type
			
			if usertype ~= newtype then
				if newtype == "C" then
					currentMod["P1"] = "C200"
				elseif newtype == "x" then
					currentMod["P1"] = "1.5x"
				end
				
				setenv("SpeedModTypeP1", newtype);				
				setenv("SpeedModP1",currentMod["P1"]);
				
				ApplySpeedMod("P1");
				self:queuecommand("Set");
			end
		end;
		SpeedModP1SetMessageCommand=function(self)
			setenv("SpeedModP1", currentMod["P1"]);
			
			ApplySpeedMod("P1");
		end;
		SetCommand=function(self)
			self:settext(THEME:GetString("OptionNames","NextRow"));
			
			local userSpeed = getenv("SpeedModP1");
			
			self:GetParent():GetChild("P1SpeedModHelper"):settext(DisplaySpeedMod(userSpeed));
			currentMod["P1"] = userSpeed;
		end;
		MenuLeftP1MessageCommand=function(self)
			if SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_1) == 1 then
				local mod = decrement(currentMod["P1"]);
				currentMod["P1"] = mod;
				self:settext(mod);
				self:GetParent():GetChild("P1SpeedModHelper"):settext(DisplaySpeedMod(mod));
			end	
		end;
		MenuRightP1MessageCommand=function(self)
			if SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_1) == 1 then
				local mod = increment(currentMod["P1"]);
				currentMod["P1"] = mod;
				self:settext(mod);
				self:GetParent():GetChild("P1SpeedModHelper"):settext(DisplaySpeedMod(mod));
			end
		end;	
	};
	
	
	-- the display that does math for you up at the top
	t[#t+1] = LoadFont("_wendy small")..{
		Name="P1SpeedModHelper";
		Text="P1 Scroll Rate";
		InitCommand=cmd(diffuse,PlayerColor(PLAYER_1); zoom,0.5; addx,-100; addy,48;);
	};	
end






if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	
	-- dummy optionRow item...
	t[#t+1] = LoadFont("_misoreg hires")..{
		Name="P2SpeedModDummyText";
		Text="";
		InitCommand=cmd(zoom,0.8;shadowlength,1;shadowcolor,color("0,0,0,0.8");strokecolor,color("0,0,0,0.2") );
		OnCommand=function(self) 
			local x = WideScale(142, 152);
			local y = 112;
			self:xy(x, y);
			self:queuecommand("Set");
		end;
		SpeedModTypeP2SetMessageCommand=function(self, params)

			local usertype = getenv("SpeedModTypeP2");
			local newtype = params.Type
			
			if usertype ~= newtype then
				if newtype == "C" then
					currentMod["P2"] = "C200"
				elseif newtype == "x" then
					currentMod["P2"] = "1.5x"
				end
				
				setenv("SpeedModTypeP2", newtype);
				setenv("SpeedModP2",currentMod["P2"]);
				
				ApplySpeedMod("P2");
				self:queuecommand("Set");
			end
		end;
		SpeedModP2SetMessageCommand=function(self)
		
			setenv("SpeedModP2", currentMod["P2"]);
			
			ApplySpeedMod("P2");
		end;
		SetCommand=function(self)
			self:settext(THEME:GetString("OptionNames","NextRow"));
			
			local userSpeed = getenv("SpeedModP2");
			
			self:GetParent():GetChild("P2SpeedModHelper"):settext(DisplaySpeedMod(userSpeed));
			currentMod["P2"] = userSpeed;
		end;
		MenuLeftP2MessageCommand=function(self)
			if SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_2) == 1 then
				local mod = decrement(currentMod["P2"]);
				currentMod["P2"] = mod;
				self:settext(mod);
				self:GetParent():GetChild("P2SpeedModHelper"):settext(DisplaySpeedMod(mod));
			end	
		end;
		MenuRightP2MessageCommand=function(self)
			if SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_2) == 1 then
				local mod = increment(currentMod["P2"]);
				currentMod["P2"] = mod;
				self:settext(mod);
				self:GetParent():GetChild("P2SpeedModHelper"):settext(DisplaySpeedMod(mod));
			end
		end;	
	};
	
	
	-- the display that does math for you up at the top
	t[#t+1] = LoadFont("_wendy small")..{
		Name="P2SpeedModHelper";
		Text="P2 Scroll Rate";
		InitCommand=cmd(diffuse,PlayerColor(PLAYER_2); zoom,0.5; addx,150; addy,48;);
	};
	
end

return t;