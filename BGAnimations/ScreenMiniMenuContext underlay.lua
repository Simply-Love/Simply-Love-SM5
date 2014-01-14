-- this is only used for the Screen that manages local profiles so far

local t = Def.ActorFrame {
	InitCommand=cmd(CenterX;y,SCREEN_CENTER_Y-84);



	-- Intructions BG
	Def.Quad {
		InitCommand = cmd(zoomto, SCREEN_WIDTH*0.25, SCREEN_CENTER_Y*0.5; diffuse,Color.Black;);
	};
	-- white border
	Border(SCREEN_WIDTH*0.25, SCREEN_CENTER_Y*0.5, 2) .. {
		InitCommand = cmd();
	};

	-- header 
	Def.Quad {
		InitCommand = cmd(y,-60; zoomto, SCREEN_WIDTH*0.25, SCREEN_CENTER_Y*0.15; diffuse,Color.White;);
	};
	
	LoadFont("_misoreg hires")..{
		InitCommand=cmd(x,-80;y,-60;halign,0;shadowlength,0;diffuse,color("#000000");strokecolor,color("0,0,0,0"));
		BeginCommand=function(self)
			local profile = GAMESTATE:GetEditLocalProfile()
			if profile then
				self:settext(profile:GetDisplayName())
			end
		end;
	};
}

return t;
