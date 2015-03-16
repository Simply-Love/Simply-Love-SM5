local text = ""
local SongNumberInCourse = 0

if GAMESTATE:IsCourseMode() then

	text = THEME:GetString("Stage", "Stage") .. " 1"

elseif not PREFSMAN:GetPreference("EventMode") then

	-- local song = GAMESTATE:GetCurrentSong()
	-- local Duration = song:GetLastSecond()
	-- local DurationWithRate = Duration / SL.Global.ActiveModifiers.MusicRate
	--
	-- local LongCutoff = PREFSMAN:GetPreference("LongVerSongSeconds")
	-- local MarathonCutoff = PREFSMAN:GetPreference("MarathonVerSongSeconds")
	--
	-- local IsLong = DurationWithRate/LongCutoff > 1 and true or false
	-- local IsMarathon = DurationWithRate/MarathonCutoff > 1 and true or false
	--
	-- local SongCost = IsLong and 2 or IsMarathon and 3 or 1
	-- local SongsPerPlay = PREFSMAN:GetPreference("SongsPerPlay")

	text = THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)

	-- if SL.Global.Stages.PlayedThisGame + SongCost >= SongsPerPlay then
	-- 	text = THEME:GetString("Stage", "Final")
	-- end

else
	text = THEME:GetString("Stage", "Event")
end

-- get the PlayerOptions string for any human players and store it now
-- we'll retreive it the next time ScreenSelectMusic loads and re-apply those same mods
-- in this way, we can override the effects of songs that forced modifiers during gameplay
local Players = GAMESTATE:GetHumanPlayers()
for player in ivalues(Players) do
	-- The player SHOULD have a default noteskin set in Preferences.ini via DefaultModifiers=
	-- under the section for the currently active game type, but apparently this is not ensured
	-- and can cause crashes in SM5 beta4a.  This is a hackish workaround.
	-- THANKFULLY, if the noteskin is "already set" in Preferences.ini (as it should be),
	-- setting it again here seems to have no adverse affects!
	local ns = GAMESTATE:GetPlayerState(player):GetCurrentPlayerOptions():NoteSkin()
	local pn = ToEnumShortString(player)
	SL[pn].CurrentPlayerOptions.String = GAMESTATE:GetPlayerState(player):GetPlayerOptionsString("ModsLevel_Preferred")..","..ns
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