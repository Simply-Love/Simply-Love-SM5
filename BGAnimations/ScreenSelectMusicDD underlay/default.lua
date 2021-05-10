---- Have to put this here because of layering issues that would otherwise occur lmao

local P1 = GAMESTATE:IsHumanPlayer(PLAYER_1)
local P2 = GAMESTATE:IsHumanPlayer(PLAYER_2)

local function getInputHandler(actor, player)
	return (function(event)
		if event.GameButton == "Start" and event.PlayerNumber == player and GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
			actor:visible(true)
		end
	end)
end

local af = Def.ActorFrame{
	Name="DifficultyBGs",
	InitCommand=function(self) self:horizalign(left):vertalign(top):xy(SCREEN_LEFT, 20 ) end,
	
	--- The background quad for the grid to make the whole thing more legible.
	Def.Quad{
		Name="DiffBackground",
		InitCommand=function(self)
				self:x(IsUsingWideScreen() and WideScale(SCREEN_LEFT + 77.5,SCREEN_LEFT + 133.5) or SCREEN_LEFT + 160)
				self:y(IsUsingWideScreen() and _screen.cy + 43.5 or _screen.cy - 68)
				self:draworder(0)
				self:diffuse(color("#1e282f"))
				if IsUsingWideScreen() then
					self:zoomx(WideScale(160,267))
					self:zoomy(56)
					self:visible(P1)
				else
					self:zoomto(270,40)
					self:visible(true)
				end
				
		end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P1'))
		end
	},
	
	Def.Quad{
		Name="DiffBackground2",
		InitCommand=function(self)
			if IsUsingWideScreen() then
				self:visible(P2)
				self:xy(WideScale(_screen.cx+_screen.w/2.7,_screen.cx+_screen.w/2.92), _screen.cy + 44)
				self:draworder(0)
				self:diffuse(color("#1e282f"))
				self:zoomx(WideScale(160,268))
				self:zoomy(56)
			else
				self:visible(false)
			end
		end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P2'))
		end
	},
	
	
}

return af