local Digits = {}
local ActiveDigit = 1
local pn, voice

local function RandomizeVocalization()
	-- start by determining how many voices are available in the Vocalization table
	-- they are indexed by key, so the # operator won't work here; we need to manually count
	local keys = {}

	for k,v in pairs(Vocalization) do
		keys[#keys+1] = k
	end

	if #keys > 0 then
		local index = math.random(#keys)
		return keys[index]
	else
		return false
	end
end


return Def.Actor{

	OnCommand=function(self)
		local scores = {}
		for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
			local pn = ToEnumShortString(player)
			-- fill the "scores" table with a string representing the score to 2 decimal places and either "P1" or "P2"
			scores[#scores+1] = {self:GetParent():GetChild(pn.."_AF_Lower"):GetChild("Pane1"):GetChild("PercentageContainer"..pn):GetChild("Percent"):GetText(), pn}
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

			-- by now, a voice should be chosen...
			-- but does the necessary directory actually exist in ./Other/Vocalize/ ?
			-- the Vocalization table should contain all available voices (when ./Scripts/ was first loaded)
			-- so check if the chosen voice was found (see: ./Scripts/SL-Vocalize.lua)
			if Vocalization[voice] then

			    local number = Digits[ActiveDigit][1]
			    local soundbyte = GetVocalizeDir() .. voice .. "/" .. number .. ".ogg"
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
			        soundbyte = GetVocalizeDir() .. voice .. "/" .. number .. ".ogg"
			    end

			    SOUND:PlayOnce( soundbyte )
			    self:sleep( sleeptime )
			end

		end

		ActiveDigit = ActiveDigit+1

		-- prevent infinite recursion by ensuring that there are still digits remaining to vocalize
		if ActiveDigit <= #Digits then
			-- recurse
			self:queuecommand('Vocalize')
		end
	end
}