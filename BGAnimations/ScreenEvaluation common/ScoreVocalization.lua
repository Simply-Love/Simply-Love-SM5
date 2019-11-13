local vocalize_dir = THEME:GetCurrentThemeDirectory().."/Other/Vocalize/"

-- if no voice packs are installed, don't bother with the rest of this code
if #FILEMAN:GetDirListing(vocalize_dir, true, false) < 1 then return end

-- if both players have their Vocalization mod set to "None", don't bother with the rest of this code
if  SL.P1.ActiveModifiers.Vocalization == "None"
and SL.P2.ActiveModifiers.Vocalization == "None"
then return end
-- -------------------------------------

local RandomizeVocalization = function()
	-- start by determining how many voices are available in the Vocalization table
	-- they are indexed by key, so the # operator won't work here; we need to manually count
	local keys = {}

	for k,v in pairs(Vocalization) do
		keys[#keys+1] = k
	end

	if #keys > 0 then
		local index = math.random(#keys)
		return keys[index]
	end
end

local ParseScores = function(args)
	local digits = {}

	for k,arg in pairs(args) do
		local score = arg[1]
		local pn = arg[2]

		score = score:gsub("%%","")
		local int = math.floor(score)
		local dec = tonumber(score:sub(-2))

		if int == 100 then
			digits[#digits+1] = {'quad', pn}

		elseif score == 0 then
			 digits[#digits+1] = {nil, pn}

		else
			if int < 20 or int % 10 == 0 then
				digits[#digits+1] = {int, pn}
				digits[#digits+1] = {'point', pn}
			else
				digits[#digits+1] = {int - int % 10, pn}
				digits[#digits+1] = {int % 10, pn}
				digits[#digits+1] = {'point', pn}
			end

			if dec < 20 == 0 then
				digits[#digits+1] = {dec, pn}
			else
				digits[#digits+1] = {(dec - (dec % 10))/10, pn}

				if dec % 10 ~= 0 then
					digits[#digits+1] = {dec % 10, pn}
				end
			end
		end
	end

	return digits
end
-- -------------------------------------

local Digits = {}
local ActiveDigit = 1
local pn, voice

return Def.Actor{

	OnCommand=function(self)
		local scores = {}

		for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
			local percent_dp = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPercentDancePoints()
			-- Format the dance points value into a percentage score string like "77.41%" or "0.00%", using
			-- gsub() to remove the % character that FormatPercentScore() included in the formatted string
			local percent = FormatPercentScore(percent_dp):gsub("%%", "")
			scores[#scores+1] = {percent, ToEnumShortString(player)}
		end

		Digits = ParseScores(scores)

		self:queuecommand("Vocalize")
	end,
	VocalizeCommand=function(self)

		-- check if we are starting to vocalize a new player
		-- pn should be nil at first, at which point we assign it to P1
		-- eventually, we may need to vocalize P2's score, so we'll assign it to P2 then
		if pn ~= Digits[ActiveDigit][2] then

			pn = Digits[ActiveDigit][2]
			voice = SL[pn].ActiveModifiers.Vocalization

			-- if "Random" was chosen as the vocalization, randomly select a voice from those available
			if voice == "Random" then
				voice = RandomizeVocalization()
			end
		end

		-- Do we have a voice enabled?
		if voice and voice ~= "None" then

			-- if "Blender" was chosen, we want to re-randomize the vocalization for each digit
			if SL[pn].ActiveModifiers.Vocalization == "Blender" then
			    voice = RandomizeVocalization()
			end

			-- a voice for this digit should be selected by now, but does the necessary directory actually exist
			-- in ./Other/Vocalize/ ?  The Vocalization table should contain all available voices (when ./Scripts/ was first loaded)
			-- so check if the chosen voice was found (see: ./Scripts/SL-Vocalize.lua)
			if Vocalization[voice] then

			    local number = Digits[ActiveDigit][1]
			    local soundbyte = vocalize_dir .. voice .. "/" .. number .. ".ogg"
			    local sleeptime = Vocalization[voice]["z"..number]

			    -- Is the score a Quad Star? If so, we might need to pick one of the
			    -- many available Quad Star soundbytes available for this voice.
			    if number == "quad" then
			        local NumberOfQuads = 0
			        for k,v in pairs(Vocalization[voice]["quad"]) do
			            NumberOfQuads = NumberOfQuads + 1
			        end

			        local WhichQuad = math.random(NumberOfQuads)
			        sleeptime = Vocalization[voice]["quad"]["z100percent" .. WhichQuad ]
			        number = "100percent" .. WhichQuad
			        soundbyte = vocalize_dir .. voice .. "/" .. number .. ".ogg"
			    end

			    SOUND:PlayOnce( soundbyte )
			    self:sleep( sleeptime )
			end
		end

		ActiveDigit = ActiveDigit+1

		-- prevent infinite queueing by ensuring that there are still digits remaining to vocalize
		if ActiveDigit <= #Digits then
			-- queue this function again to vocalize the next available digit
			self:queuecommand('Vocalize')
		end
	end
}