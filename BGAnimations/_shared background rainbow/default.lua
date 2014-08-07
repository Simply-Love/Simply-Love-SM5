local rColor = -1
local delay = 0.7
local file = THEME:GetPathB("", "_shared background normal/loveheart.png")


local t = Def.ActorFrame{
	OnCommand=cmd(Center; bob; effectmagnitude,0,50,0; effectperiod,8),
	
	Def.ActorFrame{
		OnCommand=cmd(bob; effectmagnitude,0,0,50; effectperiod,12),
		
		Def.ActorFrame{
			InitCommand=cmd(diffusealpha,0; queuecommand, 'Appear'),
			AppearCommand=cmd(linear,1; diffusealpha, 1; queuecommand, "Loop"),
			OffCommand=cmd(linear,1; diffusealpha,0),
			
			LoopCommand=function(self)
				rColor = rColor+1
				self:queuecommand('Rainbow')
				self:sleep(delay)
				self:queuecommand('Loop')
			end,
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor+1)) self:diffusealpha(.3) end;
				InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
				OnCommand=cmd(zoom,1.3;x,000;y,-000;z,-030;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.04;diffusealpha,0.3);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor+1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
				OnCommand=cmd(zoom,1.3;x,-050;y,040;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.04,.01;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor-1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(-1)) end;
				OnCommand=cmd(zoom,1.3;x,050;y,-080;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.05,.02;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor-1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(-1)) end;
				OnCommand=cmd(zoom,1.3;x,-100;y,120;z,-200;customtexturerect,0,0,1,1;texcoordvelocity,0.06,.02;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor+1)) self:diffusealpha(.3) end;
				InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
				OnCommand=cmd(zoom,1.3;x,100;y,-160;z,-040;customtexturerect,0,0,1,1;texcoordvelocity,0.07,.01;diffusealpha,0.3);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor-1)) self:diffusealpha(.3) end;
				InitCommand=function(self) self:diffuse(ColorRGB(-1)) end;
				OnCommand=cmd(zoom,1.3;x,-150;y,210;z,-050;customtexturerect,0,0,1,1;texcoordvelocity,0.08,.01;diffusealpha,0.3);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor-1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(-1)) end;
				OnCommand=cmd(zoom,1.3;x,150;y,-250;z,-200;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.03;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor+1)) self:diffusealpha(.3) end;
				InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
				OnCommand=cmd(zoom,1.3;x,-200;y,290;z,-060;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.03;diffusealpha,0.3);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor-1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(-1)) end;
				OnCommand=cmd(zoom,1.3;x,200;y,-330;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.02;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor+1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
				OnCommand=cmd(zoom,1.3;x,-250;y,370;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.03;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor+1)) self:diffusealpha(.3) end;
				InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
				OnCommand=cmd(zoom,1.3;x,250;y,-410;z,-050;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.01;diffusealpha,0.3);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor-1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(-1)) end;
				OnCommand=cmd(zoom,1.3;x,-300;y,450;z,-000;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.01;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor+1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
				OnCommand=cmd(zoom,1.3;x,300;y,-490;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.01;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor+1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
				OnCommand=cmd(zoom,1.3;x,-350;y,530;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.02;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor-1)) self:diffusealpha(.3) end;
				InitCommand=function(self) self:diffuse(ColorRGB(-1)) end;
				OnCommand=cmd(zoom,1.3;x,350;y,-570;z,-000;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.01;diffusealpha,0.3);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor+1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
				OnCommand=cmd(zoom,1.3;x,-400;y,610;z,-200;customtexturerect,0,0,1,1;texcoordvelocity,0.04,.03;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor+1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
				OnCommand=cmd(zoom,1.3;x,400;y,-650;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.02;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor+1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
				OnCommand=cmd(zoom,1.3;x,-450;y,690;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.02,.04;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor-1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(-1)) end;
				OnCommand=cmd(zoom,1.3;x,450;y,-730;z,-200;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.02;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor+1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
				OnCommand=cmd(zoom,1.3;x,-500;y,770;z,-200;customtexturerect,0,0,1,1;texcoordvelocity,0.06,.01;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor-1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(-1)) end;
				OnCommand=cmd(zoom,1.3;x,500;y,-810;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.04,.01;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor-1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(-1)) end;
				OnCommand=cmd(zoom,1.3;x,-550;y,850;z,-070;customtexturerect,0,0,1,1;texcoordvelocity,0.03,.02;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor-1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(-1)) end;
				OnCommand=cmd(zoom,1.3;x,550;y,-890;z,-200;customtexturerect,0,0,1,1;texcoordvelocity,0.02,.03;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor-1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(-1)) end;
				OnCommand=cmd(zoom,1.3;x,-600;y,930;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.06,.02;diffusealpha,0.2);
			};
			
			LoadActor( file )..{
				RainbowCommand=function(self) self:linear(delay) self:diffuse(ColorRGB(rColor+1)) self:diffusealpha(.2) end;
				InitCommand=function(self) self:diffuse(ColorRGB(1)) end;
				OnCommand=cmd(zoom,1.3;x,600;y,-970;z,-100;customtexturerect,0,0,1,1;texcoordvelocity,0.04,.04;diffusealpha,0.2);
			};
			
		};
	};
};

return t;