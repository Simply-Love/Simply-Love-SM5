local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
local notefield_width = GAMESTATE:GetCurrentStyle():GetWidth(player)

-- grab the appropriate x position from ScreenGameplay's
-- metrics on Player positioning

local x_position = THEME:GetMetric( "ScreenGameplay", "Player"..pn..style.."X" )

local timing_data = GAMESTATE:GetCurrentSong():GetTimingData()

local npm = tonumber( string.sub( mods.MeasureCounter, 1, -3))
local song_measure = 0
local measure_count = 0
local steps_this_measure = 0
local new_measure = false
local okay_to_increment = false
local judgment_calls = 0

return Def.BitmapText{
	Font="_wendy small",
	InitCommand=function(self)
		self:horizalign(left)
			:zoom(0.35)
			:xy( x_position - (notefield_width * 1.3), 16 )
	end,
	BeatCrossedMessageCommand=function(self, params)
		new_measure = math.floor(GAMESTATE:GetSongBeat() % 4) == 0
	end,
	JudgmentMessageCommand=function(self, params)
		judgment_calls = judgment_calls + 1
		Trace( judgment_calls )

		-- if params.Player == player then
		-- 	local tns = ToEnumShortString(params.TapNoteScore)
		--
		-- 	-- avoiding mines or holding/not hodling a hold arrow is irrelevant here
		-- 	if tns == "W1" or tns == "W2" or tns == "W3" or tns == "W4" or tns == "W5" or tns == "Miss" then
		--
		-- 		if not new_measure then
		-- 			steps_this_measure = steps_this_measure + 1
		-- 			okay_to_increment = steps_this_measure >= npm
		--
		-- 		else
		-- 			new_measure = false
		-- 			steps_this_measure = 0
		--
		-- 			if okay_to_increment then
		-- 				measure_count = measure_count + 1
		-- 				self:settext( measure_count )
		-- 			else
		-- 				measure_count = 0
		-- 				self:settext( "" )
		-- 			end
		-- 		end
		-- 	end
		-- end

	end
}







if mods.MeasureCounter and mods.MeasureCounter ~= "None" then
	
	local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
	local notefield_width = GAMESTATE:GetCurrentStyle():GetWidth(player)

	-- grab the appropriate x position from ScreenGameplay's
	-- metrics on Player positioning
	local x_position = THEME:GetMetric( "ScreenGameplay", "Player"..pn..style.."X" )

	local timing_data = GAMESTATE:GetCurrentSong():GetTimingData()

	local npm = tonumber( string.sub( mods.MeasureCounter, 1, -3))
	
	local song_measure = 0
	local measure_count = 0
	local steps_this_measure = 0
	local new_measure = false
	local okay_to_increment = false
	local judgment_calls = 0

	t[#t+1] = Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			self:horizalign(left)
			self:zoom(0.35)
			
			self:xy( x_position - (notefield_width * 1.3), 16 )
			-- self:Center()
		end,
		BeatCrossedMessageCommand=function(self, params)
			new_measure = math.floor(GAMESTATE:GetSongBeat() % 4) == 0
		end,
		JudgmentMessageCommand=function(self, params)
			judgment_calls = judgment_calls + 1
			if params.Player == player then
				local tns = ToEnumShortString(params.TapNoteScore)

				-- avoiding mines or holding/not hodling a hold arrow is irrelevant here
				if tns == "W1" or tns == "W2" or tns == "W3" or tns == "W4" or tns == "W5" or tns == "Miss" then

					if not new_measure then
						steps_this_measure = steps_this_measure + 1
						okay_to_increment = steps_this_measure >= npm

					else
						new_measure = false
						steps_this_measure = 0

						if okay_to_increment then
							measure_count = measure_count + 1
							self:settext( measure_count )
						else
							measure_count = 0
							self:settext( "" )
						end
					end
				end
			end

		end
	}
end