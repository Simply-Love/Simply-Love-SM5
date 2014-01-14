t =  Def.ActorFrame {};

t[#t+1] = StandardDecorationFromFile( "Header", "Header" );
t[#t+1] = StandardDecorationFromFileOptional( "Footer", "Footer" );


t[#t+1] = Def.ActorFrame{
	
	-- PlayerJoinedMessageCommand=function(self,params)
	-- 	
	-- 	local slot;
	-- 	
	-- 	if params.Player == PLAYER_1 then
	-- 		slot = "ProfileSlot_Player1";
	-- 	elseif params.Player == PLAYER_2 then
	-- 		slot = "ProfileSlot_Player2";
	-- 	end
	-- 	
	-- 	local dir = PROFILEMAN:GetProfileDir(slot);		
	-- 	local profile = PROFILEMAN:GetProfile(params.Player);
	-- 	
	-- 	LoadProfileCustom(profile,dir);
	-- end
	
};
return t; 