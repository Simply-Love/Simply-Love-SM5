local player, controller = unpack(...)

local pn = ToEnumShortString(player)
local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

local tns_string = "TapNoteScore" .. (SL.Global.GameMode=="ITG" and "" or SL.Global.GameMode)

local firstToUpper = function(str)
    return (str:gsub("^%l", string.upper))
end

local GetTNSStringFromTheme = function( arg )
	return THEME:GetString(tns_string, arg)
end

-- iterating through the TapNoteScore enum directly isn't helpful because the
-- sequencing is strange, so make our own data structures for this purpose
local TapNoteScores = {}
TapNoteScores.Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' }
TapNoteScores.Names = map(GetTNSStringFromTheme, TapNoteScores.Types)

local RadarCategories = {
	THEME:GetString("ScreenEvaluation", 'Hands'),
	THEME:GetString("ScreenEvaluation", 'Holds'),
	THEME:GetString("ScreenEvaluation", 'Mines'),
	THEME:GetString("ScreenEvaluation", 'Rolls')
}

local EnglishRadarCategories = {
	[THEME:GetString("ScreenEvaluation", 'Hands')] = "Hands",
	[THEME:GetString("ScreenEvaluation", 'Holds')] = "Holds",
	[THEME:GetString("ScreenEvaluation", 'Mines')] = "Mines",
	[THEME:GetString("ScreenEvaluation", 'Rolls')] = "Rolls",
}

local scores_table = {}
for index, window in ipairs(TapNoteScores.Types) do
	local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
	scores_table[window] = number
end

local t = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(50 * (controller==PLAYER_1 and 1 or -1), _screen.cy-24)
	end,
}

local windows = SL[pn].ActiveModifiers.TimingWindows

--  labels: W1, W2, W3, W4, W5, Miss

-- Shift labels left if any tap note counts exceeded 9999
-- The positioning logic breaks if we get to 7 digits, please nobody hit a million Fantastics
local maxCount = 1
for i=1, #TapNoteScores.Types do
	local window = TapNoteScores.Types[i]
	local number = pss:GetTapNoteScores( "TapNoteScore_"..window )
	if number > maxCount then maxCount = number end
end

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
				self:y((i-1)*28 -16)
				-- diffuse the JudgmentLabels the appropriate colors for the current GameMode
				self:diffuse( SL.JudgmentColors[SL.Global.GameMode][i] )
			end
		}
		if i==1 and SL[pn].ActiveModifiers.SmallerWhite and SL.Global.GameMode == "FA+" then
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
					self:y(i*26-30)
					-- diffuse the JudgmentLabels the appropriate colors for the current GameMode
					self:diffuse( SL.JudgmentColors[SL.Global.GameMode][i] )
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
	-- Replace hands with the EX score only in FA+ mode.
	-- We have a separate FA+ pane for ITG mode.
	if index == 1 and SL.Global.GameMode == "FA+" then
		t[#t+1] = LoadFont("Wendy/_wendy small")..{
			Text="EX",
			InitCommand=function(self) self:zoom(0.5):horizalign(right) end,
			BeginCommand=function(self)
				self:x( (controller == PLAYER_1 and -160) or 90 )
				self:y(38)
				self:diffuse( SL.JudgmentColors[SL.Global.GameMode][1] )
			end
		}
	else
		local performance = stats:GetRadarActual():GetValue( "RadarCategory_"..firstToUpper(EnglishRadarCategories[label]) )
		local possible = stats:GetRadarPossible():GetValue( "RadarCategory_"..firstToUpper(EnglishRadarCategories[label]) )

		t[#t+1] = LoadFont("Common Normal")..{
			Text=label,
			InitCommand=function(self) self:zoom(0.833):horizalign(right) end,
			BeginCommand=function(self)
				self:x( (controller == PLAYER_1 and -160) or 90 )
				self:y((index-1)*28 + 41)
			end
		}
	end
end

return t
