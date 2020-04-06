local t = ...

for hj_filename in ivalues( GetHoldJudgments() ) do
	t[#t+1] = Def.ActorFrame{
		Name="HoldJudgment_"..StripSpriteHints(hj_filename),
		InitCommand=function(self) self:visible(false) end,

		-- held
		Def.Sprite{
			Texture=THEME:GetPathG("", "_HoldJudgments/" .. hj_filename),
			InitCommand=function(self) self:animate(false):setstate(0):addx(-self:GetWidth()*0.4) end
		},
		-- let go
		Def.Sprite{
			Texture=THEME:GetPathG("", "_HoldJudgments/" .. hj_filename),
			InitCommand=function(self) self:animate(false):setstate(1):addx(self:GetWidth()*0.4) end
		}
	}
end