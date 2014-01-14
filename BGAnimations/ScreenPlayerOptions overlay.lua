local function DisplayBPM()
	local bpm = GAMESTATE:GetCurrentSong():GetDisplayBpms();
	local display = "";
		
	--if a single bpm suffices
	if bpm[1] == bpm[2] then
		display = round(bpm[1])
		
	-- if we have a range of bpms
	else
		display = round(bpm[1]) .. " - " .. round(bpm[2])
	end

	return " (" .. display .. ")";
end



---------------------------------
-- SMOKE AND MIRRORS 
---------------------------------

-- initialize speed mods from preferences
local currentMod = {
	P1 = getenv("SpeedModP1") or "1x";
	P2 = getenv("SpeedModP2") or "1x";
};


local t = Def.ActorFrame{
	InitCommand=cmd(xy,SCREEN_CENTER_X,0);
	OnCommand=function(self)
		local optionRow = SCREENMAN:GetTopScreen():GetOptionRow(1);	
		--optionRow:visible(false);
	end;
	
	
	LoadFont("_misoreg hires")..{
		Name="DummySpeedModTitle";
		Text="";
		InitCommand=cmd(zoom,0.8;shadowlength,1;shadowcolor,color("0,0,0,0.8");strokecolor,color("0,0,0,0.2");halign, 0 );
		OnCommand=function(self)
			local x = WideScale(-222,-320);
			local y = 112;
			self:xy(x, y);		
			self:settext( DisplayBPM() );
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
			-- local usertype = GetUserPref("SpeedModTypeP1");
			local usertype = getenv("SpeedModTypeP1");
			local newtype = params.Type
			
			if usertype ~= newtype then
				if newtype == "C" then
					currentMod["P1"] = "C200"
				elseif newtype == "x" then
					currentMod["P1"] = "1.5x"
				end
				-- SetUserPref("SpeedModTypeP1", newtype);
				-- SetUserPref("SpeedModP1",currentMod["P1"]);
				
				setenv("SpeedModTypeP1", newtype);				
				setenv("SpeedModP1",currentMod["P1"]);
				
				ApplySpeedMod("P1");
				self:queuecommand("Set");
			end
		end;
		SpeedModP1SetMessageCommand=function(self)
			-- SetUserPref("SpeedModP1",currentMod["P1"]);
			setenv("SpeedModP1", currentMod["P1"]);
			
			ApplySpeedMod("P1");
		end;
		SetCommand=function(self)
			self:settext(THEME:GetString("OptionNames","NextRow"));
			
			-- local userSpeed = GetUserPref("SpeedModP1");
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
			-- local usertype = GetUserPref("SpeedModTypeP2");
			local usertype = getenv("SpeedModTypeP2");
			local newtype = params.Type
			
			if usertype ~= newtype then
				if newtype == "C" then
					currentMod["P2"] = "C200"
				elseif newtype == "x" then
					currentMod["P2"] = "1.5x"
				end
				-- SetUserPref("SpeedModTypeP2", newtype);
				-- SetUserPref("SpeedModP2",currentMod["P2"]);
				
				setenv("SpeedModTypeP2", newtype);
				setenv("SpeedModP2",currentMod["P2"]);
				
				ApplySpeedMod("P2");
				self:queuecommand("Set");
			end
		end;
		SpeedModP2SetMessageCommand=function(self)
			-- SetUserPref("SpeedModP2",currentMod["P2"]);
			
			setenv("SpeedModP2", currentMod["P2"]);
			
			ApplySpeedMod("P2");
		end;
		SetCommand=function(self)
			self:settext(THEME:GetString("OptionNames","NextRow"));
			
			--local userSpeed = GetUserPref("SpeedModP2");
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