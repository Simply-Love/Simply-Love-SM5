local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

--Let's see if we need to let  the player know that they are nice.
if ThemePrefs.Get("nice") > 0 then
	return LoadActor(THEME:GetPathG("","_grades/graphics/nice.png"))..{
		InitCommand=function(self)
			self:xy(GetNotefieldX(player), _screen.cy )
			self:visible(false):zoom(0.5):diffusealpha(1)
		end,
		OffCommand=function(self)
			local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
			local PercentDP = pss:GetPercentDancePoints()
			local percent = FormatPercentScore(PercentDP):gsub("%%", "")
			-- pss:GetCurrentCombo() ignores potential "Miss combo"
			-- so get the text from the Combo actor instead if it exists
			local combo
			if not mods.HideCombo then
				combo = SCREENMAN:GetTopScreen():GetChild("Player"..pn):GetChild("Combo"):GetChild("Number"):GetText()
			end

			if combo == "69" or string.match(tostring(percent), "69") ~= nil then
				self:visible(true):linear(0.8):y(self:GetY()-50):zoom(3):diffusealpha(0)
			end
		end
	}
end