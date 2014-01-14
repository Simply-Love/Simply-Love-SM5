local Players = GAMESTATE:GetHumanPlayers();

local t = Def.ActorFrame{
	Def.Quad{
		InitCommand=cmd(Center;zoomto,SCREEN_WIDTH,50;diffuse,color("#FFFFFF"));
		OnCommand=cmd(fadebottom,0.15;fadetop,0.15);
		OffCommand=cmd(accelerate,0.15;zoomy,0);
	};

	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenProfileSave","Saving Profiles...");
		InitCommand=cmd(Center;diffuse,color("#000000");shadowlength,0; zoom,0.6);
		OffCommand=cmd(linear,0.15;diffusealpha,0);
	};
};

t[#t+1] = Def.Actor {
	BeginCommand=function(self)
		if SCREENMAN:GetTopScreen():HaveProfileToSave() then
			
			for pn in ivalues(Players) do
				PROFILEMAN:SaveProfile(pn);
			end
		end;
		
		self:queuecommand("Load");
	end;
	LoadCommand=function()
		SCREENMAN:GetTopScreen():Continue();
	end;
};

return t;