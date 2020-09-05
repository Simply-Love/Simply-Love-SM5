local af = Def.ActorFrame{}

-- illuminated
af[#af+1] = LoadActor("./scene-lit.jpg")..{
	InitCommand=function(self) self:diffuse(0,0,0,0) end,
	ShowCommand=function(self) self:sleep(5):accelerate(4.5):diffuse(1,1,1,1):sleep(5):queuecommand("Hide") end,
	HideCommand=function(self) self:visible(false) end
}

-- dark
af[#af+1] = LoadActor("./scene-dark.jpg")..{
	InitCommand=function(self) self:diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(12):accelerate(1.333):diffusealpha(1):smooth(15):diffuse(0.25,0.25,0.35,0.75) end,
}



-- descending moon
af[#af+1] = LoadActor("./moon.png")..{
	InitCommand=function(self) self:valign(1):y(-350):zoom(0.8):diffusealpha(0) end,
	ShowCommand=function(self) self:sleep(11):linear(18):diffusealpha(1):y(-240) end
}

-- trees
af[#af+1] = LoadActor("./trees1.png")..{
	InitCommand=function(self) self:diffuse(0,0,0,0) end,
	ShowCommand=function(self) self:sleep(9):smooth(1.666):diffuse(1,1,1,0.5):smooth(10):diffuse(0.7,0.7,0.7,0.4) end,
}
af[#af+1] = LoadActor("./trees2.png")..{
	InitCommand=function(self) self:diffuse(0,0,0,0) end,
	ShowCommand=function(self) self:sleep(9):smooth(2.333):diffuse(1,1,1,0.5):smooth(10):diffuse(0.7,0.7,0.7,0.4) end,
}


for i=1,3 do

	--------------------------------------
	-- initial stars, slow fade in
	af[#af+1] = LoadActor("./stars" .. i .. ".png")..{
		InitCommand=function(self) self:diffusealpha(0):zoom(1):rotationz(180):x(50) end,
		ShowCommand=function(self)
			self:sleep(0.5*(i-1))
				:smooth(5):diffusealpha(0.6)
				:diffuseshift():effectperiod(3.5+i):effectoffset(3-i):effectcolor1(1,1,1,0.75):effectcolor2(1,1,1,0)
				:sleep(4):decelerate(1.333):diffusealpha(0)
		end,
	}
	af[#af+1] = LoadActor("./stars" .. i .. ".png")..{
		InitCommand=function(self) self:diffusealpha(0):zoom(1):rotationz(180):x(50) end,
		ShowCommand=function(self)
			self:sleep(0.5*(i-1))
				:smooth(5):diffusealpha(0.5)
				:pulse():effectperiod(4+i):effectoffset(3-i):effectmagnitude(1.025,1,1)
				:sleep(4):decelerate(1.333):diffusealpha(0)
		end
	}

	--------------------------------------
	-- second stars, smaller, green-blue
	af[#af+1] = LoadActor("./stars" .. i .. ".png")..{
		InitCommand=function(self) self:diffusealpha(0):zoom(0.7):rotationx(180):xy(-250,-50) end,
		ShowCommand=function(self)
			self:sleep(4 + 0.5*(i-1))
				:decelerate(3.333):diffusealpha(0.6)
				:diffuseshift():effectperiod(3.5+i):effectoffset(3-i):effectcolor1(1,1,1,0):effectcolor2(0.6,1,1,1)
		end,
	}
	af[#af+1] = LoadActor("./stars" .. i .. ".png")..{
		InitCommand=function(self) self:diffusealpha(0):zoom(0.7):rotationx(180):xy(-250,-50) end,
		ShowCommand=function(self)
			self:sleep(4 + 0.5*(i-1))
				:decelerate(3.333):diffusealpha(0.5)
				:pulse():effectperiod(4+i):effectoffset(3-i):effectmagnitude(1.025,1,1)
		end
	}

	--------------------------------------
	-- third stars, smaller, red-blue
	af[#af+1] = LoadActor("./stars" .. i .. ".png")..{
		InitCommand=function(self) self:diffusealpha(0):zoom(1.1):rotationz(90):x(200) end,
		ShowCommand=function(self)
			self:sleep(6 + 0.5*(i-1))
				:smooth(2):diffusealpha(0.6)
				:diffuseshift():effectperiod(3.5+i):effectoffset(3-i):effectcolor1(1,1,1,0):effectcolor2(1,0.85,1,1)
				:sleep(1):decelerate(1.333):diffusealpha(0)
		end,
	}
	af[#af+1] = LoadActor("./stars" .. i .. ".png")..{
		InitCommand=function(self) self:diffusealpha(0):zoom(0.7):rotationz(45):x(-200) end,
		ShowCommand=function(self)
			self:sleep(6 + 0.5*(i-1))
				:smooth(2):diffusealpha(0.5)
				:pulse():effectperiod(4+i):effectoffset(3-i):effectmagnitude(1.025,1,1)
				:sleep(1):decelerate(1.333):diffusealpha(0)
		end
	}

	--------------------------------------
	-- last stars, full size
	af[#af+1] = LoadActor("./stars" .. i .. ".png")..{
		InitCommand=function(self) self:diffusealpha(0) end,
		ShowCommand=function(self)
			self:sleep(8 + (0.5*(i-1)))
				:decelerate(2):diffusealpha(0.6)
				:diffuseshift():effectperiod(3+i):effectoffset(3-i):effectcolor1(1,1,1,1):effectcolor2(1,1,1,0)
		end,
	}
	af[#af+1] = LoadActor("./stars" .. i .. ".png")..{
		InitCommand=function(self) self:diffusealpha(0) end,
		ShowCommand=function(self)
			self:sleep(9 + (0.5*(i-1)))
				:decelerate(2):diffusealpha(0.5)
				:pulse():effectperiod(4+i):effectoffset(3-i):effectmagnitude(1.025,1,1)
		end
	}
end


for i=1,3 do
	af[#af+1] = LoadActor("./person" .. i .. ".png")..{
		InitCommand=function(self) self:diffusealpha(0) end,
		ShowCommand=function(self) self:sleep(12 + (6*(i-1))):smooth(1):diffusealpha(1):sleep(4):smooth(1):diffusealpha(0) end,
	}
end

return af