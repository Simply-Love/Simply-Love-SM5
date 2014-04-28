-- this is only used for the Screen that manages local profiles so far

local t = Def.ActorFrame {
	InitCommand=cmd(xy,SCREEN_CENTER_X-SCREEN_WIDTH/6,SCREEN_CENTER_Y-84);
	
	-- white border
	Border(204, SCREEN_HEIGHT*0.235, 2);

	-- header 
	Def.Quad {
		InitCommand=cmd(y,-60; zoomto, 204, SCREEN_HEIGHT*0.075; diffuse,Color.White;);
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
