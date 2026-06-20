local color1 = GetHexColor(SL.Global.ActiveColorIndex-2, true)
local color2 = GetHexColor(SL.Global.ActiveColorIndex-1, true)
local style = ThemePrefs.Get("VisualStyle")

local assets = {}
assets.flycenter = THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flycenter")
assets.flytop    = THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flytop")
assets.flybottom = THEME:GetPathG("", "_VisualStyles/".. style .."/TitleMenu flybottom")

local timing = {}
timing.af_decel = 0.4
timing.af_accel = 0.5
timing.img_accel= 0.8
timing.duration = 1

local t = Def.ActorFrame{}

-- -----------------------------------------------------------------------
-- override if it's time to get spooky
if IsSpooky() then
	style = "Spooky/ExtraSpooky"
	assets.flycenter = THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/Bats")
	assets.flytop    = THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/Bats")
	assets.flybottom = THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/Bats")

	-- this is broadcast from ./Graphics/ScreenTitleMenu scroll.lua
	-- when the first choice ("Gameplay") is chosen by the player
	t.TitleMenuToGameplayMessageCommand=function(self)
		-- change tween timing values before OffCommands evaluate them
		timing.af_decel = 0.35
		timing.af_accel = 1.15
		timing.img_accel= 1.45
		timing.duration = 2.5
	end
end
-- -----------------------------------------------------------------------

t.OffCommand=function(self)
	self:sleep(timing.duration)
end

-- centers
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+50) end,
	OffCommand=function(self)
		self:decelerate(timing.af_decel):addy(-250)
		    :accelerate(timing.af_accel):addy(20):diffusealpha(0)
	end,

	--top center
	LoadActor(assets.flycenter)..{
		InitCommand=function(self) self:diffuse(color2):diffusealpha(0):rotationy(180):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(50):zoom(1):diffusealpha(0.4)
			    :sleep(0):zoom(0)
		end
	},
	LoadActor(assets.flycenter)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(-50):zoom(0.6):diffusealpha(0.6)
			    :sleep(0):zoom(0)
		end
	},
}

t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+380) end,
	OffCommand=function(self)
		self:decelerate(timing.af_decel):addy(-250)
		    :accelerate(timing.af_accel):addy(80):diffusealpha(0)
	end,

	--bottom center
	LoadActor(assets.flycenter)..{
		InitCommand=function(self) self:diffuse(color2):diffusealpha(0):rotationy(180):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(50):zoom(0.6):diffusealpha(0.6)
			    :sleep(0):zoom(0)
		end
	},
	LoadActor(assets.flycenter)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(-50):zoom(1):diffusealpha(0.4)
			    :sleep(0):zoom(0)
		end
	}
}

-- up 200
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OffCommand=function(self)
		self:decelerate(timing.af_decel):addy(-200)
		    :accelerate(timing.af_accel):addy(100):diffusealpha(0)
	end,

	--top left
	LoadActor(assets.flycenter)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(-200):zoom(1):diffusealpha(0.6)
			    :sleep(0):zoom(0)
		end
	},
	--top right
	LoadActor(assets.flytop)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(200):zoom(1):diffusealpha(0.4)
			    :sleep(0):zoom(0)
		end
	}
}

--up 250
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OffCommand=function(self)
		self:decelerate(timing.af_decel):addy(-250)
		    :accelerate(timing.af_accel):addy(100):diffusealpha(0)
	end,

	--top left
	LoadActor(assets.flytop)..{
		InitCommand=function(self) self:diffuse(color2):diffusealpha(0):rotationy(180):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(-200):zoom(1.5):diffusealpha(0.3)
			    :sleep(0):zoom(0)
		end
	},
	LoadActor(assets.flytop)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(-200):zoom(0.8):diffusealpha(0.6)
			    :sleep(0):zoom(0)
		end
	},
	--top right
	LoadActor(assets.flytop)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(200):zoom(1.5):diffusealpha(0.2)
			    :sleep(0):zoom(0)
		end
	},
	LoadActor(assets.flytop)..{
		InitCommand=function(self) self:diffuse(color2):diffusealpha(0):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(200):zoom(0.8):diffusealpha(0.4)
			    :sleep(0):zoom(0)
		end
	}
}

