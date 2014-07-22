local Players = GAMESTATE:GetHumanPlayers()
local ScreenOptions

-- SpeedModItems is a table that will contain the BitMapText Actors
-- for the SpeedModNew OptionRow for both P1 and P2
local SpeedModItems = {P1, P2}

local t = Def.ActorFrame{
	InitCommand=cmd(xy,_screen.cx,0);
	OnCommand=cmd(diffusealpha,0; linear,0.2;diffusealpha,1; queuecommand,"Capture");
	OffCommand=cmd(linear,0.2;diffusealpha,0);
	CaptureCommand=function(self)
		
		ScreenOptions = SCREENMAN:GetTopScreen()
		
		-- reset for ScreenEditOptions
		SpeedModItems = {P1 = nil, P2 = nil}
		
		-- The bitmaptext actors for P1 and P2 speedmod are both named "Item"
		SpeedModItems.P1 = ScreenOptions:GetOptionRow(1):GetChild(""):GetChild("Item")[1]
		SpeedModItems.P2 = ScreenOptions:GetOptionRow(1):GetChild(""):GetChild("Item")[2]
			
		if SpeedModItems.P1 and GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			self:playcommand("SetP1")
		end
		if SpeedModItems.P2 and GAMESTATE:IsPlayerEnabled(PLAYER_2) then
			self:playcommand("SetP2")
		end
	end;
	
	-- this is broadcast from [OptionRow] TitleGainFocusCommand in metrics.ini
	-- we use it to color the active OptionRow's title appropriately by PlayerColor()
	OptionRowChangedMessageCommand=function(self, params)
			
		local CurrentRowIndex = {P1, P2}
	
		-- there is always the possibility that a diffuseshift is still active
		-- cancel it now (and re-apply below, if applicable)
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


for player in ivalues(Players) do
	local pn = ToEnumShortString(player)

	t[#t+1] = Def.ActorFrame{

		-- Commands for player speedmod
		["SpeedModType" .. pn .. "SetMessageCommand"]=function(self,params)
					
			local prevtype = SL[pn].ActiveModifiers.SpeedModType
			local newtype = params.Type
	
			if prevtype ~= newtype then
				if newtype == "C" then
					SL[pn].ActiveModifiers.SpeedMod = 200
				elseif newtype == "x" then
					SL[pn].ActiveModifiers.SpeedMod = 1.50
				end
		
				SL[pn].ActiveModifiers.SpeedModType = newtype
		
				ApplySpeedMod(player)
				self:queuecommand("Set" .. pn)
			end
		end;
		
		["Set" .. pn .. "Command"]=function(self)
			local text = ""
			
			if  SL[pn].ActiveModifiers.SpeedModType == "x" then
				text = string.format("%.2f" , SL[pn].ActiveModifiers.SpeedMod ) .. "x"
			elseif  SL[pn].ActiveModifiers.SpeedModType == "C" then
				text = "C" .. tostring(SL[pn].ActiveModifiers.SpeedMod)
			end
			
			SpeedModItems[pn]:settext( text )
			self:GetParent():GetChild(pn .. "SpeedModHelper"):settext( DisplaySpeedMod(pn) )
		end;
		
		["MenuLeft" .. pn .. "MessageCommand"]=function(self)
			if SCREENMAN:GetTopScreen():GetCurrentRowIndex(player) == 1 then
				ChangeSpeedMod( pn, -1 )
				local text = ""
			
				if  SL[pn].ActiveModifiers.SpeedModType == "x" then
					text = string.format("%.2f" , SL[pn].ActiveModifiers.SpeedMod ) .. "x"
				elseif  SL[pn].ActiveModifiers.SpeedModType == "C" then
					text = "C" .. tostring(SL[pn].ActiveModifiers.SpeedMod)
				end
			
				SpeedModItems[pn]:settext( text )
				self:GetParent():GetChild(pn.."SpeedModHelper"):settext( DisplaySpeedMod(pn) )
			end	
		end;
		["MenuRight" .. pn .. "MessageCommand"]=function(self)
			if SCREENMAN:GetTopScreen():GetCurrentRowIndex(player) == 1 then
				ChangeSpeedMod( pn, 1 )
				local text = ""
			
				if  SL[pn].ActiveModifiers.SpeedModType == "x" then
					text = string.format("%.2f" , SL[pn].ActiveModifiers.SpeedMod ) .. "x"
				elseif  SL[pn].ActiveModifiers.SpeedModType == "C" then
					text = "C" .. tostring(SL[pn].ActiveModifiers.SpeedMod)
				end
			
				SpeedModItems[pn]:settext( text )
				self:GetParent():GetChild(pn.."SpeedModHelper"):settext( DisplaySpeedMod(pn) )
			end
		end
	}
	
	-- the display that does math for you up at the top
	t[#t+1] = LoadFont("_wendy small")..{
		Name=pn.."SpeedModHelper";
		Text="";
		InitCommand=function(self)
			self:diffuse(PlayerColor(player))
			self:zoom(0.5)
			if player == PLAYER_1 then
				self:x(-100)
			elseif player == PLAYER_2 then
				self:x(150)
			end
			self:y(48)
			self:diffusealpha(0)
		end;
		OnCommand=cmd(linear,0.4;diffusealpha,1);
	}
end

return t