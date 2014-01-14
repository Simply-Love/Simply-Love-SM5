local dc1 = DifficultyIndexColor(1);
local dc2 = DifficultyIndexColor(2);

local t = Def.ActorFrame{
	OffCommand=cmd(linear,1);
};

-- centers
t[#t+1] = Def.ActorFrame {
	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+50;diffusealpha,1;decelerate,0.4;addy,-250;accelerate,0.5;addy,20;diffusealpha,0;);
	
	--top center
	LoadActor("ScreenTitleMenu underlay/heartflycenter.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)			
			self:diffuse(dc2);
			self:rotationy(180);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(50);
			self:zoom(1);
			self:diffusealpha(0.4);
			self:sleep(0);
			self:zoom(0);
		end
	};	
	
	LoadActor("ScreenTitleMenu underlay/heartflycenter.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1)
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(-50);
			self:zoom(0.6);
			self:diffusealpha(0.6);
			self:sleep(0);
			self:zoom(0);
		end
	};
};


t[#t+1] = Def.ActorFrame {
	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+380;diffusealpha,1;decelerate,0.4;addy,-250;accelerate,0.5;addy,80;diffusealpha,0;);
	
	--bottom center
	LoadActor("ScreenTitleMenu underlay/heartflycenter.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc2);
			self:rotationy(180);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(50);
			self:zoom(0.6);
			self:diffusealpha(0.6);
			self:sleep(0);
			self:zoom(0);
		end
	};

	LoadActor("ScreenTitleMenu underlay/heartflycenter.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1)
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(-50);
			self:zoom(1);
			self:diffusealpha(0.4);
			self:sleep(0);
			self:zoom(0);
		end
	};
}



-- up 200
t[#t+1] = Def.ActorFrame {
	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+200;diffusealpha,1;decelerate,0.4;addy,-200;accelerate,0.5;addy,100;diffusealpha,0;);
	
	--top left
	LoadActor("ScreenTitleMenu underlay/heartflytop.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:rotationy(180);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(-200);
			self:zoom(1.0);
			self:diffusealpha(0.6);
			self:sleep(0);
			self:zoom(0);
		end
	};


	--top right
	LoadActor("ScreenTitleMenu underlay/heartflytop.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(200);
			self:zoom(1.0);
			self:diffusealpha(0.4);
			self:sleep(0);
			self:zoom(0);	
		end
	};
}





--up 250
t[#t+1] = Def.ActorFrame {
	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(x,SCREEN_CENTER_X; y,SCREEN_CENTER_Y+200;diffusealpha,1; decelerate,0.5; addy,-250; accelerate,0.5; addy,100;diffusealpha,0;);
	
	--top left
	LoadActor("ScreenTitleMenu underlay/heartflytop.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc2);
			self:rotationy(180);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(-200);
			self:zoom(1.5);
			self:diffusealpha(0.3);
			self:sleep(0);
			self:zoom(0);
		end
	};


	LoadActor("ScreenTitleMenu underlay/heartflytop.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:rotationy(180);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(-200);
			self:zoom(0.8);
			self:diffusealpha(0.6);
			self:sleep(0);
			self:zoom(0);
		end
	};
	
	
	--top right
	LoadActor("ScreenTitleMenu underlay/heartflytop.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(200);
			self:zoom(1.5);
			self:diffusealpha(0.2);
			self:sleep(0);
			self:zoom(0);
		end
	};


	LoadActor("ScreenTitleMenu underlay/heartflytop.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc2);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(200);
			self:zoom(0.8);
			self:diffusealpha(0.4);
			self:sleep(0);
			self:zoom(0);
		end
	};
}



--up 150, out 280
t[#t+1] = Def.ActorFrame {
	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+200;diffusealpha,1;decelerate,0.4;addy,-150;accelerate,0.5;addy,100;diffusealpha,0;);
	
	--top left
	LoadActor("ScreenTitleMenu underlay/heartflytop.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:rotationy(180);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(-280);
			self:zoom(1.2);
			self:diffusealpha(0.6);
			self:sleep(0);
			self:zoom(0);
		end
	};
		
	--top right
	LoadActor("ScreenTitleMenu underlay/heartflytop.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(280);
			self:zoom(1.2);
			self:diffusealpha(0.4);
			self:sleep(0);
			self:zoom(0);
		end
	};
}
		
	
--up 250, out 280
t[#t+1] = Def.ActorFrame {
	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+200;diffusealpha,1;decelerate,0.4;addy,-250;accelerate,0.5;addy,100;diffusealpha,0;);
	
	--top left
	LoadActor("ScreenTitleMenu underlay/heartflytop.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:rotationy(180);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(-280);
			self:zoom(0.2);
			self:diffusealpha(0.3);
			self:sleep(0);
			self:zoom(0);
		end
	};
	
	--top right
	LoadActor("ScreenTitleMenu underlay/heartflytop.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(280);
			self:zoom(0.2);
			self:diffusealpha(0.2);
			self:sleep(0);
			self:zoom(0);
		end
	};
}	
	
	
	
