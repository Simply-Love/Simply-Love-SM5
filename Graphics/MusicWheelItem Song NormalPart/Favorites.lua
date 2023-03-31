-- This is used for tracking ITL points on the songwheel
-- TODO: 
-- Maybe load all points at screen load instead of every time the MusicWheelItem loads?
-- Screen needs to reload when new players join or else the layout is messed up
-- Doesn't display anything until you scroll the musicwheel at once

-- Notes
-- Works for 16:9, 16:10, 4:3 on 1,2 player and versus mode
-- I'm unsure whether it is readable on a 4:3 CRT
-- Design in 2 player mode could probably be improved

local player = ...
local pn = ToEnumShortString(player)

local ar = GetScreenAspectRatio()

local profile_slot = {
	[PLAYER_1] = "ProfileSlot_Player1",
	[PLAYER_2] = "ProfileSlot_Player2"
}

local isFavorite = function(songPath)
	local playerName = PROFILEMAN:GetPlayerName(pn)
	
	local profileDir  = PROFILEMAN:GetProfileDir(profile_slot[player])
	local path = profileDir .. "favorites.txt"
	
	local oldDir = THEME:GetCurrentThemeDirectory() .. "Other/"
	local oldPath = oldDir.. "SongManager " .. playerName .. "-favorites.txt"
	
	local f = RageFileUtil:CreateRageFile()
	
	local isFave = false
	if f:Open(path, 1) then
		faves = f:Read()
		f:Close()

		for line in faves:gmatch('[^\r\n]+') do
			if string.len(line) > 0 then
				if line:find(songPath,1,true) ~= nil then
					isFave = true
					break
				end
			end
		end
	elseif f:Open(oldPath, 1) then
		faves = f:Read()
		f:Close()

		for line in faves:gmatch('[^\r\n]+') do
			if string.len(line) > 0 then
				if line:find(songPath,1,true) ~= nil then
					isFave = true
					break
				end
			end
		end
	end

	f:Close()
	f:destroy()

	return isFave
end

local af = Def.ActorFrame {
	InitCommand=function(self)
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if not PROFILEMAN:IsPersistentProfile(params.Player) then
			GAMESTATE:ResetPlayerOptions(params.Player)
			SL[ToEnumShortString(params.Player)]:initialize()
		end
		if pn == nil then
			player = params.Player
			pn = ToEnumShortString(player)
		end
	end,
	SetCommand=function(self,params)
		if params.Type == "Song" then
			local song = params.Song
			local favorite = isFavorite(song:GetSongDir():gsub("/Songs/", ""))
			if favorite then
				self:playcommand("Favorite",{favorite=favorite})
			else
				local song = ""
				if params.Song then song = params.Song:GetDisplayFullTitle() end
				--SM("Unsetting top " .. pn .. " " .. params.Type .. " " .. params.Text .. " " .. song)
				self:playcommand("Unset") 
			end
		else
			local song = ""
			if params.Song then song = params.Song:GetDisplayFullTitle() end
			--SM("Unsetting bottom " .. pn .. " " .. params.Type .. " " .. params.Text .. " " .. song)
			self:playcommand("Unset") 
		end
	end
}

af[#af+1] = Def.Sprite{
	InitCommand=function(self)
		self:animate(false):visible(false)
		self:Load( THEME:GetPathG("", "fave-icon.png") )
	end,
	FavoriteCommand=function(self,params)
		self:diffuseshift():effectperiod(0.8)
		if pn == "P1" then
			self:effectcolor1(Color.Blue)
			self:effectcolor2(lerp_color(
				0.70, color("#ffffff"), Color.Blue))
		else
			self:effectcolor1(color("#ff7777"))
			self:effectcolor2(lerp_color(
				0.70, color("#ffffff"), color("#ff7777")))
		end
		self:visible(params.favorite)
		self:x(-20)
		if #GAMESTATE:GetHumanPlayers() > 1 then
			self:zoomto(15,15)
			self:y(pn == "P1" and -8 or 8)
		else
			self:zoomto(20,20):y(0)
		end
	end,
	UnsetCommand=function(self)
		self:visible(false)
	end
}

return af
