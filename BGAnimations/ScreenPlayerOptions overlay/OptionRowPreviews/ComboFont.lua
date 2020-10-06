local t = ...

-- -----------------------------------------------------------------------
-- Figure out where on the screen the OptionRow for ComboFont is.
-- We could just hardcode this to be a number like 6, because ComboFont
-- is the 7th OptionRow as on this screen as defined in Metrics.ini,
-- but a lot of people like to edit their Metrics.ini and far fewer people
-- are comfortable digging into the many, many Lua files throughout this theme.
-- So, maybe they've moved the ComboFont row somewhere else.  Let's try to accommodate.
local ComboFontOptRowIndex = nil

-- get all the LinesNames as a single string from Metrics.ini, split on commas,
local LineNames = split(",", THEME:GetMetric("ScreenPlayerOptions", "LineNames"))
-- and loop through until we find one that matches "ComboFont" (or, we don't).
for i, name in ipairs(LineNames) do
	if name == "ComboFont" then ComboFontOptRowIndex = i-1; break end
end

local PlayerOnComboFontOptRow = function(p)
	return SCREENMAN:GetTopScreen():GetCurrentRowIndex(p) == ComboFontOptRowIndex
end

-- -----------------------------------------------------------------------

for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	local pn = ToEnumShortString(player)

	for combo_font in ivalues( GetComboFonts() ) do
		if combo_font ~= "None" then

			local prev_beat = nil

			t[#t+1] = LoadFont("_Combo Fonts/" .. combo_font .."/" .. combo_font)..{
				Name=(pn.."_ComboFont_"..combo_font),
				Text="1",
				InitCommand=function(self) self:visible(false) end,

				-- OptionRowChanged is broadcast from Metrics.ini under [OptionRow] via TitleGainFocusCommand
				OptionRowChangedMessageCommand=function(self, params)
					-- if the player is currently on the ComboFont OptionRow
					if PlayerOnComboFontOptRow(player) then
						-- then enter into a "Loop" queue to increment the combo numbers
						self:queuecommand("Loop")
					end
				end,
				LoopCommand=function(self)
					if PlayerOnComboFontOptRow(player) then
						local beat = math.floor(GAMESTATE:GetSongBeat())

						if prev_beat ~= beat then
							self:settext( tonumber(self:GetText())+1 )
							prev_beat = beat

							if ThemePrefs.Get("nice")==2 and self:GetText()=="69" then
								SOUND:DimMusic(PREFSMAN:GetPreference("SoundVolume"),  1.3)
								SOUND:PlayOnce(THEME:GetPathS("", "nice.ogg"))
							end
						end
						-- call stoptweening() to prevent tween overflow that could occur from rapid input from the player
						-- and re-queue this "Loop" every 25ms
						self:stoptweening():sleep(0.025):queuecommand("Loop")
					end
				end
			}
		else
			t[#t+1] = Def.Actor{ Name=(pn.."_ComboFont_None"), InitCommand=function(self) self:visible(false) end }
		end
	end
end