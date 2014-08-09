local Players = GAMESTATE:GetHumanPlayers()
local Digits = {}
local ActiveDigit = 1
local pn, voice

local function RandomizeVocalization()
		
	-- what voice directories exist in ./Simply Love//Other/Vocalize/ ?
	local files = FILEMAN:GetDirListing("Themes/" .. THEME:GetThemeDisplayName() .. "/Other/Vocalize/" , true, false)
	local voices = {}

	for k,dir in ipairs(files) do
		-- Dynamically fill the table.
		voices[#voices+1] = dir
	end
	local WhichVoice = math.random(#voices)
	
	return voices[WhichVoice]	
end


return Def.Actor{
	OnCommand=function(self)
		local scores = {}
		for player in ivalues(Players) do
			local pn = ToEnumShortString(player)
			scores[#scores+1] = self:GetParent():GetChild(pn.." AF Lower"):GetChild("PercentageContainer"..pn):GetText()
		end
		Digits = ParseScores(scores)
		
		self:queuecommand("Vocalize")
	end,
	VocalizeCommand=function(self)
		
		
		-- if we are starting to vocalize a new player
		if pn ~= Digits[ActiveDigit][2] then
			pn = Digits[ActiveDigit][2]
			voice = SL[pn].ActiveModifiers.Vocalization
			
			-- if "Random" was chosen as the vocalization, randomly select a voice from those available
			if voice == "Random" then
				voice = RandomizeVocalization()
			end
		end
		
		
		-- Do we have a voice enabled?
		if voice ~= "None" then
			if SL[pn].ActiveModifiers.Vocalization == "Blender" then
				voice = RandomizeVocalization()
			end
			
			if not Vocalization[voice] then
				-- load the voice timings
				dofile(THEME:GetPathO("","Vocalize/" .. voice .. "/default.lua"))
			end
			
			local number = Digits[ActiveDigit][1]
			local soundbyte = "Themes/" .. THEME:GetThemeDisplayName() .. "/Other/Vocalize/" .. voice .. "/" .. number .. ".ogg"
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
				soundbyte = "Themes/" .. THEME:GetThemeDisplayName() .. "/Other/Vocalize/" .. voice .. "/" .. number .. ".ogg"
			end

			SOUND:PlayOnce( soundbyte )
			self:sleep( sleeptime )
		end
		
		ActiveDigit = ActiveDigit+1
		
		-- prevent infinite recursion by ensuring that there are still digits remaining to vocalize
		if ActiveDigit <= #Digits then
			
			-- recurse
			self:queuecommand('Vocalize')
		end
	end
}