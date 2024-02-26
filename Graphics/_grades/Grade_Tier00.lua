local pss = ...

local function Spin(self)
	r = math.min(math.random(3,51),36)
	s = math.random()*7+1
	z = self:GetZ()
	l = r/36

	if z >= 36 then
		z = z-36
		self:z(z)
		self:rotationz(z*10)
	end

	z = z + r
	self:linear(l)
	self:rotationz(z*10)
	self:z(z)
	self:sleep(s)
	self:queuecommand("Spin")
end

return Def.ActorFrame{
	--top middle
	LoadActor("star.lua", pss)..{
		OnCommand=function(self) self:x(0):y(-54):zoom(0.35):pulse():effectmagnitude(1,0.9,0):sleep(5):queuecommand("Spin") end,
		SpinCommand=function(self) Spin(self) end
	},

	--top left
	LoadActor("star.lua", pss)..{
		OnCommand=function(self) self:x(-52):y(-16):zoom(0.35):pulse():effectmagnitude(1,0.9,0):sleep(60):queuecommand("Spin") end,
		SpinCommand=function(self) Spin(self) end
	},

	--top right
	LoadActor("star.lua", pss)..{
		OnCommand=function(self) self:x(52):y(-16):zoom(0.35):effectoffset(0.2):pulse():effectmagnitude(0.9,1,0):sleep(3):queuecommand("Spin") end,
		SpinCommand=function(self) Spin(self) end
	},

	-- bottom left
	LoadActor("star.lua", pss)..{
		OnCommand=function(self) self:x(-32):y(50):zoom(0.35):effectoffset(0.4):pulse():effectmagnitude(0.9,1,0):sleep(11):queuecommand("Spin") end,
		SpinCommand=function(self) Spin(self) end
	},

	--  bottom right
	LoadActor("star.lua", pss)..{
		OnCommand=function(self) self:x(32):y(50):zoom(0.35):effectoffset(0.6):pulse():effectmagnitude(1,0.9,0):sleep(48):queuecommand("Spin") end,
		SpinCommand=function(self) Spin(self) end
	}
}