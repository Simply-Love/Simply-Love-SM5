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
		InitCommand=cmd(diffuse, color("#00000099"); zoomto,160,_screen.h; xy, 80, _screen.h/2 ),
	},

	--Player 2 Stats BG
	Def.Quad{
		InitCommand=cmd(xy,_screen.w-80, _screen.h/2; diffuse, color("#00000099"); zoomto,160,_screen.h ),
	}
}

for player in ivalues(Players) do
	
	local x_pos = player == PLAYER_1 and 80 or _screen.w-80
	local PlayerStatsAF = Def.ActorFrame{}
	local stats
	
	if PROFILEMAN:IsPersistentProfile(player) then
		stats = LoadActor("PlayerStatsWithProfile.lua", player)
	else
		stats = LoadActor("PlayerStatsWithoutProfile.lua", player)	
	end
	
	for i,line in ipairs(stats) do
	
		if line=="---" then
			PlayerStatsAF[#PlayerStatsAF+1] = Def.Quad{
				InitCommand=function(self) 
					self:zoomto(120,1):xy(x_pos, (60*(i-1)) + 40)
						:diffuse( PlayerColor(player) )
				end
			}
		else
	
			PlayerStatsAF[#PlayerStatsAF+1] = Def.BitmapText{
				Font="_miso",
				Text=line,
				InitCommand=function(self)
					self:diffuse(PlayerColor(player))
						:xy(x_pos, (60*(i-1)) + 40)
				end
			}
		end
	end
	
	t[#t+1] = PlayerStatsAF
end

return t