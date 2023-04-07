-- code for setting the PlayerOptions string (needed to counteract ITG mod charts)
-- and the MeasureCounter has been abstracted out to a different file to keep this one simpler.
local InitializeMeasureCounterAndModsLevel = LoadActor("./MeasureCounterAndModsLevel.lua")

local text = ""
local SongNumberInCourse = 0
local SongsInCourse
local style = ThemePrefs.Get("VisualStyle")
local assets = {
	splode     = THEME:GetPathG("", "_VisualStyles/"..style.."/GameplayIn splode"),
	minisplode = THEME:GetPathG("", "_VisualStyles/"..style.."/GameplayIn minisplode")
}

if IsSpooky() then
	assets.splode     = THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/Bats")
	assets.minisplode = THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/Bats")
end

if not SL.Global.GameplayReloadCheck then
	SL.Global.Stages.Restarts = 0
end

if GAMESTATE:IsCourseMode() then
	SongsInCourse = #GAMESTATE:GetCurrentCourse():GetCourseEntries()
	text = ("%s 1 / %d"):format(THEME:GetString("Stage", "Stage"), SongsInCourse)
elseif SL.Global.GameplayReloadCheck then
	SL.Global.Stages.Restarts = SL.Global.Stages.Restarts + 1
	text = "RESTART " .. tostring(SL.Global.Stages.Restarts)
elseif string.find(string.upper(GAMESTATE:GetCurrentSong():GetGroupName()), "STAMINA RPG 6") then
	text = "Stamina RPG 6"
	
elseif string.find(string.upper(GAMESTATE:GetCurrentSong():GetGroupName()), "ITL ONLINE 2023") then
	text = "ITL Online 2023"

elseif not PREFSMAN:GetPreference("EventMode") then
	text = THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)
else
	text = THEME:GetString("Stage", "Event")
end

InitializeMeasureCounterAndModsLevel(SongNumberInCourse)

-------------------------------------------------------------------------

local af = Def.ActorFrame{}

af[#af+1] = Def.ActorFrame{
	-- no need to keep drawing these during gameplay; set visible(false) once they're done and save a few clock cycles
	OnCommand=function(self)
		if SL.Global.GameplayReloadCheck then
			-- don't bother animating these visuals if ScreenGameplay was just reloaded by a mod chart
			-- just jump directly to hiding this lead in
			self:playcommand("Hide")
		else
			self:sleep(2):queuecommand("Hide")
		end
	end,
	HideCommand=function(self)
		self:visible(false)
		SL.Global.GameplayReloadCheck = true
	end,
	OffCommand=function(self)
		SL.Global.GameplayReloadCheck = false
	end,

	Def.Quad{
		InitCommand=function(self) self:diffuse(Color.Black):Center():FullScreen() end,
		OnCommand=function(self) self:sleep(1.4):accelerate(0.6):diffusealpha(0) end
	},

	LoadActor(assets.splode)..{
		InitCommand=function(self) self:diffuse(GetCurrentColor(true)):Center():rotationz(10):zoom(0):diffusealpha(0.9) end,
		OnCommand=function(self) self:sleep(0.4):linear(0.6):rotationz(0):zoom(1.1):diffusealpha(0) end
	},
	LoadActor(assets.splode)..{
		InitCommand=function(self) self:diffuse(GetCurrentColor(true)):Center():rotationy(180):rotationz(-10):zoom(0):diffusealpha(0.8) end,
		OnCommand=function(self) self:sleep(0.4):decelerate(0.6):rotationz(0):zoom(1.3):diffusealpha(0) end
	},
	LoadActor(assets.minisplode)..{
		InitCommand=function(self) self:diffuse(GetCurrentColor(true)):Center():rotationz(10):zoom(0) end,
		OnCommand=function(self) self:sleep(0.4):decelerate(0.8):rotationz(0):zoom(0.9):diffusealpha(0) end
	}
}

af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
	Text=text,
	InitCommand=function(self) self:Center():diffusealpha(0):shadowlength(1) end,
	OnCommand=function(self)
		-- don't animate the text tweening to the bottom of the screen if ScreenGameplay was just reloaded by a mod chart
		-- if not SL.Global.GameplayReloadCheck then
			self:accelerate(0.5):diffusealpha(1):sleep(0.66):accelerate(0.33)
		-- end
		self:zoom(0.4):y(_screen.h-30):diffusealpha(1):sleep(2)

		-- offset "stage i" text to the left or right if only one player is joined, and that player's notefield is centered
		if #GAMESTATE:GetHumanPlayers() == 1 and GetNotefieldX( GAMESTATE:GetMasterPlayerNumber() ) == _screen.cx then
			local player = GAMESTATE:GetHumanPlayers()[1]
			self:x(_screen.cx + (GetNotefieldWidth()*0.5 + self:GetWidth()*0.25) * (player==PLAYER_1 and -1 or 1))
		end
	end,
	CurrentSongChangedMessageCommand=function(self)
		if GAMESTATE:IsCourseMode() then
			InitializeMeasureCounterAndModsLevel(SongNumberInCourse)
			SongNumberInCourse = SongNumberInCourse + 1
			self:settext(("%s %d / %d"):format(THEME:GetString("Stage", "Stage"), SongNumberInCourse, SongsInCourse))
		end
	end
}


-- Play random sound in Sounds/Song Start/
local soundDir = THEME:GetCurrentThemeDirectory() .. "Sounds/Song Start/"
audio_files = findFiles(soundDir)
local restart_file = soundDir .. "Restart/" .. SL.Global.Stages.Restarts .. ".ogg"
local restart_nocount_file = soundDir .. "Restart/restart.ogg"
if SL.Global.GameplayReloadCheck then
	if FILEMAN:DoesFileExist(restart_file) then SOUND:PlayOnce(restart_file)
	elseif FILEMAN:DoesFileExist(restart_nocount_file) then SOUND:PlayOnce(restart_nocount_file) end
elseif #audio_files > 0 then
	SOUND:PlayOnce(audio_files[math.random(#audio_files)])
end

return af
