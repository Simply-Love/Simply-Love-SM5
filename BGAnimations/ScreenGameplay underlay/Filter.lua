-- filter code rewrite
local Player = ...;
assert(...);

local IsUsingSoloSingles = PREFSMAN:GetPreference('Center1Player');
local NumPlayers = GAMESTATE:GetNumPlayersEnabled();
local NumSides = GAMESTATE:GetNumSidesJoined();

local pName;
local filterColor;
local fallbackColor = color("0,0,0,0.75");

local function InitFilter()
	pName = pname(Player);
	
	local darkness = getenv("ScreenFilter"..pName)
	if darkness == "Dark" then
		filterColor = color("#00000088");
	elseif darkness == "Darker" then
		filterColor = color("#000000AA");
	elseif darkness == "Darkest" then
		filterColor = color("#000000EE");
	else
		filterColor = color("#00000000");
	end
	
end;

local function FilterPosition()
	if IsUsingSoloSingles and NumPlayers == 1 and NumSides == 1 then return SCREEN_CENTER_X; end;
	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then return SCREEN_CENTER_X; end;

	local strPlayer = (NumPlayers == 1) and "OnePlayer" or "TwoPlayers";
	local strSide = (NumSides == 1) and "OneSide" or "TwoSides";
	return THEME:GetMetric("ScreenGameplay","Player".. pName .. strPlayer .. strSide .."X");
end;

-- updated by sillybear
-- xxx: does this still only account for dance?
local function FilterWidth()
	
	if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then 
		return ((SCREEN_WIDTH*1.058)/GetScreenAspectRatio());
	else
		return ((SCREEN_WIDTH*0.529)/GetScreenAspectRatio());
	end;
end;

InitFilter();

local filter = Def.ActorFrame{
	Def.Quad{
		InitCommand=cmd(diffuse,filterColor;xy,FilterPosition(),SCREEN_CENTER_Y;zoomto,FilterWidth(),SCREEN_HEIGHT);
		OffCommand=function(self)
			local pStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(Player);
			if pStats:FullCombo() then
				local comboColor
				if pStats:FullComboOfScore('TapNoteScore_W1') then
					comboColor = color("#6BF0FF")
				elseif pStats:FullComboOfScore('TapNoteScore_W2') then
					comboColor = color("#FDDB85")
				else
					comboColor = color("#94FEC1")
				end
				self:accelerate(0.25);
				self:diffuse( comboColor );
				self:decelerate(0.75);
				self:diffusealpha( 0 );
			end;
		end;
	};
};
return filter;
