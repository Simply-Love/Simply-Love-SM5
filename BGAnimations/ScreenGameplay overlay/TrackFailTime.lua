-- This file will track the time that a player fails and show on the Evaluation screen.
-- Additionally, if the player fails inside a stream (16ths or higher) it will display 
-- the position in the stream (16ths) that they fail.

-- This does not count if the player holds start to fail

local player = ...
local pn = ToEnumShortString(player)

local af = Def.Actor{
	HealthStateChangedMessageCommand=function(self, param)
		if param.PlayerNumber == player and param.HealthState == "HealthState_Dead" then
			local playerstate = GAMESTATE:GetPlayerState(player)
			local seconds = GAMESTATE:GetCurrentSong():MusicLengthSeconds()
			seconds = seconds / SL.Global.ActiveModifiers.MusicRate
			local storage = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
			local songposition = playerstate:GetSongPosition():GetMusicSeconds() / SL.Global.ActiveModifiers.MusicRate
			local songmeasure = math.floor(playerstate:GetSongPosition():GetSongBeatVisible()/4)
			local streams = SL[pn].Streams
			storage.Seconds = seconds
			storage.DeathSecond = songposition

			-- find out if this measure was a stream (16ths or higher)
			if streams.NotesPerMeasure[songmeasure+1] >= 16 then
				-- find out which measure the fail was 
				for i=1,#streams.Measures do
					if songmeasure >= streams.Measures[i].streamStart and songmeasure < streams.Measures[i].streamEnd  then							
						streamrun = songmeasure-streams.Measures[i].streamStart+1
						streamtotal = streams.Measures[i].streamEnd - streams.Measures[i].streamStart
						storage.DeathMeasures = string.format("%s/%s",streamrun,streamtotal)
					end
				end
			end
		end
	end
}

return af
