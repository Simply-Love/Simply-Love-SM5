local text = ""
local SongNumberInCourse = 0

if GAMESTATE:IsCourseMode() then

	text = THEME:GetString("Stage", "Stage") .. " 1"

elseif not PREFSMAN:GetPreference("EventMode") then

	text = THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)
else

	text = THEME:GetString("Stage", "Event")
end


-- get the PlayerOptions string for any human players and store it now
-- we'll retreive it the next time ScreenSelectMusic loads and re-apply those same mods
-- in this way, we can override the effects of songs that forced modifiers during gameplay
-- the old-school (ie. ITG) way of GAMESTATE:ApplyGameCommand()
local Players = GAMESTATE:GetHumanPlayers()
for player in ivalues(Players) do
	local pn = ToEnumShortString(player)
	SL[pn].CurrentPlayerOptions.String = GAMESTATE:GetPlayerState(player):GetPlayerOptionsString("ModsLevel_Preferred")


	-- Check if MeasureCounter is turned on;
	-- we may (or may not) need to parse the chart.
	local mods = SL[pn].ActiveModifiers
	if mods.MeasureCounter and mods.MeasureCounter ~= "None" then

		local song_dir = GAMESTATE:GetCurrentSong():GetSongDir()
		local steps = GAMESTATE:GetCurrentSteps(player)
		local steps_type = ToEnumShortString( steps:GetStepsType() ):gsub("_", "-"):lower()
		local difficulty = ToEnumShortString( steps:GetDifficulty() )
		local notes_per_measure = tonumber(mods.MeasureCounter:match("%d+"))
		local threshold_to_be_stream = 2

		-- if any of these don't match what we're currently looking for...
		if SL[pn].Streams.SongDir ~= song_dir or SL[pn].Streams.StepsType ~= step_type or SL[pn].Streams.Difficulty ~= difficulty then

			-- ...then parse the simfile, given the current parameters
			SL[pn].Streams.Measures = GetStreams(song_dir, steps_type, difficulty, notes_per_measure, threshold_to_be_stream)
			-- and set these so we can check again next time.
			SL[pn].Streams.SongDir = song_dir
			SL[pn].Streams.StepsType = steps_type
			SL[pn].Streams.Difficulty = difficulty
		end
	end
end


local t = Def.ActorFrame{

	Def.Quad{
		InitCommand=cmd(diffuse,Color.Black; Center; FullScreen),
		OnCommand=cmd(sleep,1.4; accelerate,0.6; diffusealpha,0)
	},


	LoadActor("heartsplode")..{
		InitCommand=cmd(diffusealpha,0),
		OnCommand=cmd(sleep,0.4; diffuse, GetCurrentColor(); Center; rotationz,10; diffusealpha,0; zoom,0; diffusealpha,0.9; linear,0.6; rotationz,0; zoom,1.1; diffusealpha,0)
	},
	LoadActor("heartsplode")..{
		InitCommand=cmd(diffusealpha,0),
		OnCommand=cmd(sleep,0.4; diffuse, GetCurrentColor(); Center; rotationy,180; rotationz,-10; diffusealpha,0; zoom,0.2; diffusealpha,0.8; decelerate,0.6; rotationz,0; zoom,1.3; diffusealpha,0)
	},
	LoadActor("minisplode")..{
		InitCommand=cmd(diffusealpha,0),
		OnCommand=cmd(sleep,0.4; diffuse, GetCurrentColor(); Center; rotationz,10; diffusealpha,0; zoom,0; diffusealpha,1; decelerate,0.8; rotationz,0; zoom,0.9; diffusealpha,0)
	},

	LoadFont("_wendy small")..{
		Text=text,
		InitCommand=cmd(Center; diffusealpha,0; shadowlength,1),
		OnCommand=cmd(accelerate, 0.5; diffusealpha, 1; sleep, 0.66; accelerate, 0.33; zoom, 0.4; y, _screen.h-30),
		CurrentSongChangedMessageCommand=function(self)
			if GAMESTATE:IsCourseMode() then
				SongNumberInCourse = SongNumberInCourse + 1
				self:settext( THEME:GetString("Stage", "Stage") .. " " .. SongNumberInCourse )
			end
		end
	}
}

return t