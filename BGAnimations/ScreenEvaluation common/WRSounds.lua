local FirstPass = true
local RandomSound = nil

local Files = FILEMAN:GetDirListing(THEME:GetCurrentThemeDirectory() .. '/Sounds/WRSounds/', false, true)
local Sounds = {}
for file in ivalues(Files) do
	local extension = file:match('[.](.*)$')
	if extension == 'ogg' or extension == 'mp3' then
		Sounds[#Sounds+1] = file
	end
end

-- don't try to play a sound if the folder is empty.
if #Sounds ~= 0 then
	RandomSound = Sounds[math.random(#Sounds)]
end

local af = Def.ActorFrame {
	InitCommand=function(self)
		-- If the GSL is disabled and we got a quad we still want to play a sound.
		if not IsServiceAllowed(SL.GrooveStats.Leaderboard) then
			for i=1,2 do
				local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(i-1)
				local PercentDP = stats:GetPercentDancePoints()
				local percent = FormatPercentScore(PercentDP)
				if percent == "100.00%" then
					self:playcommand("PlayRandomWRSound")
				end
			end
		end
	end,
	PlayRandomWRSoundMessageCommand=function(self)
		self:sleep(2)
		if FirstPass == true and RandomSound ~= nil then
			self:playcommand("StartSound")
			FirstPass = false
		end
	end,

	Def.Sound {
		File=RandomSound,
		IsAction=false,

		StartSoundCommand=function(self)
			self:play()
		end,

		StopWRSoundMessageCommand=function(self)
			self:stop()
		end,
	},
}

return af