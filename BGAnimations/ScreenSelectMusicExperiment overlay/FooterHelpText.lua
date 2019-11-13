local player = 'PlayerNumber_P1' --TODO this only works for first player!

local cancel = THEME:GetString("ScreenSelectMusicCasual", "FooterTextSingleSong")
if PREFSMAN:GetPreference("ThreeKeyNavigation") then cancel = THEME:GetString("ScreenSelectMusicCasual", "FooterTextSingleSong3Key") end

local profile = PROFILEMAN:GetProfile(player) 
local zoom_factor = WideScale(0.8,0.9)

local stageStats = STATSMAN:GetCurStageStats()

local totalTime = 0
local songsPlayedThisGame = 0

-- Use pairs here (instead of ipairs) because this player might have late-joined
-- which will result in nil entries in the the Stats table, which halts ipairs.
-- We're just summing total time anyway, so order doesn't matter.
for _,stats in pairs( SL[ToEnumShortString(player)].Stages.Stats ) do
	totalTime = totalTime + (stats and stats.duration or 0)
	songsPlayedThisGame = songsPlayedThisGame + (stats and 1 or 0)
end

local hours = math.floor(totalTime/3600)
local minutes = math.floor((totalTime-(hours*3600))/60)
local seconds = round(totalTime%60)
local gametime =  minutes .. THEME:GetString("ScreenGameOver", "Minutes") .. " " .. seconds .. THEME:GetString("ScreenGameOver", "Seconds")

if hours > 0 then
	gametime = hours .. ScreenString("Hours") .. " " ..
	minutes .. ScreenString("Minutes") .. " " ..
	seconds .. ScreenString("Seconds")
end

return Def.ActorFrame {
	LoadFont("Common Normal")..{
		InitCommand=function(self) 
			self:xy(_screen.w - (_screen.w/10), _screen.h - 16):zoom(1):diffusealpha(1)
			self:settext(PROFILEMAN:GetPlayerName(1))
		end,
	},
	LoadFont("Common Normal")..{
		InitCommand=function(self) 
			self:xy(_screen.w/15, _screen.h - 16):zoom(1):diffusealpha(1)
			self:settext(PROFILEMAN:GetPlayerName(0))
		end,
	},

		--Songs Played Label
	LoadFont("Common Normal")..{
		Name="Songs Played",
		Text=THEME:GetString("ScreenSelectMusicExperiment", "SongsPlayed"),
		InitCommand=function(self) 
			self:xy(_screen.w/10+75, _screen.h - 24):zoom(0.6):diffusealpha(1):halign(1)
		end,
	},

	--Songs Played
	LoadFont("Common Normal")..{
		Name="Songs Played",
		Text=songsPlayedThisGame,
		InitCommand=function(self) 
			self:xy(_screen.w/10+80, _screen.h - 24):zoom(0.6):diffusealpha(1):halign(0)
		end,
	},
	--Calories Label
	LoadFont("Common Normal")..{
		Name="Calories",
		Text=THEME:GetString("ScreenSelectMusicExperiment", "Calories"),
		InitCommand=function(self) 
			self:xy(_screen.w/10+75, _screen.h - 8):zoom(0.6):diffusealpha(1):halign(1)
		end,
	},
	--Calories
	LoadFont("Common Normal")..{
		Name="Calories",
		Text=round(profile:GetCaloriesBurnedToday()),
		InitCommand=function(self) 
			self:xy(_screen.w/10+80, _screen.h - 8):zoom(0.6):diffusealpha(1):halign(0)
		end,
	},

	--Game Time
	LoadFont("Common Normal")..{
		InitCommand=function(self) self:xy(_screen.cx, _screen.h - 16):zoom(0.7):diffusealpha(1) end,
		Name="Game Time",
		Text=THEME:GetString("ScreenSelectMusicExperiment", "Gametime").." "..gametime,
		
	},



}