--up 150, out 280
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OffCommand=function(self)
		self:decelerate(timing.af_decel):addy(-150)
		    :accelerate(timing.af_accel):addy(100):diffusealpha(0)
	end,

	--top left
	LoadActor(assets.flytop)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(-280):zoom(1.2):diffusealpha(0.6)
			    :sleep(0):zoom(0)
		end
	},
	--top right
	LoadActor(assets.flytop)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(280):zoom(1.2):diffusealpha(0.4)
			    :sleep(0):zoom(0)
		end
	}
}

--up 250, out 280
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OffCommand=function(self)
		self:decelerate(timing.af_decel):addy(-250)
		    :accelerate(timing.af_accel):addy(100):diffusealpha(0)
	end,

	--top left
	LoadActor(assets.flytop)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(-280):zoom(0.2):diffusealpha(0.3)
			    :sleep(0):zoom(0)
		end
	},
	--top right
	LoadActor(assets.flytop)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(280):zoom(0.2):diffusealpha(0.2)
			    :sleep(0):zoom(0)
		end
	}
}

--up 200
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OffCommand=function(self)
		self:decelerate(timing.af_decel):addy(-200)
		    :accelerate(timing.af_accel):addy(100):diffusealpha(0)
	end,

	--bottom left
	LoadActor(assets.flybottom)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(-200):zoom(1):diffusealpha(0.3)
			    :sleep(0):zoom(0)
		end
	},
	--bottom right
	LoadActor(assets.flybottom)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(200):zoom(1):diffusealpha(0.2)
			    :sleep(0):zoom(0)
		end
	}
}

--up 250
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OffCommand=function(self)
		self:decelerate(timing.af_decel):addy(-250)
		    :accelerate(timing.af_accel):addy(100):diffusealpha(0)
	end,

	-- bottom left
	LoadActor(assets.flybottom)..{
		InitCommand=function(self) self:diffuse(color2):diffusealpha(0):rotationy(180):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(-200):zoom(1.5):diffusealpha(0.6)
			    :sleep(0):zoom(0)
		end
	},
	LoadActor(assets.flybottom)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(-200):zoom(0.8):diffusealpha(0.3)
			    :sleep(0):zoom(0)
		end
	},
	-- bottom right
	LoadActor(assets.flybottom)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(200):zoom(1.5):diffusealpha(0.4)
			    :sleep(0):zoom(0)
		end
	},
	LoadActor(assets.flybottom)..{
		InitCommand=function(self) self:diffuse(color2):diffusealpha(0):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(200):zoom(0.8):diffusealpha(0.2)
			    :sleep(0):zoom(0)
		end
	}
}

--up 150, out 280
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OffCommand=function(self)
		self:decelerate(timing.af_decel):addy(-150)
		    :accelerate(timing.af_accel):addy(100):diffusealpha(0)
	end,

	--bottom left
	LoadActor(assets.flybottom)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(-280):zoom(1.2):diffusealpha(0.3)
			    :sleep(0):zoom(0)
		end
	},
	--bottom right
	LoadActor(assets.flybottom)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(280):zoom(1.2):diffusealpha(0.2)
			    :sleep(0):zoom(0)
		end
	}
}

--up 250, out 280
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy+200) end,
	OffCommand=function(self)
		self:decelerate(timing.af_decel):addy(-250)
		    :accelerate(timing.af_accel):addy(100):diffusealpha(0)
	end,

	--bottom left
	LoadActor(assets.flybottom)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):rotationy(180):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(-280):zoom(0.2):diffusealpha(0.3)
				:sleep(0):zoom(0)
		end
	},
	--bottom right
	LoadActor(assets.flybottom)..{
		InitCommand=function(self) self:diffuse(color1):diffusealpha(0):zoom(0) end,
		OffCommand=function(self)
			self:accelerate(timing.img_accel):addx(280):zoom(0.2):diffusealpha(0.2)
			    :sleep(0):zoom(0)
		end
	}
}

if IsSpooky() then
	-- sound effect
	t[#t+1] = LoadActor(THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/spooky.ogg"))..{
		-- only play when the first choice (Gameplay) is chosen
		TitleMenuToGameplayMessageCommand=function(self) self:play() end
	}
end

return t
