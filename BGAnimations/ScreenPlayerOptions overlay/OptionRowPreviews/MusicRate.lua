local t = ...

local MusicRateOptRowIndex = nil

-- get all the LinesNames as a single string from Metrics.ini, split on commas,
local LineNames = split(",", THEME:GetMetric("ScreenPlayerOptions", "LineNames"))
-- and loop through until we find one that matches "ComboFont" (or, we don't).
for i, name in ipairs(LineNames) do
	if name == "MusicRate" then MusicRateOptRowIndex = i-1; break end
end

local PlayerOnMusicRateOptRow = function(p)
	return SCREENMAN:GetTopScreen():GetCurrentRowIndex(p) == MusicRateOptRowIndex
end

-- -----------------------------------------------------------------------

for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	local pn = ToEnumShortString(player)

	t[#t+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
		Name=pn.."_MusicRate_",
		InitCommand=function(self)
			self:zoom(2):x(SL_WideScale(-222,-238)):visible(false)
		end,

		-- OptionRowChanged is broadcast from Metrics.ini under [OptionRow] via TitleGainFocusCommand
		OptionRowChangedMessageCommand=function(self, params)
			-- if the player is currently on the MusicRate OptionRow
			if PlayerOnMusicRateOptRow(player) then
				self:diffuse(1,1,1,1)
			else
				self:diffuse(0.5,0.5,0.5,1)
			end
		end,

		RefreshBPMRangeMessageCommand=function(self, params)
			-- params comes in as a table of already-stringified BPM ranges for p1 and p2
			local i = PlayerNumber:Reverse()[player]+1
			self:settext(params[i])
		end
	}
end