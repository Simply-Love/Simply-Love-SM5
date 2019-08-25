local color1 = GetHexColor(SL.Global.ActiveColorIndex-1)
local color2 = GetHexColor(SL.Global.ActiveColorIndex)
local style = ThemePrefs.Get("VisualTheme")

local t = Def.ActorFrame{ OffCommand=function(self) self:linear(1) end }

-- centers
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+50) end,
	OnCommand=function(self)
		self:decelerate(0.4):addy(-250)
		    :accelerate(0.5):addy(20):diffusealpha(0)
	end,

	--top center
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flycenter"))..{
		InitCommand=function(self) self:diffuse(color2):diffusealpha(0):rotationy(180):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(50):zoom(1):diffusealpha(0.4)
			    :sleep(0):zoom(0)
		end
	},
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flycenter"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(-50):zoom(0.6):diffusealpha(0.6)
			    :sleep(0):zoom(0)
		end
	},
}

t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+380) end,
	OnCommand=function(self)
		self:decelerate(0.4):addy(-250)
		    :accelerate(0.5):addy(80):diffusealpha(0)
	end,

	--bottom center
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flycenter"))..{
		InitCommand=function(self) self:diffuse(color2):diffusealpha(0):rotationy(180):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(50):zoom(0.6):diffusealpha(0.6)
			    :sleep(0):zoom(0)
		end
	},
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flycenter"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(-50):zoom(1):diffusealpha(0.4)
			    :sleep(0):zoom(0)
		end
	}
}

-- up 200
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OnCommand=function(self)
		self:decelerate(0.4):addy(-200)
		    :accelerate(0.5):addy(100):diffusealpha(0)
	end,

	--top left
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flytop"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(-200):zoom(1):diffusealpha(0.6)
			    :sleep(0):zoom(0)
		end
	},
	--top right
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flytop"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(200):zoom(1):diffusealpha(0.4)
			    :sleep(0):zoom(0)
		end
	}
}

--up 250
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OnCommand=function(self)
		self:decelerate(0.5):addy(-250)
		    :accelerate(0.5):addy(100):diffusealpha(0)
	end,

	--top left
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flytop"))..{
		InitCommand=function(self) self:diffuse(color2):diffusealpha(0):rotationy(180):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(-200):zoom(1.5):diffusealpha(0.3)
			    :sleep(0):zoom(0)
		end
	},
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flytop"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(-200):zoom(0.8):diffusealpha(0.6)
			    :sleep(0):zoom(0)
		end
	},
	--top right
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flytop"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(200):zoom(1.5):diffusealpha(0.2)
			    :sleep(0):zoom(0)
		end
	},
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flytop"))..{
		InitCommand=function(self) self:diffuse(color2):diffusealpha(0):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(200):zoom(0.8):diffusealpha(0.4)
			    :sleep(0):zoom(0)
		end
	}
}

--up 150, out 280
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OnCommand=function(self)
		self:decelerate(0.4):addy(-150)
		    :accelerate(0.5):addy(100):diffusealpha(0)
	end,

	--top left
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flytop"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(-280):zoom(1.2):diffusealpha(0.6)
			    :sleep(0):zoom(0)
		end
	},
	--top right
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flytop"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(280):zoom(1.2):diffusealpha(0.4)
			    :sleep(0):zoom(0)
		end
	}
}

--up 250, out 280
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OnCommand=function(self)
		self:decelerate(0.4):addy(-250)
		    :accelerate(0.5):addy(100):diffusealpha(0)
	end,

	--top left
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flytop"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(-280):zoom(0.2):diffusealpha(0.3)
			    :sleep(0):zoom(0)
		end
	},
	--top right
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flytop"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(280):zoom(0.2):diffusealpha(0.2)
			    :sleep(0):zoom(0)
		end
	}
}

--up 200
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OnCommand=function(self)
		self:decelerate(0.4):addy(-200)
		    :accelerate(0.5):addy(100):diffusealpha(0)
	end,

	--bottom left
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flybottom"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(-200):zoom(1):diffusealpha(0.3)
			    :sleep(0):zoom(0)
		end
	},
	--bottom right
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flybottom"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(200):zoom(1):diffusealpha(0.2)
			    :sleep(0):zoom(0)
		end
	}
}

--up 250
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OnCommand=function(self)
		self:decelerate(0.4):addy(-250)
		    :accelerate(0.5):addy(100):diffusealpha(0)
	end,

	-- bottom left
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flybottom"))..{
		InitCommand=function(self) self:diffuse(color2):diffusealpha(0):rotationy(180):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(-200):zoom(1.5):diffusealpha(0.6)
			    :sleep(0):zoom(0)
		end
	},
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flybottom"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(-200):zoom(0.8):diffusealpha(0.3)
			    :sleep(0):zoom(0)
		end
	},
	-- bottom right
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flybottom"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(200):zoom(1.5):diffusealpha(0.4)
			    :sleep(0):zoom(0)
		end
	},
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flybottom"))..{
		InitCommand=function(self) self:diffuse(color2):diffusealpha(0):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(200):zoom(0.8):diffusealpha(0.2)
			    :sleep(0):zoom(0)
		end
	}
}

--up 150, out 280
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OnCommand=function(self)
		self:decelerate(0.4):addy(-150)
		    :accelerate(0.5):addy(100):diffusealpha(0)
	end,

	--bottom left
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flybottom"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(-280):zoom(1.2):diffusealpha(0.3)
			    :sleep(0):zoom(0)
		end
	},
	--bottom right
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flybottom"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(280):zoom(1.2):diffusealpha(0.2)
			    :sleep(0):zoom(0)
		end
	}
}

--up 250, out 280
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OnCommand=function(self)
		self:decelerate(0.4):addy(-250)
		    :accelerate(0.5):addy(100):diffusealpha(0)
	end,

	--bottom left
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flybottom"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(-280):zoom(0.2):diffusealpha(0.3)
				:sleep(0):zoom(0)
		end
	},
	--bottom right
	LoadActor(THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flybottom"))..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OnCommand=function(self)
			self:accelerate(0.8):addx(280):zoom(0.2):diffusealpha(0.2)
			    :sleep(0):zoom(0)
		end
	}
}

return t