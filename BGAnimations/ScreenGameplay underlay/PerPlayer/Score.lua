local player = ...
local pn = ToEnumShortString(player)

local mods = SL[pn].ActiveModifiers
local center1p = PREFSMAN:GetPreference("Center1Player")
local IsUltraWide = (GetScreenAspectRatio() > 21/9)

if mods.HideScore then return end

if #GAMESTATE:GetHumanPlayers() > 1
and mods.NPSGraphAtTop
and not IsUltraWide
then return end



-- -----------------------------------------------------------------------

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

-- -----------------------------------------------------------------------

return LoadFont("Wendy/_wendy monospace numbers")..{
	Text="0.00",

	Name=pn.."Score",
	InitCommand=function(self)
		self:valign(1):horizalign(right)
		self:zoom(IsUltraWide and 0.425 or 0.5)
	end,
	BeginCommand=function(self)
		-- assume "normal" score positioning first, but there are many reasons it will need to be moved
		self:xy( pos[player].x, pos[player].y )

		if mods.NPSGraphAtTop and styletype ~= "OnePlayerTwoSides" then
			-- if NPSGraphAtTop and Step Statistics and not double,
			-- move the score down into the stepstats pane under
			-- the jugdgment breakdown
			if mods.DataVisualizations=="Step Statistics" then
				local step_stats = self:GetParent():GetChild("StepStatsPane"..pn)
				local judgmentnumbers = step_stats:GetChild("BannerAndData"):GetChild("JudgmentNumbers"):GetChild("")[1]
				-- padding is a lazy fix for multiple ActorFrames having zoom applied and
				-- me not feeling like recursively crawling the AF tree to factor each in
				local padding = IsUltraWide and -4 or 37

				if IsUsingWideScreen() then
					-- pad with an additional ~14px for each digit past 4 the stepcount goes
					-- this keeps the score right-aligned with the right edge of the judgment
					-- counts in the StepStats pane
					padding = padding + (digits * 14)
				end


				self:x(step_stats:GetX() + judgmentnumbers:GetX() + padding)
				self:y( _screen.cy + 40 )

			-- if NPSGraphAtTop but not Step Statistics
			else
				-- if not Center1Player, move the score right or left
				-- within the normal gameplay header to where the
				-- other player's score would be if this were versus
				if not center1p then
					self:x( pos[ OtherPlayer[player] ].x )
					self:y( pos[ OtherPlayer[player] ].y )
				end
				-- if Center1Player, no need to move the score
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