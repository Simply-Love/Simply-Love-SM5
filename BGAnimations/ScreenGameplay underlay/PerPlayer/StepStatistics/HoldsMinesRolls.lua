local player = ...

local IsUltraWide = (GetScreenAspectRatio() > 21/9)
local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)

-- gray is used for leading 0s
local gray = color("#5A6166")
local row_height = 28

local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)

-- -----------------------------------------------------------------------
-- helper function

-- accepts a non-negative number
-- returns how many digits are needed to express that number in base-10
local Base10Digits = function(val)
	if type(val) ~= "number" then return nil end
	if val  < 0 then return nil end
	if val == 0 then return 1   end
	return (math.floor(math.log10(val)) + 1)
end

-- -----------------------------------------------------------------------
-- SETUP: get numerical counts for Holds, Mines, and Rolls using the SM5
--        engine's RadarValues interface

local RadarCategories = { 'Holds', 'Mines', 'Rolls' }

-- use RCJudgments to track player performance during gameplay
-- use RCPossible to contain the total numbers for each type
local RCJudgments = { Holds=0,  Mines=0,  Rolls=0  }
local RCPossible  = { Holds={}, Mines={}, Rolls={} }

-- get number values for RCPossible
for i, category in ipairs(RadarCategories) do
	RCPossible[category].count = StepsOrTrail:GetRadarValues( player ):GetValue( category )
end

-- how many digits do we need the UI to accommodate?
local largest = math.max( RCPossible.Holds.count, RCPossible.Mines.count, RCPossible.Rolls.count )
-- fall back on 0 if our helper function returns nil
local digits_needed = Base10Digits(largest) or 0

-- digits_needed might be 1, 2, 3, 4, etc.
-- ensure we show at least 3 for aesthetic purposes
local digits_to_fmt = clamp(digits_needed, 3, 4)

-- generate a Lua string pattern to leftpad a number with 0s
local patternPfrm = ("%%0%dd"):format( digits_to_fmt )
local patternPsbl = "%s"

-- a pattern for formatting performance/possible numbers with an appropriate quantity of leading 0s
local fmt = ("%s/%s"):format(patternPfrm, patternPsbl)

-- -----------------------------------------------------------------------
-- MORE SETUP: with RadarValue counts and string patterns handled, we can set:
--      display, a player-facing string representing the possible RadarValue
--      dimLen,  how many characters to dim the brightness of using AddAttribute()
--               typically for leading 0s

