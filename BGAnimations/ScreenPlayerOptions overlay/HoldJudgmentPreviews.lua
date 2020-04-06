local t = ...

for hj_filename in ivalues( GetHoldJudgments() ) do
	local hj

	if hj_filename ~= "None" then
		hj = Def.ActorFrame{
			Name="HoldJudgment_"..StripSpriteHints(hj_filename),
			InitCommand=function(self) self:visible(false) end,

			Def.Sprite{
				Texture=THEME:GetPathG("", "_HoldJudgments/" .. hj_filename),
				InitCommand=function(self) self:animate(false):setstate(0) end
			},
			Def.Sprite{
				Name="HoldJudgment_"..StripSpriteHints(hj_filename),
				Texture=THEME:GetPathG("", "_HoldJudgments/" .. hj_filename),
				InitCommand=function(self) self:animate(false):setstate(1):addx(self:GetWidth()*0.75) end
			}
		}
	else
		hj = Def.Actor{ Name="HoldJudgment_None" }
	end

	t[#t+1] = hj
end