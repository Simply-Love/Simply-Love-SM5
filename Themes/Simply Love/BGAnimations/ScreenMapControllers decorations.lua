local headerHeight = 50;

local function PlayerText(pn)
	local pnumber = pn == PLAYER_1 and "1" or "2";
	local xpos = pn == PLAYER_1 and 0.5 or 1.5;

	return LoadFont("_wendy small")..{
		Name="Label"..pname(pn);
		Text="Player "..pnumber;
		InitCommand=cmd(x,_screen.cx*xpos; y,headerHeight/2; NoStroke; zoom,0.8;);
		OnCommand=cmd(diffusealpha,0;linear,0.5;diffusealpha,1);
		OffCommand=cmd(linear,0.5;diffusealpha,0);
	};
end;

local t = Def.ActorFrame{
	Def.ActorFrame{
		Def.ActorProxy{
			Name="Scroller";
			InitCommand=cmd(MaskDest);
			BeginCommand=function(self)
				local scroller = SCREENMAN:GetTopScreen():GetChild("LineScroller");
				self:SetTarget(scroller);
			end;			
		};
	
		Def.Quad{
			InitCommand=cmd(CenterX;y,SCREEN_TOP;vertalign,top;zoomto,_screen.w,headerHeight;MaskSource);
		};
	};

	Def.ActorFrame{
		Def.Quad{
			Name="P1bg";
			InitCommand=cmd(x,SCREEN_LEFT;y,SCREEN_TOP;horizalign,left;vertalign,top;zoomto,_screen.cx,headerHeight;diffuse,PlayerColor(PLAYER_1););
			OnCommand=cmd(diffusealpha,0.75;);
		};

		PlayerText(PLAYER_1);
	};

	Def.ActorFrame{
		Def.Quad{
			Name="P2bg";
			InitCommand=cmd(x,SCREEN_RIGHT;y,SCREEN_TOP;horizalign,right;vertalign,top;zoomto,_screen.cx,headerHeight;diffuse,PlayerColor(PLAYER_2););
			OnCommand=cmd(diffusealpha,0.75;);
		};

		PlayerText(PLAYER_2);
	};

	Def.Quad{
		Name="DevicesBG";
		InitCommand=cmd(x,_screen.cx;y,headerHeight/2;zoomto,_screen.w/3.5,headerHeight*0.65;diffuse,color("0.5,0.5,0.5,0.9"));
	};
};

return t;