local Players = GAMESTATE:GetHumanPlayers();

local t = Def.ActorFrame{
	LoadFont("_wendy white")..{
		Text="GAME",
		InitCommand=cmd(xy,_screen.cx,_screen.cy-40;croptop,1;fadetop,1; zoom,1.2),
		OnCommand=cmd(decelerate,0.5; croptop,0; fadetop,0; glow,color("1,1,1,1"); decelerate,1; glow,color("1,1,1,0") ),
		OffCommand=cmd(accelerate,0.5; fadeleft,1; cropleft,1)
	},
	LoadFont("_wendy white")..{
		Text="OVER",
		InitCommand=cmd(xy,_screen.cx,_screen.cy+40; croptop,1; fadetop,1; zoom,1.2),
		OnCommand=cmd(decelerate,0.5; croptop,0; fadetop,0; glow,color("1,1,1,1"); decelerate,1;glow,color("1,1,1,0") ),
		OffCommand=cmd(accelerate,0.5;fadeleft,1;cropleft,1)
	},
	
	
	--Player 1 Stats BG
	Def.Quad{
		InitCommand=cmd(diffuse, color("#00000099"); zoomto,160,_screen.h; xy, 80, _screen.h/2 ),
		OnCommand=cmd()
	},
	
	--Player 2 Stats BG
	Def.Quad{
		InitCommand=cmd(xy,_screen.w-80, _screen.h/2; diffuse, color("#00000099"); zoomto,160,_screen.h ),
		OnCommand=cmd()
	}
}


for pn in ivalues(Players) do
	if PROFILEMAN:IsPersistentProfile(pn) then
		t[#t+1] = LoadActor("PlayerStats", pn)
	else
		t[#t+1] = LoadFont("_miso")..{
			Text="No Card",
			InitCommand=cmd(diffuse, PlayerColor(pn); y, 40),
			OnCommand=function(self)
				if pn == PLAYER_1 then
					self:x(80)
				elseif pn == PLAYER_2 then
					self:x(_screen.w-80)
				end
			end
		}
	end
end

return t