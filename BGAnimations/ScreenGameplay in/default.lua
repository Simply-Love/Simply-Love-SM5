local text = ""

if GAMESTATE:IsCourseMode() then

	text = THEME:GetString("Stage", "Course")

elseif not PREFSMAN:GetPreference("EventMode") then

	local song = GAMESTATE:GetCurrentSong()
	local Duration = song:GetLastSecond()
	local DurationWithRate = Duration / SL.Global.ActiveModifiers.MusicRate

	local LongCutoff = PREFSMAN:GetPreference("LongVerSongSeconds")
	local MarathonCutoff = PREFSMAN:GetPreference("MarathonVerSongSeconds")

	local IsLong = DurationWithRate/LongCutoff > 1 and true or false
	local IsMarathon = DurationWithRate/MarathonCutoff > 1 and true or false

	local SongCost = IsLong and 2 or IsMarathon and 3 or 1
	local SongsPerPlay = PREFSMAN:GetPreference("SongsPerPlay")

	text = THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)

	-- if SL.Global.Stages.PlayedThisGame + SongCost >= SongsPerPlay then
	-- 	text = THEME:GetString("Stage", "Final")
	-- end

else
	text = THEME:GetString("Stage", "Event")
end



local t = Def.ActorFrame {}

t[#t+1] = Def.ActorFrame{

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
		InitCommand=cmd(Center; diffusealpha,0; shadowlength,1),
		OnCommand=cmd(settext, text; accelerate, 0.5; diffusealpha, 1; sleep, 0.66; accelerate, 0.33; zoom, 0.4; y, _screen.h-30)
	}
}

return t