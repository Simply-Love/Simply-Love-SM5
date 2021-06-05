local t = ...

for judgment_filename in ivalues( GetJudgmentGraphics(SL.Global.GameMode) ) do
	if judgment_filename ~= "None" then
		t[#t+1] = LoadActor( GetJudgmentGraphicsPath(judgment_filename, SL.Global.GameMode) )..{
			Name="JudgmentGraphic_"..StripSpriteHints(judgment_filename),
			InitCommand=function(self)
				self:visible(false):animate(false)
				local num_frames = self:GetNumStates()

				for i,window in ipairs(SL.Global.ActiveModifiers.TimingWindows) do
					if window then
						if num_frames == 12 then
							self:setstate((i-1)*2)
						else
							self:setstate(i-1)
						end
						break
					end
				end
			end
		}
	else
		t[#t+1] = Def.Actor{ Name="JudgmentGraphic_None", InitCommand=function(self) self:visible(false) end }
	end
end
