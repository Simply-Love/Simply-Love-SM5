local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

--Let's see if we need to let  the player know that they are nice.
if ThemePrefs.Get("nice") > 0 then
	return LoadActor(THEME:GetPathG("","nice.png"))..{
		InitCommand=function(self)
			self:xy(GetNotefieldX(player), _screen.cy )
			self:visible(false):zoom(0.5):diffusealpha(1)
		end,
		OffCommand=function(self)
			local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
			local PercentDP = pss:GetPercentDancePoints()
			local percent = FormatPercentScore(PercentDP):gsub("%%", "")
			local combo = nil

			if not mods.HideCombo then
				-- At any given time either the normal combo or
				-- the miss combo is zero. We can just add them
				-- together to get the currently active combo
				-- count.
				combo = pss:GetCurrentCombo() + pss:GetCurrentMissCombo()
			end

			if combo == 69 or string.match(tostring(percent), "69") ~= nil then
				self:visible(true):linear(0.8):y(self:GetY()-50):zoom(3):diffusealpha(0)
			end
		end
	}
end