--up 200
t[#t+1] = Def.ActorFrame {
	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+200;diffusealpha,1;decelerate,0.4;addy,-200;accelerate,0.5;addy,100;diffusealpha,0;);

	--bottom left
	LoadActor("ScreenTitleMenu underlay/heartflybottom.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:rotationy(180);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(-200);
			self:zoom(1.0);
			self:diffusealpha(0.3);
			self:sleep(0);
			self:zoom(0);
		end
	};
	
	--bottom right
	LoadActor("ScreenTitleMenu underlay/heartflybottom.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(200);
			self:zoom(1.0);
			self:diffusealpha(0.2);
			self:sleep(0);
			self:zoom(0);
		end
	};
}
		

--up 250		
t[#t+1] = Def.ActorFrame {
	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+200;diffusealpha,1;decelerate,0.4;addy,-250;accelerate,0.5;addy,100;diffusealpha,0;);
	
	-- bottom left
	LoadActor("ScreenTitleMenu underlay/heartflybottom.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc2);
			self:rotationy(180);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(-200);
			self:zoom(1.5);
			self:diffusealpha(0.6);
			self:sleep(0);
			self:zoom(0);
		end
	};
	LoadActor("ScreenTitleMenu underlay/heartflybottom.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:rotationy(180);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(-200);
			self:zoom(0.8);
			self:diffusealpha(0.3);
			self:sleep(0);
			self:zoom(0);
		end
	};
	-- bottom right
	LoadActor("ScreenTitleMenu underlay/heartflybottom.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(200);
			self:zoom(1.5);
			self:diffusealpha(0.4);
			self:sleep(0);
			self:zoom(0);
		end
	};
	
	
	
	LoadActor("ScreenTitleMenu underlay/heartflybottom.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc2);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(200);
			self:zoom(0.8);
			self:diffusealpha(0.2);
			self:sleep(0);
			self:zoom(0);
		end
	};		
}

--up 150, out 280
t[#t+1] = Def.ActorFrame {
	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y+200;diffusealpha,1;decelerate,0.4;addy,-150;accelerate,0.5;addy,100;diffusealpha,0;);
		
	--bottom left
	LoadActor("ScreenTitleMenu underlay/heartflybottom.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:rotationy(180);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(-280);
			self:zoom(1.2);
			self:diffusealpha(0.3);
			self:sleep(0);
			self:zoom(0);
		end
	};
	
	--bottom right
	LoadActor("ScreenTitleMenu underlay/heartflybottom.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(280);
			self:zoom(1.2);
			self:diffusealpha(0.2);
			self:sleep(0);
			self:zoom(0);
		end
	};
}

--up 250, out 280

t[#t+1] = Def.ActorFrame {

	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(x,SCREEN_CENTER_X; y,SCREEN_CENTER_Y+200;diffusealpha,1; decelerate,0.4; addy,-250; accelerate,0.5; addy,100; diffusealpha,0;);
	
	--bottom left
	LoadActor("ScreenTitleMenu underlay/heartflybottom.png") .. {
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:diffuse(dc1);
			self:rotationy(180);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(-280);
			self:zoom(0.2);
			self:diffusealpha(0.3);
			self:sleep(0);
			self:zoom(0);
		end
	};
	--bottom right
	LoadActor("ScreenTitleMenu underlay/heartflybottom.png") .. {
		InitCommand=cmd(diffusealpha,0); 
		OnCommand=function(self)
			self:diffuse(dc1);
			self:zoom(0);
			self:diffusealpha(0);
			self:accelerate(0.8);
			self:addx(280);
			self:zoom(0.2);
			self:diffusealpha(0.2);
			self:sleep(0);
			self:zoom(0);
		end
	};
}






return t;