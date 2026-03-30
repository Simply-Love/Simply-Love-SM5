local t = ...

for held_miss_filename in ivalues( GetHeldMissGraphics() ) do
	if held_miss_filename ~= "None" then
		t[#t+1] = LoadActor( THEME:GetPathG("", "_HeldMiss/" .. held_miss_filename) )..{
			Name="HeldGraphic_"..StripSpriteHints(held_miss_filename),
			InitCommand=function(self)
				self:visible(false):animate(false)
			end
		}
	else
		t[#t+1] = Def.Actor{ Name="HeldGraphic_None", InitCommand=function(self) self:visible(false) end }
	end
end