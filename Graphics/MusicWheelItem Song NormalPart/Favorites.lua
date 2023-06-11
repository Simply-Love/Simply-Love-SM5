local player = ...
local pn = ToEnumShortString(player)

local profileSlot = {
	[PLAYER_1] = "ProfileSlot_Player1",
	[PLAYER_2] = "ProfileSlot_Player2"
}

local allFavorites = {}

local LoadFavorites = function()
  local playerName = PROFILEMAN:GetPlayerName(pn)
  local profileDir  = PROFILEMAN:GetProfileDir(profileSlot[player])
	local path = profileDir .. "favorites.txt"

	local f = RageFileUtil:CreateRageFile()

	if f:Open(path, 1) then
		favoritesStr = f:Read()
		f:Close()
	  f:destroy()

		for line in favoritesStr:gmatch("[^\r\n]+") do
			if string.len(line) > 0 then
        allFavorites[line] = true
			end
		end
	end
end

LoadFavorites()

local af = Def.ActorFrame {
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
  FavoritesChangedMessageCommand=function(self, params)
    if params.Player == player then
      if params.Remove then
        if allFavorites[params.SongPath] then
          allFavorites[params.SongPath] = nil
        end
      else
        allFavorites[params.SongPath] = true
      end
      
      self:playcommand("Set", {Song = GAMESTATE:GetCurrentSong(), Type = "Song"})
    end
  end,
	SetCommand=function(self, params)
		if params.Type == "Song" then
			local song = params.Song
      local song_path = song:GetSongDir():gsub("/Songs/", ""):sub(1, -2)
      local isFavorite = allFavorites[song_path] == true
      self:playcommand("Favorite", {isFavorite = isFavorite})
		end
	end
}

af[#af+1] = Def.Sprite{
	InitCommand=function(self)
		self:animate(false):visible(false):x(-20)
		self:Load( THEME:GetPathG("", "fave-icon.png") )
	end,
	FavoriteCommand=function(self, params)
    self:visible(params.isFavorite)

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

		if #GAMESTATE:GetHumanPlayers() > 1 then
			self:zoomto(15,15)
			self:y(pn == "P1" and -8 or 8)
		else
			self:zoomto(20,20):y(0)
		end
	end,
}

return af