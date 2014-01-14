local pn = ...;
	
local PlayerState = GAMESTATE:GetPlayerState(pn);
-- grab the song options from this PlayerState.
local options = PlayerState:GetPlayerOptionsString('ModsLevel_Preferred');
-- now using split, let's put them into a table for comparison
local tableOfOptions = split(", ", options);
local optionslist= "";

for i=1, #tableOfOptions do
	if tableOfOptions[i] ~= "FailAtEnd" then
		optionslist = optionslist..tostring(tableOfOptions[i])..", ";
	end
end

-- chop off the final, trailing comma 
optionslist = string.sub(optionslist,1,-3);
	
	
return Def.ActorFrame{
	
	Def.Quad{
		InitCommand=cmd(diffuse,color("#1E282F"); zoomto, 300, 30);
	};
	
	LoadFont("_misoreg hires")..{
		Text=optionslist;
		InitCommand=cmd(zoom,0.7; horizalign,left; x,-140);
	};
};
