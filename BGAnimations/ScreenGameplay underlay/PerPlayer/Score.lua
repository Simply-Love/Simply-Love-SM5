local player = ...
local pn = ToEnumShortString(player)

local mods = SL[pn].ActiveModifiers
local IsUltraWide = (GetScreenAspectRatio() > 21/9)
local NumPlayers = #GAMESTATE:GetHumanPlayers()
-- -----------------------------------------------------------------------
-- first, check for conditions where we might not draw the score actor at all

if mods.HideScore then return end
if mods.DoNotJudgeMe then return end

if NumPlayers > 1
and mods.NPSGraphAtTop
and not IsUltraWide
then
	return
end

-- -----------------------------------------------------------------------
-- set up some preliminary variables and calculations for positioning and zooming

local styletype = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())

local pos = {
	[PLAYER_1] = { x=(_screen.cx - clamp(_screen.w, 640, 854)/4.3),  y=56 },
	[PLAYER_2] = { x=(_screen.cx + clamp(_screen.w, 640, 854)/2.75), y=56 },
}

local dance_points, percent
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
local total_tapnotes = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Notes" )

-- determine how many digits are needed to express the number of notes in base-10
local digits = (math.floor(math.log10(total_tapnotes)) + 1)
-- subtract 4 from the digit count; we're only really interested in how many digits past 4
-- this stepcount is so we can use it to align the score actor in the StepStats pane if needed
-- aligned-with-4-digits is the default
digits = clamp(math.max(4, digits) - 4, 0, 3)

local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)

local ar_scale = {
	sixteen_ten  = 0.825,
	sixteen_nine = 1
}
local zoom_factor = clamp(scale(GetScreenAspectRatio(), 16/10, 16/9, ar_scale.sixteen_ten, ar_scale.sixteen_nine), 0, 1.125)

-- -----------------------------------------------------------------------

return LoadFont("Wendy/_wendy monospace numbers")..{
	Text="0.00",

	Name=pn.."Score",
	InitCommand=function(self)
		self:valign(1):horizalign(right)
		self:zoom(0.5)
	end,

	-- FIXME: this is out of control and points to the need for a generalized approach
	--        to positioning and scaling actors based on AspectRatio (4:3, 16:10, 16:9, 21:9),
	--        Step Stats (drawing or not),
	--        NPSGraphAtTop (drawing or not),
	--        Center1Player (see GetNotefieldX() in ./Scripts/SL-Helpers.lua)
	--        and which players are joined

	BeginCommand=function(self)
		-- assume "normal" score positioning first, but there are many reasons it will need to be moved
		self:xy( pos[player].x, pos[player].y )

		if mods.NPSGraphAtTop and styletype ~= "OnePlayerTwoSides" then
			-- if NPSGraphAtTop and Step Statistics and not double,
			-- move the score down into the stepstats pane under
			-- the jugdgment breakdown
			if mods.DataVisualizations=="Step Statistics" then
				local step_stats = self:GetParent():GetChild("StepStatsPane"..pn)

				-- Step Statistics might be true in the SL table from a previous game session
				-- but current conditions might be such that it won't actually appear.
				-- Ensure the StepStats ActorFrame is present before trying to traverse it.
				if step_stats then
					local judgmentnumbers = step_stats:GetChild("BannerAndData"):GetChild("JudgmentNumbers"):GetChild("")[1]

					-- -----------------------------------------------------------------------
					-- FIXME: "padding" is a lazy fix for multiple nested ActorFrames having zoom applied and
					--         me not feeling like recursively crawling the AF tree to factor in each zoom
					local padding

					if NoteFieldIsCentered then
						if IsUltraWide then
							padding = 37
						else
							padding = SL_WideScale(-11.5,27)
						end

					else
						if IsUltraWide then
							if NumPlayers > 1 then
								padding = -2
							else
								padding = 37
							end
						else
							padding = 37
						end
					end

					-- -----------------------------------------------------------------------

					if IsUsingWideScreen() and not (IsUltraWide and NumPlayers > 1) then
						-- pad with an additional ~14px for each digit past 4 the stepcount goes
						-- this keeps the score right-aligned with the right edge of the judgment
						-- counts in the StepStats pane
						padding = padding + (digits * 14)

						if NoteFieldIsCentered then
							padding = clamp(padding, 0, WideScale(-12,43))
							self:zoom( self:GetZoom() * zoom_factor )
						end
					end

					self:x(step_stats:GetX() + judgmentnumbers:GetX() + padding)
					if  IsUltraWide and NumPlayers > 1 then
						self:y(_screen.cy - 2)
					else
						self:y( _screen.cy + 42 )
					end
				end

			-- if NPSGraphAtTop but not Step Statistics
			else
				-- if not Center1Player, move the score right or left
				-- within the normal gameplay header to where the
				-- other player's score would be if this were versus
				if not NoteFieldIsCentered then
					self:x( pos[ OtherPlayer[player] ].x )
					self:y( pos[ OtherPlayer[player] ].y )
				end
				-- if NoteFieldIsCentered, no need to move the score
			end
		end
	end,
	JudgmentMessageCommand=function(self) self:queuecommand("RedrawScore") end,
	RedrawScoreCommand=function(self)
		dance_points = pss:GetPercentDancePoints()
		percent = FormatPercentScore( dance_points ):sub(1,-2)
		self:settext(percent)
	end
}