for i, category in ipairs(RadarCategories) do
	-- non-static courses (e.g. Player's Best 1-4) will have -1
	-- use a question mark to indicate we don't know the count
	-- FIXME: patch this in the SM5 engine to not return -1
	if RCPossible[category].count < 0 then
		-- display is a string to display
		-- dimLen is how many characters to dim the brightness of using AddAttribute()
		RCPossible[category].display = "???"
		RCPossible[category].dimLen  = 3

	-- very long courses may have Mines, Hold, and/or Rolls counts larger than 9999
	-- but there's not enough space in the layout to support more than five digits
	-- so use "10k+" to represent "a lot"
	elseif RCPossible[category].count > 9999 then
		RCPossible[category].display = "10k+"
		RCPossible[category].dimLen  = 0

	else
		RCPossible[category].display = ( ("%%0%dd"):format(digits_to_fmt) ):format(RCPossible[category].count)
		RCPossible[category].dimLen  = digits_to_fmt - Base10Digits(RCPossible[category].count)
	end
end

-- -----------------------------------------------------------------------

local af = Def.ActorFrame{ Name="HoldsMinesRolls" }

-- position the ActorFrame
af.InitCommand=function(self)
	self:x(player==PLAYER_1 and 155 or -85)
	self:y(-140)

	if NoteFieldIsCentered and IsUsingWideScreen() then
		self:x( player==PLAYER_1 and 155 or -88 )
	end

	-- adjust for smaller panes when ultrawide and both players joined
	if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
		self:x( player==PLAYER_1 and 14 or 50 )
	end
end


-- loop through our RadarCategories table, adding
-- two BitmapText actors for each: a label and a value
for i, category in ipairs(RadarCategories) do

	local possibleAttr = { Diffuse=gray }

	-- labels: holds, mines, rolls
	af[#af+1] = LoadFont("Common Normal")..{
		Name=("%s_Label"):format(category),
		Text=THEME:GetString("ScreenEvaluation", category),
		InitCommand=function(self)
			self:zoom(0.833):horizalign( right )
			self:y( (i-1)*row_height )
		end,
		PositionCommand=function(self, params)
			self:x((player==PLAYER_1 and -10 or 90) - (params.Offset or 0))
		end
	}

	-- player performance value / possible value
	af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " ScreenEval")..{
		Name=("%s_Values"):format(category),
		InitCommand=function(self)
			self:zoom(0.4):horizalign( right )
			self:x( player==PLAYER_1 and 0 or 100 )
			self:y( (i-1)*row_height )
		end,
		BeginCommand=function(self)

			self:settext( (fmt):format(0, RCPossible[category].display) )

			-----------------------------------------------------------------
			-- diffuse the leading 0s for the player performance value
			local performanceAttr = {
				Length=digits_to_fmt - 1,
				Diffuse=gray
			}
			self:AddAttribute(0, performanceAttr)

			-----------------------------------------------------------------
			-- diffuse the slash and leading 0s for the possible value

			possibleAttr.Length = RCPossible[category].dimLen + 1 -- +1 to include the / character
			self:AddAttribute(digits_to_fmt, possibleAttr)

			-----------------------------------------------------------------
			-- position the label now that we know how many digits there are
			-- 36 comes from the width of characters in this Wendy ScreenEval font
			-- it's not immediately portable to other themes with different fonts, but easy enough to change
			local offset = (self:GetText():len() * 36) * self:GetZoom()
			self:GetParent():GetChild(("%s_Label"):format(category)):playcommand("Position", {Offset=offset})

		end,
		JudgmentMessageCommand=function(self, params)
			if params.Player ~= player then return end
			if not params.TapNoteScore then return end

			if category=="Mines" and params.TapNoteScore == "TapNoteScore_AvoidMine" then
				RCJudgments.Mines = RCJudgments.Mines + 1

			elseif category=="Holds" and params.TapNote and params.TapNote:GetTapNoteSubType() == "TapNoteSubType_Hold" then
				RCJudgments.Holds = RCJudgments.Holds + 1

			elseif category=="Rolls" and params.TapNote and params.TapNote:GetTapNoteSubType() == "TapNoteSubType_Roll" then
				RCJudgments.Rolls = RCJudgments.Rolls + 1

			else
				-- if Mines, Holds, or Rolls didn't change, return early from the function now
				-- no need to settext, calculate digits, and diffuse leading 0s if nothing changed
				return
			end

			self:settext( (fmt):format(RCJudgments[category], RCPossible[category].display) )

			-- determine how many digits are needed to express the current player performance value in base-10
			local digits = Base10Digits(RCJudgments[category])
			local length = digits_to_fmt - digits

			-----------------------------------------------------------------
			-- make leading 0s a dim gray; this is the normal case for values like "042/125"
			-- the leading "0" in "042" should be a dimmed gray color, as well as the slash
			if length >= 0 then
				-- diffuse the leading 0s for the player performance value
				self:AddAttribute(0, { Length=length; Diffuse=gray } )

				-- diffuse the slash and any leading 0s for the possible value
				self:AddAttribute(digits_to_fmt, possibleAttr)


			-- if length is negative, it means the player performance value has
			-- exceeded 9999, and we have a value like "10053/10k+"
			-- the only thing that should be dimmed now is the slash.
			--
			-- Note that, for aesthetic reasons, this is initially formatted
			-- like "0000/10k+", it counts up to 9999 as gameplay progresses, and
			-- eventually visually spills over like "10053/10k+".  This is not a perfect
			-- system, but it's not awful, and situations where it shows up should at
			-- least be uncommon.
			else
				-- diffuse just the slash
				self:AddAttribute( self:GetText():len()-5, { Length=1; Diffuse=gray } )
			end
			-----------------------------------------------------------------
		end
	}
end

return af