local Players = GAMESTATE:GetHumanPlayers()
local Digits = {}
local ActiveDigit = 1

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
		
		local number= Digits[ActiveDigit][1]
		local pn 	= Digits[ActiveDigit][2]
		local voice = SL[pn].ActiveModifiers.Vocalization
		
		-- Do we have a voice enabled?
		if voice ~= "None" then

			local soundbyte = "Themes/" .. THEME:GetThemeDisplayName() .. "/Vocalize/" .. voice .. "/" .. number .. ".ogg"
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
				soundbyte = "Themes/" .. THEME:GetThemeDisplayName() .. "/Vocalize/" .. voice .. "/" .. number .. ".ogg"
			end

			SOUND:PlayOnce( soundbyte )
			self:sleep( sleeptime )
		end
		
		ActiveDigit = ActiveDigit+1
		
		if ActiveDigit <= #Digits then
			self:queuecommand('Vocalize')
		end
	end
}