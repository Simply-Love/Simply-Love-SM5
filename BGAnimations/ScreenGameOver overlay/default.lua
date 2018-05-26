local Players = GAMESTATE:GetHumanPlayers();

local t = Def.ActorFrame{
	LoadFont("_wendy white")..{
		Text="GAME",
		InitCommand=cmd(xy,_screen.cx,_screen.cy-40;croptop,1;fadetop,1; zoom,1.2; shadowlength,1),
		OnCommand=cmd(decelerate,0.5; croptop,0; fadetop,0; glow,color("1,1,1,1"); decelerate,1; glow,color("1,1,1,0") ),
		OffCommand=cmd(accelerate,0.5; fadeleft,1; cropleft,1)
	},
	LoadFont("_wendy white")..{
		Text="OVER",
		InitCommand=cmd(xy,_screen.cx,_screen.cy+40; croptop,1; fadetop,1; zoom,1.2; shadowlength,1),
		OnCommand=cmd(decelerate,0.5; croptop,0; fadetop,0; glow,color("1,1,1,1"); decelerate,1;glow,color("1,1,1,0") ),
		OffCommand=cmd(accelerate,0.5;fadeleft,1;cropleft,1)
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

for player in ivalues(Players) do
	
	local line_height = 60
	local middle_line_y = 220
	local x_pos = player == PLAYER_1 and 80 or _screen.w-80
	local PlayerStatsAF = Def.ActorFrame{ Name="PlayerStatsAF_"..ToEnumShortString(player) }
	local stats
	
	-- first, check if this player is using a profile (local or MemoryCard)
	if PROFILEMAN:IsPersistentProfile(player) then
		
		-- if a profile is in use, grab gameplay stats for this session that are pertinent
		-- to this specific player's profile (highscore name, calories burned, total songs played)
		stats = LoadActor("PlayerStatsWithProfile.lua", player)
		
		-- loop through those stats, adding them to the ActorFrame for this player as BitmapText actors
		for i,stat in ipairs(stats) do
			PlayerStatsAF[#PlayerStatsAF+1] = Def.BitmapText{
				Font="_miso",
				Text=stat,
				InitCommand=function(self)
					self:diffuse(PlayerColor(player))
						:xy(x_pos, (line_height*(i-1)) + 40)
				end
			}
		end
		
	end
	
	-- draw a thin line (really just a Def.Quad) separating 
	-- the upper (profile) stats from the lower (general) stats
	PlayerStatsAF[#PlayerStatsAF+1] = Def.Quad{
		InitCommand=function(self) 
			self:zoomto(120,1):xy(x_pos, middle_line_y)
				:diffuse( PlayerColor(player) )
		end
	}
	
	-- retrieve general gameplay session stats for which a profile is not needed
	stats = LoadActor("PlayerStatsWithoutProfile.lua", player)	
	
	-- loop through those stats, adding them to the ActorFrame for this player as BitmapText actors
	for i,stat in ipairs(stats) do
		PlayerStatsAF[#PlayerStatsAF+1] = Def.BitmapText{
			Font="_miso",
			Text=stat,
			InitCommand=function(self)
				self:diffuse(PlayerColor(player))
					:xy(x_pos, (line_height*i) + middle_line_y)
			end
		}
	end
	
	t[#t+1] = PlayerStatsAF
end

return t