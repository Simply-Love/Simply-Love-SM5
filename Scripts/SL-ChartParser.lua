-- TODO: we shouldn't hardcode this and instead just pass if col is a mine directly.
local MINE_NOTE_TYPE = 4

ParseChartInfo = function(steps, pn)
	local player = pn == "P1" and PLAYER_1 or PLAYER_2

	SL[pn].Streams.NotesPerMeasure = steps:GetNotesPerMeasure(player)
	SL[pn].Streams.NPSperMeasure = steps:GetNpsPerMeasure(player)
	SL[pn].Streams.PeakNPS = steps:GetPeakNps(player)
	SL[pn].Streams.Hash = steps:GetGrooveStatsHash()

	local techCounts = steps:GetTechCounts(player)
	SL[pn].Streams.Crossovers = techCounts:GetValue("TechCountsCategory_Crossovers")
	SL[pn].Streams.Footswitches = techCounts:GetValue("TechCountsCategory_Footswitches")
	SL[pn].Streams.Sideswitches = techCounts:GetValue("TechCountsCategory_Sideswitches")
	SL[pn].Streams.Jacks = techCounts:GetValue("TechCountsCategory_Jacks")
	SL[pn].Streams.Brackets = techCounts:GetValue("TechCountsCategory_Brackets")
end

-- Column cues require decompressing the chart's NoteData, which is expensive.
ParseColumnCues = function(steps, pn)
	local columnCues = steps:GetColumnCues(SL.Global.ColumnCueMinTime)
	for _, cue in ipairs(columnCues) do
		for _, col in ipairs(cue.columns) do
			col.isMine = (col.noteType == MINE_NOTE_TYPE)
			col.noteType = nil
		end
	end
	SL[pn].Streams.ColumnCues = columnCues
end
