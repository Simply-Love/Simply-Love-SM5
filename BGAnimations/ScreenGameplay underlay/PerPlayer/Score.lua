local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local center1p = PREFSMAN:GetPreference("Center1Player")

if mods.HideScore then return end

if #GAMESTATE:GetHumanPlayers() > 1
and mods.NPSGraphAtTop
then return end

local pos = {
	[PLAYER_1] = { x=(_screen.cx - _screen.w/4.3),  y=56 },
	[PLAYER_2] = { x=(_screen.cx + _screen.w/2.75), y=56 },
}

local dance_points, percent
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

return LoadFont("_wendy monospace numbers")..{
	Text="0.00",

	Name=pn.."Score",
	InitCommand=function(self)
		self:valign(1):halign(1)
		self:zoom(0.5)

		-- assume "normal" score positioning first, but there are many reasons it will need to be moved
		self:xy( pos[player].x, pos[player].y )


		if mods.NPSGraphAtTop then
			-- if NPSGraphAtTop and Step Statistics, move the score down
			-- into the stepstats pane under the jugdgment breakdown
			if mods.DataVisualizations=="Step Statistics" then
				if player==PLAYER_1 then
					self:x( _screen.w - WideScale(15, center1p and 9 or 67) )
				else
					self:x( WideScale(306, center1p and 280 or 358) )
				end

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