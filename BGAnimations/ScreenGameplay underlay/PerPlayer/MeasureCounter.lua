local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local npm = tonumber( string.sub( mods.MeasureCounter, 1, -3))
local PlayerState = GAMESTATE:GetPlayerState(player)

local current_beat, previous_beat
local measure_count = 0
local steps_this_measure = 0
local MeasureCounterBMT

local function Update(self, delta)

	current_beat = PlayerState:GetSongPosition():GetSongBeatVisible()

	-- previous_beat will initially be nil; set it to be the same as current_beat
	if not previous_beat then previous_beat = current_beat end

	local new_beat_has_occurred = math.floor(current_beat) > math.floor(previous_beat)

	if new_beat_has_occurred then
		previous_beat = current_beat
	 	local new_measure = math.floor(current_beat % 4) == 0

		if new_measure then

			-- (npm - 1) because the sometimes the appropriate npm will be achieved
			-- but not tracked/counted/something.  I'm not sure why this happens.
			-- Maybe this is a normal amount of hiccups that any engine will experience.
			-- Maybe I'm going about this the wrong way.  At any rate, this is
			-- acceptable kludge for now because it works.
			local okay_to_increment = steps_this_measure >= npm-1

			-- it's a new measure, so reset the step count for this measure
			steps_this_measure = 0
			local text = ""

			if okay_to_increment then
				measure_count = measure_count + 1
				text = tostring(measure_count)
			else
				measure_count = 0
			end

			MeasureCounterBMT:settext( text )
		end
	end

	return
end

if mods.MeasureCounter and mods.MeasureCounter ~= "None" then

	local af = Def.ActorFrame{
		InitCommand=function(self)
			self:queuecommand("SetUpdate")
		end,
		SetUpdateCommand=function(self)
			self:SetUpdateFunction( Update )
		end
	}

	af[#af+1] = Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			MeasureCounterBMT = self

			local style = GAMESTATE:GetCurrentStyle(player)
			local width = style:GetWidth(player)
			local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()

			self:zoom(0.35)
				:xy( GetNotefieldX(player) - (width/NumColumns), _screen.cy )
				:shadowlength(1)
		end,
		JudgmentMessageCommand=function(self, params)

			-- If this judgement message belongs to this player
			-- and if there is at least one note that triggered it,
			-- then increment the step count for the current measure.
			--
			-- Using params.Notes is the best way to do this that I've found so far.
			-- params.Notes not being nil could mean a tapnote, a jump, or a hold head
			-- params.Notes will be nil for mines and hold caps, as is desired here.
			if params.Player == player and params.Notes ~= nil then
				steps_this_measure = steps_this_measure + 1
			end
		end
	}

	return af

else
	return Def.Actor{}
end
