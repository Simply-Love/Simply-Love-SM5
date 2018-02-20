local t = Def.ActorFrame{}

if ThemePrefs.Get("RainbowMode") then
	t[#t+1] = Def.Quad{
		InitCommand=function(self) self:FullScreen():Center():diffuse( Color.White ) end
	}
	t[#t+1] = LoadActor( THEME:GetPathB("", "_shared background normal"))
	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:diffuse(Color.White):Center():FullScreen()
				:sleep(0.6):linear(0.5):diffusealpha(0)
		end
	}
end

return t