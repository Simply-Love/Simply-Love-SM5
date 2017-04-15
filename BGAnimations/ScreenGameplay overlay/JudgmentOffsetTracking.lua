local player = ...
local offsets = {}

return Def.Actor{
	JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if params.TapNoteScore == 'TapNoteScore_Miss' then return end
		if params.HoldNoteScore then return end

		if params.TapNoteOffset then
			local offset = round(params.TapNoteOffset, 3)
			if not offsets[offset] then
				offsets[offset] = 1
			else
				offsets[offset] = offsets[offset] + 1
			end
		end
	end,
	OffCommand=function(self)
		local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
		storage.timing_offsets = offsets
	end
}