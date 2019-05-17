-- code for setting the PlayerOptions string (needed to counteract ITG mod charts)
-- and the MeasureCounter has been abstracted out to a different file to keep this one simpler.
local InitializeMeasureCounterAndModsLevel = LoadActor("./MeasureCounterAndModsLevel.lua")

local text = ""
local SongNumberInCourse = 0
local style = ThemePrefs.Get("VisualTheme")

if GAMESTATE:IsCourseMode() then
	text = THEME:GetString("Stage", "Stage") .. " 1"

elseif not PREFSMAN:GetPreference("EventMode") then
	text = THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)

else
	text = THEME:GetString("Stage", "Event")
end

InitializeMeasureCounterAndModsLevel(SongNumberInCourse)

local t = Def.ActorFrame{

	Def.ActorFrame{
		-- no need to keep drawing these during gameplay; set visible(false) once they're done and save a few clock cycles
		OnCommand=function(self) self:sleep(2):queuecommand("Hide") end,
		HideCommand=function(self) self:visible(false) end,

		Def.Quad{
			InitCommand=cmd(diffuse,Color.Black; Center; FullScreen),
			OnCommand=cmd(sleep,1.4; accelerate,0.6; diffusealpha,0)
		},
		LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/GameplayIn splode"))..{
			InitCommand=cmd(diffusealpha,0),
			OnCommand=cmd(sleep,0.4; diffuse, GetCurrentColor(); Center; rotationz,10; diffusealpha,0; zoom,0; diffusealpha,0.9; linear,0.6; rotationz,0; zoom,1.1; diffusealpha,0)
		},
		LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/GameplayIn splode"))..{
			InitCommand=cmd(diffusealpha,0),
			OnCommand=cmd(sleep,0.4; diffuse, GetCurrentColor(); Center; rotationy,180; rotationz,-10; diffusealpha,0; zoom,0.2; diffusealpha,0.8; decelerate,0.6; rotationz,0; zoom,1.3; diffusealpha,0)
		},
		LoadActor(THEME:GetPathG("", "_VisualStyles/"..style.."/GameplayIn minisplode"))..{
			InitCommand=cmd(diffusealpha,0),
			OnCommand=cmd(sleep,0.4; diffuse, GetCurrentColor(); Center; rotationz,10; diffusealpha,0; zoom,0; diffusealpha,1; decelerate,0.8; rotationz,0; zoom,0.9; diffusealpha,0)
		},
	},

	LoadFont("_wendy small")..{
		Text=text,
		InitCommand=cmd(Center; diffusealpha,0; shadowlength,1),
		OnCommand=cmd(accelerate, 0.5; diffusealpha, 1; sleep, 0.66; accelerate, 0.33; zoom, 0.4; y, _screen.h-30),
		CurrentSongChangedMessageCommand=function(self)
			if GAMESTATE:IsCourseMode() then
				InitializeMeasureCounterAndModsLevel(SongNumberInCourse)
				SongNumberInCourse = SongNumberInCourse + 1
				self:settext( THEME:GetString("Stage", "Stage") .. " " .. SongNumberInCourse )
			end
		end
	}
}

return t