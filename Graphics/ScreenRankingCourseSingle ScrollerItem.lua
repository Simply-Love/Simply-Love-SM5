local t = Def.ActorFrame{
	-- setting ztest to true allows masking
	InitCommand=cmd(runcommandsonleaves,cmd(ztest,true));

	Def.Quad{
		InitCommand=cmd(zoomto,_screen.w,60);
		OnCommand=cmd(diffuse,color("0,0,0,0.7"));		
	};

	Def.Banner{
		InitCommand=cmd(x,WideScale(-280,-276);halign,0;scaletoclipped,128,40;diffusealpha,0.2;);
		SetCommand=function(self, params)
			if params.Course then
				self:LoadFromCourse( params.Course );
			end
		end;
	};
	
	--the name of the course, on top of the graphical banner
	LoadFont("_misoreg hires")..{
		InitCommand=cmd(x,WideScale(-220,-292);halign,0;shadowlength,1;wrapwidthpixels,264);
		SetCommand=function(self, params)
			if params.Course then
				self:settext( params.Course:GetDisplayFullTitle() );
			end
		end;
	};
};

local c
local Scores = Def.ActorFrame{
	InitCommand=function(self) c = self:GetChildren(); self:x(188); end;
};

for i=0,1 do
	Scores[#Scores+1] = LoadFont("_misoreg hires")..{
		Name="Name"..i+1;
		InitCommand=cmd(x,WideScale(140,40) + i*100;y,-8;zoom,0.8);
	};
	Scores[#Scores+1] = LoadFont("_misoreg hires")..{
		Name="Score"..i+1;
		InitCommand=cmd(x,WideScale(140,40) + i*100;y,12;zoom,0.8);
	};
end


Scores.SetCommand=function(self,param)
	local profile = PROFILEMAN:GetMachineProfile();
	for name, child in pairs(c) do child:visible(false); end
	local sel = param.Course
	if not sel then return end

	for i, item in pairs(param.Entries) do
		if item then
			local hsl = profile:GetHighScoreList(sel, item);
			local hs = hsl and hsl:GetHighScores();

			assert(c["Name"..i])
			assert(c["Score"..i])

			c["Name"..i]:visible(true)
			c["Score"..i]:visible(true)
			if hs and #hs > 0 then
				c["Name"..i]:settext( hs[1]:GetName() );
				c["Score"..i]:settext( FormatPercentScore( hs[1]:GetPercentDP() ) );
			else
				c["Name"..i]:settext( "-----" );
				c["Score"..i]:settext( FormatPercentScore( 0 ) );
			end
		end
	end
end;

t[#t+1] = Scores

return t