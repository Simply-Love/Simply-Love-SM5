local file = "loveheart.png";

local t = Def.ActorFrame {

	Def.ActorFrame {
		
		InitCommand=cmd(diffusealpha,0;);
		OnCommand=cmd(accelerate,0.8;diffusealpha,1);
		
		LoadActor( file ) .. {
			InitCommand=function(self) self:diffuse(ColorRGB(0)) end;
			ColorSelectedMessageCommand=function(self) self:linear(.5) self:diffuse(ColorRGB(0)) self:diffusealpha(0.05) end;
			OnCommand=cmd(zoom,1.3;x,000;y,000;z,-000;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.01;diffusealpha,0.05);
		};
		
		LoadActor( file ) .. {
			InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
			ColorSelectedMessageCommand=function(self) self:linear(.5) self:diffuse(ColorRGB(1)) self:diffusealpha(0.2) end;
			OnCommand=cmd(zoom,1.3;x,040;y,040;z,-000;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.02;diffusealpha,0.2);
		};
		
		LoadActor( file ) .. {
			InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
			ColorSelectedMessageCommand=function(self) self:linear(.5) self:diffuse(ColorRGB(1)) self:diffusealpha(0.1) end;
			OnCommand=cmd(zoom,1.3;x,080;y,080;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.01;diffusealpha,0.1);
		};
		
		LoadActor( file ) .. {
			InitCommand=function(self) self:diffuse(ColorRGB(0)) end;
			ColorSelectedMessageCommand=function(self) self:linear(.5) self:diffuse(ColorRGB(0)) self:diffusealpha(0.1) end;
			OnCommand=cmd(zoom,1.3;x,120;y,120;z,-200;customtexturerect,0,0,1,1;texcoordvelocity,0.02,.02;diffusealpha,0.1);
		};
		
		LoadActor( file ) .. {
			InitCommand=function(self) self:diffuse(ColorRGB(0)) end;
			ColorSelectedMessageCommand=function(self) self:linear(.5) self:diffuse(ColorRGB(0)) self:diffusealpha(0.1) end;
			OnCommand=cmd(zoom,1.3;x,200;y,200;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.03;diffusealpha,0.1);
		};
		
		LoadActor( file ) .. {
			InitCommand=function(self) self:diffuse(ColorRGB(0)) end;
			ColorSelectedMessageCommand=function(self) self:linear(.5) self:diffuse(ColorRGB(0)) self:diffusealpha(0.1) end;
			OnCommand=cmd(zoom,1.3;x,280;y,280;z,-300;customtexturerect,0,0,1,1;texcoordvelocity,0.02,.02;diffusealpha,0.1);
		};
		
		LoadActor( file ) .. {
			InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
			ColorSelectedMessageCommand=function(self) self:linear(.5) self:diffuse(ColorRGB(1)) self:diffusealpha(0.1) end;
			OnCommand=cmd(zoom,1.3;x,360;y,360;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.01;diffusealpha,0.1);
		};
		
		LoadActor( file ) .. {
			InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
			ColorSelectedMessageCommand=function(self) self:linear(.5) self:diffuse(ColorRGB(1)) self:diffusealpha(0.05) end;
			OnCommand=cmd(zoom,1.3;x,400;y,400;z,-350;customtexturerect,0,0,1,1;texcoordvelocity,-0.03,.01;diffusealpha,0.05);
		};
		
		LoadActor( file ) .. {
			InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
			ColorSelectedMessageCommand=function(self) self:linear(.5) self:diffuse(ColorRGB(1)) self:diffusealpha(0.1) end;
			OnCommand=cmd(zoom,1.3;x,480;y,480;z,-400;customtexturerect,0,0,1,1;texcoordvelocity,0.05,.03;diffusealpha,0.1);
		};
		
		LoadActor( file ) .. {
			InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
			ColorSelectedMessageCommand=function(self) self:linear(.5) self:diffuse(ColorRGB(1)) self:diffusealpha(0.1) end;
			OnCommand=cmd(zoom,1.3;x,560;y,560;z,-300;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.04;diffusealpha,0.1);
		};
	};
};

return t;