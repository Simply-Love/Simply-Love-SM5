local player = ...
local offsets = {}
local sequential_offsets = {}

return Def.Actor{
	JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if params.HoldNoteScore then return end

		if params.TapNoteOffset then
			local offset = round(params.TapNoteOffset, 3)

            if params.TapNoteScore ~= "TapNoteScore_Miss" then
    			if not offsets[offset] then
    				offsets[offset] = 1
    			else
    				offsets[offset] = offsets[offset] + 1
    			end
            else
                offset = "Miss"
            end

            -- store judgment offsets (including misses) in an indexed table as they come
            -- also store the CurrentMusicSeconds
            sequential_offsets[#sequential_offsets+1] = { GAMESTATE:GetCurMusicSeconds(), offset }
		end
	end,
	OffCommand=function(self)
		local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
		storage.timing_offsets = offsets
        storage.sequential_offsets = sequential_offsets
	end
}