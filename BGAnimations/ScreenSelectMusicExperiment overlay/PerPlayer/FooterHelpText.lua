local player = ...

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

gametime = THEME:GetString("ScreenSelectMusicExperiment", "Gametime").." "..gametime
if player ~= GAMESTATE:GetMasterPlayerNumber() then gametime = "" end

return Def.ActorFrame {
	PlayerJoinedMessageCommand=function(self)
		self:playcommand("Set")
	end,
	LoadFont("Common Normal")..{
		Text=PROFILEMAN:GetPlayerName(player),
		InitCommand=function(self) 
			if PROFILEMAN:GetPlayerName(player) == "" then self:settext("Guest") end
			if player == PLAYER_1 then self:xy(_screen.w/15, _screen.h - 16):zoom(1)
			elseif player == PLAYER_2 then self:xy(_screen.w - (_screen.w/10), _screen.h - 16):zoom(1) end
			if not GAMESTATE:IsHumanPlayer(player) then self:visible(false) end
		end,
		SetCommand=function(self)
			if PROFILEMAN:GetPlayerName(player) == "" then self:settext("Guest") 
			else self:settext(PROFILEMAN:GetPlayerName(player)) end
			if GAMESTATE:IsHumanPlayer(player) then self:visible(true) end
		end,
	},

		--Songs Played Label
	LoadFont("Common Normal")..{
		Name="Songs Played",
		Text=THEME:GetString("ScreenSelectMusicExperiment", "SongsPlayed"),
		InitCommand=function(self) 
			if player == PLAYER_1 then self:xy(_screen.w/10+75, _screen.h - 24):zoom(0.6):halign(1)
			elseif player == PLAYER_2 then self:xy(_screen.w - (_screen.w/5), _screen.h - 24):zoom(.6):halign(1) end
			if not GAMESTATE:IsHumanPlayer(player) then self:visible(false) end
		end,
		SetCommand=function(self)
			if GAMESTATE:IsHumanPlayer(player) then self:visible(true) end
		end
	},

	--Songs Played
	LoadFont("Common Normal")..{
		Name="Songs Played",
		Text=songsPlayedThisGame,
		InitCommand=function(self) 
			if player == PLAYER_1 then self:xy(_screen.w/10+80, _screen.h - 24):zoom(0.6):halign(0)
			elseif player == PLAYER_2 then self:xy(_screen.w - (_screen.w/10+80), _screen.h - 24):zoom(0.6):halign(0) end
			if not GAMESTATE:IsHumanPlayer(player) then self:visible(false) end
		end,
		SetCommand=function(self)
			self:settext(songsPlayedThisGame)
			if GAMESTATE:IsHumanPlayer(player) then self:visible(true) end
		end,
	},
	--Calories Label
	LoadFont("Common Normal")..{
		Name="Calories",
		Text=THEME:GetString("ScreenSelectMusicExperiment", "Calories"),
		InitCommand=function(self) 
			if player == PLAYER_1 then self:xy(_screen.w/10+75, _screen.h - 8):zoom(0.6):halign(1)
			elseif player == PLAYER_2 then self:xy(_screen.w - (_screen.w/5), _screen.h - 8):zoom(0.6):halign(1) end
			if not GAMESTATE:IsHumanPlayer(player) then self:visible(false) end
		end,
		SetCommand=function(self)
			if GAMESTATE:IsHumanPlayer(player) then self:visible(true) end
		end,
	},
	--Calories
	LoadFont("Common Normal")..{
		Name="Calories",
		Text=round(profile:GetCaloriesBurnedToday()),
		InitCommand=function(self) 
			if player == PLAYER_1 then self:xy(_screen.w/10+80, _screen.h - 8):zoom(0.6):halign(0)
			elseif player == PLAYER_2 then self:xy(_screen.w - (_screen.w/10+80), _screen.h - 8):zoom(0.6):halign(0) end
			if not GAMESTATE:IsHumanPlayer(player) then self:visible(false) end
		end,
		SetCommand=function(self)
			round(profile:GetCaloriesBurnedToday())
		end
	},

	--Game Time
	LoadFont("Common Normal")..{
		Name="Game Time",
		InitCommand=function(self) self:xy(_screen.cx, _screen.h - 16):zoom(0.7):diffusealpha(1) end,
		Text = gametime,	
	}
}
