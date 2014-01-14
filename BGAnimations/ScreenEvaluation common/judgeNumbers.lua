local pn = ...;

local TNSTypes = {
	'TapNoteScore_W1',
	'TapNoteScore_W2',
	'TapNoteScore_W3',
	'TapNoteScore_W4',
	'TapNoteScore_W5',
	'TapNoteScore_Miss'
};

local labels2_RC = {'RadarCategory_Holds', 'RadarCategory_Mines', 'RadarCategory_Hands', 'RadarCategory_Rolls' };


local function paddingZeros(number, howManyDigits, xpos, ypos, pn)

	return LoadFont("_ScreenEvaluation numbers")..{
		InitCommand=cmd(zoom,0.5; x, xpos; y, ypos; diffuse,color("#5A6166"); diffusealpha,0.75; horizalign, left;);
		BeginCommand=function(self)
						
			local zeros = "";
			
			if howManyDigits == 4 then
				if number < 10 then
					zeros = "000";
				elseif number >= 10 and number< 100 then
					zeros = "00";
				elseif number >= 100 and number < 1000 then
					zeros = "0";
				end
			elseif howManyDigits == 3 then
				if number < 10 then
					zeros = "00";
				elseif number >= 10 and number < 100 then
					zeros = "0";
				end
			else
				zeros = "";
			end
			
			self:settext(zeros);
			self:visible( GAMESTATE:IsPlayerEnabled(pn) );
		end;
	};
end



local n = Def.ActorFrame{};
local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn);

local performance_x1,paddng_x1,performance_x2,slash_x,possible_x,padding_x2,padding_x3;

-- this function is no longer modular; sorry about that, AJ :(
-- ( There are definitely better ways to do this, but I'm lazy. )
if pn == PLAYER_1 then
	performance_x1 = 64;
	paddng_x1 = -9;
	performance_x2 = -180;
	padding_x2 = -234
	slash_x = -168;	
	possible_x = -114;
	padding_x3 = -168;
elseif pn == PLAYER_2 then
	performance_x1 = 94;
	paddng_x1 = 20;	
	performance_x2 = 218;
	padding_x2 = 164;
	slash_x = 230;
	possible_x = 286;
	padding_x3 = 230;
end	


-- do the normals first
for i=1,#TNSTypes do
	
	local number = stats:GetTapNoteScores(TNSTypes[i]);
	
	-- actual numbers
	n[#n+1] = LoadFont("_ScreenEvaluation numbers")..{
		InitCommand=cmd(shadowlength,1;NoStroke; zoom,0.5; x,performance_x1;);
		BeginCommand=function(self)
			self:y((i-1)*35 -20);
			self:settext(number);
			self:diffuse(color("#FFFFFF"));
			self:halign( 1 );
			self:visible( GAMESTATE:IsPlayerEnabled(pn) );
		end;
	};

	n[#n+1] = paddingZeros(number, 4, paddng_x1, ((i-1)*35 - 20), pn)
	
end;
	
	

for i=1,#labels2_RC do	
		
	-- player performace value
	n[#n+1] = LoadFont("_ScreenEvaluation numbers")..{
		InitCommand=cmd(shadowlength,1;NoStroke;zoom,0.5);
		BeginCommand=function(self)			
			self:y((i-1)*35 + 53);
			self:x(performance_x2);			
			self:settext(stats:GetRadarActual():GetValue(labels2_RC[i]));
			self:halign( 1 );
			self:visible( GAMESTATE:IsPlayerEnabled(pn) );
		end;
	};

	-- gray zeros for padding the performance value
	n[#n+1] = paddingZeros(stats:GetRadarActual():GetValue(labels2_RC[i]), 3, padding_x2, ((i-1)*35 + 53), pn);
	
	--  slash
	n[#n+1] = LoadFont("_misoreg hires")..{
		Text="/";
		InitCommand=cmd(NoStroke; diffuse,color("#5A6166"); zoom, 1.25);
		BeginCommand=function(self)
			self:y((i-1)*35 + 53);
			self:x(slash_x);
			self:halign( 1 );
			self:visible( GAMESTATE:IsPlayerEnabled(pn) );
		end;
	};
	
	--possible value
	n[#n+1] = LoadFont("_ScreenEvaluation numbers")..{
		InitCommand=cmd(shadowlength,1;NoStroke;zoom,0.5);
		BeginCommand=function(self)
			self:y((i-1)*35 + 53);
			self:x(possible_x);
			self:settext(stats:GetRadarPossible():GetValue(labels2_RC[i]));
			self:halign( 1 );
			self:visible( GAMESTATE:IsPlayerEnabled(pn) );
		end;
	};

	-- gray zeros for padding the possible value
	n[#n+1] = paddingZeros(stats:GetRadarPossible():GetValue(labels2_RC[i]), 3, padding_x3, ((i-1)*35 + 53), pn);

end	


return n;