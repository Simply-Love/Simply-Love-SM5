-- This file will track the time that a player fails and show on the Evaluation screen.
-- Additionally, if the player fails inside a stream (16ths or higher) it will display 
-- the position in the stream (16ths) that they fail.

-- This does not count if the player holds start to fail

local player = ...
local pn = ToEnumShortString(player)

local af = Def.Actor{
	HealthStateChangedMessageCommand=function(self, param)
		-- Only do something if the player fails
		if param.PlayerNumber == player and param.HealthState == "HealthState_Dead" then			
			local playerState = GAMESTATE:GetPlayerState(player)			
			
			-- These functions already account for rate mod
			local currentSecond = currentTimeSongOrCourse(player)
			-- Not only is the course mode graph useless, it's also kinda weird
			-- It only shows the lifebar history for the entire course up until the end of the current song
			-- So for positioning in course mode, we need to find the total time of all the songs
			-- up until the end of the current song. This is maybe correct
			local totalSeconds = totalLengthSongOrCourse(player)
			local deathSecond = currentTimeSongOrCourse(player)
			local graphPercentage, graphLabel

			if GAMESTATE:IsCourseMode() then 
				local cumulative_seconds = courseLengthBySong(player)
				local course_index = GAMESTATE:GetCourseSongIndex()
				totalSecondsToEndOfSong = cumulative_seconds[course_index+1]
				
				graphPercentage = deathSecond/totalSecondsToEndOfSong
				graphLabel = deathSecond/totalSeconds
			else 
				graphPercentage = deathSecond/totalSeconds
				graphLabel = totalSeconds-deathSecond
			end

			local currentMeasure = math.floor(playerState:GetSongPosition():GetSongBeatVisible()/4)
			
			local streams = SL[pn].Streams
			local storage = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
			
			storage.TotalSeconds = totalSeconds
			storage.DeathSecond = deathSecond
			storage.GraphPercentage = graphPercentage
			storage.GraphLabel = graphLabel

			-- find out if this measure was a stream (16ths or higher)
			if streams.NotesPerMeasure[currentMeasure+1] >= 16 then
				-- find out which measure the fail was 
				for i=1,#streams.Measures do
					if currentMeasure >= streams.Measures[i].streamStart and currentMeasure < streams.Measures[i].streamEnd  then							
						streamrun = currentMeasure-streams.Measures[i].streamStart+1
						streamtotal = streams.Measures[i].streamEnd - streams.Measures[i].streamStart
						storage.DeathMeasures = string.format("%s/%s",streamrun,streamtotal)
					end
				end
			end
		end
	end
}

return af
