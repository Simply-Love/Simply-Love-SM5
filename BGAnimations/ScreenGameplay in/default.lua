local sStage = "";

if not PREFSMAN:GetPreference("EventMode") then
	
	local CurrentSong = GAMESTATE:GetCurrentSong();
	local Players = GAMESTATE:GetHumanPlayers();

	local bIsLong = CurrentSong:IsLong();
	local bIsMarathon = CurrentSong:IsMarathon();
	local iAdditionalStagesThisSongCountsFor = bIsLong and 1 or bIsMarathon and 2 or 0;

	local iStagesLeft = math.huge;

	-- GAMESTATE:GetNumStagesLeft() asks for a playernumber because latejoin can
	-- cause discrepencies between players.  For Simply Love, we only care about
	-- which player has fewer stages remaining; we use that value for both.
	for pn in ivalues(Players) do
		local iPlayerStagesLeft = GAMESTATE:GetNumStagesLeft(pn)

		if iStagesLeft > iPlayerStagesLeft then
			iStagesLeft = iPlayerStagesLeft;
		end
	end


	local iSongsPerPlay = PREFSMAN:GetPreference("SongsPerPlay");
	local iStageNumber = (iSongsPerPlay - iStagesLeft) + 1;

	sStage = THEME:GetString("Stage", "Stage") .. " " .. tostring(iStageNumber);

	if iStageNumber + iAdditionalStagesThisSongCountsFor >= iSongsPerPlay then
		sStage = THEME:GetString("Stage", "Final");
	end
	
else
	sStage = THEME:GetString("Stage", "Event");
end



local t = Def.ActorFrame {};

t[#t+1] = Def.ActorFrame{

	Def.Quad{
		InitCommand=cmd(diffuse,color("0,0,0,1"); Center; FullScreen;);
		OnCommand=cmd(sleep,1.4; accelerate,0.6; diffusealpha,0;);
	};
	
	
	LoadActor("heartsplode")..{
		InitCommand=cmd(diffusealpha,0);
		OnCommand=cmd(sleep,0.4; diffuse, GetCurrentColor(); Center; rotationz,10; diffusealpha,0; zoom,0; diffusealpha,0.9; linear,0.6; rotationz,0; zoom,1.1; diffusealpha,0;);
	};
	LoadActor("heartsplode")..{
		InitCommand=cmd(diffusealpha,0);
		OnCommand=cmd(sleep,0.4; diffuse, GetCurrentColor(); Center; rotationy,180; rotationz,-10; diffusealpha,0; zoom,0.2; diffusealpha,0.8; decelerate,0.6; rotationz,0; zoom,1.3; diffusealpha,0;);
	};
	LoadActor("minisplode")..{
		InitCommand=cmd(diffusealpha,0);
		OnCommand=cmd(sleep,0.4; diffuse, GetCurrentColor(); Center; rotationz,10; diffusealpha,0; zoom,0; diffusealpha,1; decelerate,0.8; rotationz,0; zoom,0.9; diffusealpha,0;)
	};
	
	LoadFont("_wendy small")..{
		InitCommand=cmd(Center; diffusealpha,0; shadowlength,1);
		OnCommand=cmd(settext, sStage; accelerate, 0.5; diffusealpha, 1; sleep, 0.66; accelerate, 0.33; zoom, 0.4; y, SCREEN_HEIGHT-30);
	};
};




return t;