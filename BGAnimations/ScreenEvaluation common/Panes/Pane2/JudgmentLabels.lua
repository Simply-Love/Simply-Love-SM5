local player, controller = unpack(...)

local pn = ToEnumShortString(player)
local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

local firstToUpper = function(str)
    return (str:gsub("^%l", string.upper))
end

-- iterating through the TapNoteScore enum directly isn't helpful because the
-- sequencing is strange, so make our own data structures for this purpose
local TapNoteScores = {}
local TapNoteScores = {
	Types = { 'W0', 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	Names = {
		THEME:GetString("TapNoteScoreFA+", "W1"),
		THEME:GetString("TapNoteScoreFA+", "W2"),
		THEME:GetString("TapNoteScoreFA+", "W3"),
		THEME:GetString("TapNoteScoreFA+", "W4"),
		THEME:GetString("TapNoteScoreFA+", "W5"),
		THEME:GetString("TapNoteScore", "W5"), -- FA+ mode doesn't have a Way Off window. Extract name from the ITG mode.
		THEME:GetString("TapNoteScoreFA+", "Miss"),
	},
	Colors = {
		SL.JudgmentColors["FA+"][1],
		SL.JudgmentColors["FA+"][2],
		SL.JudgmentColors["FA+"][3],
		SL.JudgmentColors["FA+"][4],
		SL.JudgmentColors["FA+"][5],
		SL.JudgmentColors["ITG"][5], -- FA+ mode doesn't have a Way Off window. Extract color from the ITG mode.
		SL.JudgmentColors["FA+"][6],
	},
	-- x values for P1 and P2
	x = { P1=64, P2=94 }
}

local RadarCategories = {
	THEME:GetString("ScreenEvaluation", 'Holds'),
	THEME:GetString("ScreenEvaluation", 'Mines'),
	THEME:GetString("ScreenEvaluation", 'Rolls')
}

local EnglishRadarCategories = {
	[THEME:GetString("ScreenEvaluation", 'Holds')] = "Holds",
	[THEME:GetString("ScreenEvaluation", 'Mines')] = "Mines",
	[THEME:GetString("ScreenEvaluation", 'Rolls')] = "Rolls",
}

local t = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(50 * (controller==PLAYER_1 and 1 or -1), _screen.cy-24)
	end,
}

-- The FA+ window shares the status as the FA window.
-- If the FA window is disabled, then we consider the FA+ window disabled as well.
local windows = {SL[pn].ActiveModifiers.TimingWindows[1]}
for v in ivalues(SL[pn].ActiveModifiers.TimingWindows) do
	windows[#windows + 1] = v
end

-- Shift labels left if any tap note counts exceeded 9999
-- The positioning logic breaks if we get to 7 digits, please nobody hit a million Fantastics
local maxCount = 1
local counts = GetExJudgmentCounts(player)
for i=1, #TapNoteScores.Types do
	local window = TapNoteScores.Types[i]
	local number = counts[window] or 0
	if number > maxCount then maxCount = number end
end

--  labels: W1, W2, W3, W4, W5, Miss
for i=1, #TapNoteScores.Types do
	-- no need to add BitmapText actors for TimingWindows that were turned off
	if windows[i] or i==#TapNoteScores.Types then
		t[#t+1] = LoadFont("Common Normal")..{
			Text=TapNoteScores.Names[i]:upper(),
			InitCommand=function(self) self:zoom(0.833):horizalign(right):maxwidth(76) end,
			BeginCommand=function(self)
				self:x( (controller == PLAYER_1 and 28) or -28 )
				if maxCount > 9999 then
					length = math.floor(math.log10(maxCount)+1)
					finalPos = 28 - 11*(length-4)
					finalZoom = 0.833 - 0.1*(length-4)
					self:x( (controller == PLAYER_1 and finalPos) or -finalPos ):zoom(finalZoom)
				end
				self:y(i*26 -46)
				-- diffuse the JudgmentLabels the appropriate colors for the current GameMode
				self:diffuse( TapNoteScores.Colors[i] )
			end
		}
		if i==1 and SL[pn].ActiveModifiers.SmallerWhite then
			local show15 = false
			t[#t+1] = LoadFont("Common Normal")..{
				Text="10ms",
				InitCommand=function(self) self:zoom(0.6):horizalign(right):maxwidth(76) end,
				BeginCommand=function(self)
					self:x( (controller == PLAYER_1 and 28) or -28 )
					if maxCount > 9999 then
						length = math.floor(math.log10(maxCount)+1)
						finalPos = 28 - 11*(length-4)
						finalZoom = 0.6 - 0.1*(length-4)
						self:x( (controller == PLAYER_1 and finalPos) or -finalPos ):zoom(finalZoom)
					end
					self:y(i*26-36)
					-- diffuse the JudgmentLabels the appropriate colors for the current GameMode
					self:diffuse( TapNoteScores.Colors[i] )
					self:playcommand("Marquee")
				end,
				MarqueeCommand=function(self)
					if show15 then
						self:settext("15ms")
						show15 = false
					else
						self:settext("10ms")
						show15 = true
					end
					
					self:sleep(2):queuecommand("Marquee")
				end
			}
		end
	end
end

-- labels: hands/ex, holds, mines, rolls
for index, label in ipairs(RadarCategories) do
	if index == 1 then
		t[#t+1] = LoadFont("Wendy/_wendy small")..{
			Text="EX",
			InitCommand=function(self) self:zoom(0.5):horizalign(right) end,
			BeginCommand=function(self)
				self:x( (controller == PLAYER_1 and -160) or 90 )
				self:y(38)
				self:diffuse( SL.JudgmentColors[SL.Global.GameMode][1] )
			end
		}
	end

	local performance = stats:GetRadarActual():GetValue( "RadarCategory_"..firstToUpper(EnglishRadarCategories[label]) )
	local possible = stats:GetRadarPossible():GetValue( "RadarCategory_"..firstToUpper(EnglishRadarCategories[label]) )

	t[#t+1] = LoadFont("Common Normal")..{
		Text=label,
		InitCommand=function(self) self:zoom(0.833):horizalign(right) end,
		BeginCommand=function(self)
			self:x( (controller == PLAYER_1 and -160) or 90 )
			self:y(index*28 + 41)
		end
	}
end

return t
