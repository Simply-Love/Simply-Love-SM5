local Players = GAMESTATE:GetHumanPlayers();

local t = Def.ActorFrame{
	LoadFont("Wendy/_wendy white")..{
		Text="GAME",
		InitCommand=function(self) self:xy(_screen.cx,_screen.cy-40):croptop(1):fadetop(1):zoom(1.2):shadowlength(1) end,
		OnCommand=function(self) self:decelerate(0.5):croptop(0):fadetop(0):glow(1,1,1,1):decelerate(1):glow(1,1,1,1) end,
		OffCommand=function(self) self:accelerate(0.5):fadeleft(1):cropleft(1) end
	},
	LoadFont("Wendy/_wendy white")..{
		Text="OVER",
		InitCommand=function(self) self:xy(_screen.cx,_screen.cy+40):croptop(1):fadetop(1):zoom(1.2):shadowlength(1) end,
		OnCommand=function(self) self:decelerate(0.5):croptop(0):fadetop(0):glow(1,1,1,1):decelerate(1):glow(1,1,1,1) end,
		OffCommand=function(self) self:accelerate(0.5):fadeleft(1):cropleft(1) end
	},

	--Player 1 Stats BG
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(160,_screen.h):xy(80, _screen.h/2):diffuse(color("#00000099"))
			if ThemePrefs.Get("RainbowMode") then self:diffuse(color("#000000dd")) end
		end,
	},

	--Player 2 Stats BG
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(160,_screen.h):xy(_screen.w-80, _screen.h/2):diffuse(color("#00000099"))
			if ThemePrefs.Get("RainbowMode") then self:diffuse(color("#000000dd")) end
		end,
	}
}

local line_height = 58
local profilestats_y = 145
local horiz_line_y   = 294
local normalstats_y  = 268

for player in ivalues(Players) do

	local stats
	local x_pos = player==PLAYER_1 and 80 or _screen.w-80
	local PlayerStatsAF = Def.ActorFrame{ Name="PlayerStatsAF_"..ToEnumShortString(player) }


	-- first, check if this player is using a profile (local or MemoryCard)
	if PROFILEMAN:IsPersistentProfile(player) then

		-- if a profile is in use, grab gameplay stats for this session that are pertinent
		-- to this specific player's profile (highscore name, calories burned, total songs played)
		stats = LoadActor("PlayerStatsWithProfile.lua", player)

		-- loop through those stats, adding them to the ActorFrame for this player as BitmapText actors
		for i,stat in ipairs(stats) do
			PlayerStatsAF[#PlayerStatsAF+1] = LoadFont("Common Normal")..{
				Text=stat,
				InitCommand=function(self)
					self:diffuse(PlayerColor(player)):zoom(0.95)
						:xy(x_pos, (line_height*(i-1)) + profilestats_y)
						:maxwidth(150):vertspacing(-1)
				end
			}
		end

		local avatar_dim  = 100
		local avatar_path = GetAvatarPathForPlayerProfile(player)

		if avatar_path ~= nil then
			PlayerStatsAF[#PlayerStatsAF+1] = Def.Sprite{
				Texture=avatar_path,
				InitCommand=function(self) self:align(0,0):zoomto(avatar_dim, avatar_dim):xy(x_pos-avatar_dim*0.5, 12) end
			}
		else
			-- fallback avatar
			PlayerStatsAF[#PlayerStatsAF+1] = Def.ActorFrame{
				InitCommand=function(self) self:xy(x_pos-avatar_dim*0.5, 12) end,

				Def.Quad{
					InitCommand=function(self)
						self:align(0,0):zoomto(avatar_dim,avatar_dim):diffuse(color("#283239aa"))
					end
				},
				-- fallback visual (SL visual theme)
				LoadActor(THEME:GetPathG("", "_VisualStyles/".. ThemePrefs.Get("VisualTheme") .."/SelectColor"))..{
					InitCommand=function(self)
						self:align(0,0):zoom(0.11):diffusealpha(0.9):xy(13, 8)
					end
				},
				-- fallback text ("no avatar")
				LoadFont("Common Normal")..{
					Text=THEME:GetString("ProfileAvatar","NoAvatar"),
					InitCommand=function(self)
						self:valign(0):zoom(0.875):diffusealpha(0.9):xy(self:GetWidth()*0.5 + 18, 78)
					end,
					SetCommand=function(self, params)
						if params == nil then
							self:settext(THEME:GetString("ScreenSelectProfile", "GuestProfile"))
						else
							self:settext(THEME:GetString("ScreenSelectProfile", "NoAvatar"))
						end
					end
				}
			}
		end
	end

	-- horizontal line separating upper stats (profile) from the lower stats (general)
	PlayerStatsAF[#PlayerStatsAF+1] = Def.Quad{
		InitCommand=function(self)
			self:zoomto(120,1):xy(x_pos, horiz_line_y)
				:diffuse( PlayerColor(player) )
		end
	}

	-- retrieve general gameplay session stats for which a profile is not needed
	stats = LoadActor("PlayerStatsWithoutProfile.lua", player)

	-- loop through those stats, adding them to the ActorFrame for this player as BitmapText actors
	for i,stat in ipairs(stats) do
		PlayerStatsAF[#PlayerStatsAF+1] = LoadFont("Common Normal")..{
			Text=stat,
			InitCommand=function(self)
				self:diffuse(PlayerColor(player)):zoom(0.95)
					:xy(x_pos, (line_height*i) + normalstats_y)
					:maxwidth(150):vertspacing(-1)
			end
		}
	end

	t[#t+1] = PlayerStatsAF
end

return t