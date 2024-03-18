local player, use_smaller_graph, notefield_is_centered = unpack(...)
local pn = ToEnumShortString(player)

-- ---------------------------------------------------------------
-- Finds the top score for the current song (or course) given a player.
local GetTopScore = function(kind)
	if not player or not kind then return end

	local SongOrCourse, StepsOrTrail, scorelist

	if GAMESTATE:IsCourseMode() then
		SongOrCourse = GAMESTATE:GetCurrentCourse()
		StepsOrTrail = GAMESTATE:GetCurrentTrail(player)
	else
		SongOrCourse = GAMESTATE:GetCurrentSong()
		StepsOrTrail = GAMESTATE:GetCurrentSteps(player)
	end

	if kind == "Machine" then
		scorelist = PROFILEMAN:GetMachineProfile():GetHighScoreList(SongOrCourse,StepsOrTrail)
	elseif kind == "Personal" then
		scorelist = PROFILEMAN:GetProfile(player):GetHighScoreList(SongOrCourse,StepsOrTrail)
	end

	if scorelist then
		local topscore = scorelist:GetHighScores()[1]
		if topscore then
			if SL[pn].ActiveModifiers.ShowEXScore then
				local counts = {}
				counts["W0"] = topscore:GetTapNoteScore("TapNoteScore_W1") - topscore:GetScore()
				counts["W1"] = topscore:GetScore()
				counts["W2"] = topscore:GetTapNoteScore("TapNoteScore_W2")
				counts["W3"] = topscore:GetTapNoteScore("TapNoteScore_W3")
				counts["W4"] = topscore:GetTapNoteScore("TapNoteScore_W4")
				counts["W5"] = topscore:GetTapNoteScore("TapNoteScore_W5")
				counts["Miss"] = topscore:GetTapNoteScore("TapNoteScore_Miss")
				counts["HitMine"] = topscore:GetTapNoteScore("TapNoteScore_HitMine")
				counts["Held"] = topscore:GetHoldNoteScore("HoldNoteScore_Held")
				ex_score, ex_points, ex_possible = CalculateExScore(player, counts)
				return (ex_score/100)
			else
				return topscore:GetPercentDP()
			end
		end
	end

	return 0
end

-- ---------------------------------------------------------------
-- calculate size and position data for graph(s)

-- FIXME: replace this custom helper function with WideScale()
local get43size = function(size4_3)
	return 640*(size4_3/854)
end


local pos_data = {}

pos_data.BorderWidth = 2

-- overall graph sizing and positioning
pos_data.graph = { h=350, x=0 }
-- individual bar sizing and positioning
pos_data.bar = {}

if use_smaller_graph then
	-- this graph is horizontally condensed compared to the full-width alternative
	pos_data.graph.w = SL_WideScale(25, 70)
	pos_data.graph.y = 429

	-- smaller border for the target bar
	pos_data.BorderWidth = 1

	-- if widescreen, nudge each graph over 5px, potentially creating a 10px gap if bothWantBars
	local separator = IsUsingWideScreen() and 5 or 0

	-- put the graph directly beside the note field
	if player == PLAYER_1 then
		pos_data.graph.x = _screen.cx - pos_data.graph.w - separator
	else
		pos_data.graph.x = _screen.cx + separator
	end

	-- if Center1Player pref, or dance-solo, or techno single8, or kb7 single
	if notefield_is_centered then
		-- if 4:3 force the smaller graph to be 60px from the right edge of the screen
		-- if widescreen, adapt to the width of the notefield
		pos_data.graph.x = WideScale( _screen.w-60, GetNotefieldX(player) + GetNotefieldWidth()/2 + 20)
	end

	pos_data.bar.w = pos_data.graph.w * 0.25
	pos_data.bar.spacing = pos_data.bar.w / 4
	pos_data.bar.offset = pos_data.bar.spacing * (IsUsingWideScreen() and 1 or 1.5)


-- full-width graph
else
	pos_data.graph.w = WideScale(250, 300)
	pos_data.graph.y = 432

	-- put the graph on the other side of the screen
	if (player == PLAYER_1) then
		pos_data.graph.x = WideScale( get43size(500), 500)
	else
		pos_data.graph.x = WideScale( get43size(40), 40)
	end

	pos_data.bar.w = pos_data.graph.w * 0.25
	pos_data.bar.spacing = pos_data.bar.w / 4
	pos_data.bar.offset = pos_data.bar.spacing / 3
end

-- ---------------------------------------------------------------
-- possible target grades, as defined in ./Scripts/SL-PlayerOptions.lua within TargetScore.Values()
-- { 'C-', 'C', 'C+', 'B-', 'B', 'B+', 'A-', 'A', 'A+', 'S-', 'S', 'S+', '☆', '☆☆', '☆☆☆', '☆☆☆☆', 'Machine best', 'Personal best' }

-- the index of the target score chosen in the PlayerOptions menu
local target_score_option = SL[pn].ActiveModifiers.TargetScore

-- the score that corresponds to the chosen target grade by the player
local target_grade_score = 0

if (target_score_option == "Machine best") then
	-- player set TargetGrade as Machine best
	target_grade_score = GetTopScore("Machine")

elseif (target_score_option == "Personal best") then
	-- player set TargetGrade as Personal best
	target_grade_score = GetTopScore("Personal")
else
	-- player set TargetGrade as a particular score
	-- pull from that option
	target_grade_score = tonumber(SL[pn].ActiveModifiers.TargetScoreNumber) / 100
end

-- if there is no personal/machine score, default to S as target
if target_grade_score == 0 then
	target_grade_score = THEME:GetMetric("PlayerStageStats", "GradePercentTier06")
end

-- ---------------------------------------------------------------

return target_grade_score, pos_data, GetTopScore("Personal")