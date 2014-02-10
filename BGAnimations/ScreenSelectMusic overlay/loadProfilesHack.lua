-- THIS IS A HACK
-- LoadProfileCustom() is normally called via Metrics.ini under [Profile]
-- this does work for profiles on USB memory cards, but not local profiles
-- so these two commands are defined  here to load local profiles
--
-- I would define these in ScreenWithMenuElements decorations.lua,
-- but PROFILEMAN:GetProfileDir() returns an empty string there...

local t = Def.ActorFrame{
	
	-- this should handle latejoin players (?)
	PlayerJoinedMessageCommand=function(self,params)
		
		local slot;
		
		if params.Player == PLAYER_1 then
			slot = "ProfileSlot_Player1";
		elseif params.Player == PLAYER_2 then
			slot = "ProfileSlot_Player2";
		end
		
		local dir = PROFILEMAN:GetProfileDir(slot);		
		local profile = PROFILEMAN:GetProfile(params.Player);
		
		LoadProfileCustom(profile,dir);
	end;
	
	-- this should handle players who joined at a "normal" time
	OnCommand=function(self)
		local Players = GAMESTATE:GetHumanPlayers();
		
		for pn in ivalues(Players) do
		
			local slot;
		
			if pn == PLAYER_1 then
				slot = "ProfileSlot_Player1";
			elseif pn == PLAYER_2 then
				slot = "ProfileSlot_Player2";
			end
		
			local dir = PROFILEMAN:GetProfileDir(slot);		
			local profile = PROFILEMAN:GetProfile(pn);
		
			LoadProfileCustom(profile,dir);
		end
	end;
};

return t;