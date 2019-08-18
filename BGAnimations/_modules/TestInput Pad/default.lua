local player = ...

local af = Def.ActorFrame{}
local game = GAMESTATE:GetCurrentGame():GetName()

local Highlights = {
	Start={		x=0, 	y=66, 	rotationz=0, 	zoom=0.5, graphic="highlightgreen.png" },
	Select={	x=0, 	y=95,	rotationz=180, 	zoom=0.5, graphic="highlightred.png" },
	MenuRight={	x=37, 	y=80, 	rotationz=0, 	zoom=0.5, graphic="highlightarrow.png" },
	MenuLeft={	x=-37, 	y=80, 	rotationz=180,	zoom=0.5, graphic="highlightarrow.png" },

	UpLeft={	x=-67,	y=-148, rotationz=0,	zoom=0.8, graphic="highlight.png" },
	Up={		x=0, 	y=-148, rotationz=0,	zoom=0.8, graphic="highlight.png" },
	UpRight={	x=67, 	y=-148, rotationz=0,	zoom=0.8, graphic="highlight.png" },

	Left={		x=-67,	y=-80,	rotationz=0,	zoom=0.8, graphic="highlight.png" },
	Center={	x=0, 	y=-80,	rotationz=0,	zoom=0.8, graphic="highlight.png" },
	Right={		x=67, 	y=-80,	rotationz=0,	zoom=0.8, graphic="highlight.png" },

	DownLeft={	x=-67,	y=-12,	rotationz=0,	zoom=0.8, graphic="highlight.png" },
	Down={		x=0,	y=-12,	rotationz=0,	zoom=0.8, graphic="highlight.png" },
	DownRight={	x=67, 	y=-12,	rotationz=0,	zoom=0.8, graphic="highlight.png" }
}



local pad = Def.ActorFrame{
	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenTestInput", "Player"):format( PlayerNumber:Reverse()[player]+1 ),
		InitCommand=function(self) self:y(-210):zoom(0.7):visible(false) end,
		OnCommand=function(self)
			local screenname =  SCREENMAN:GetTopScreen():GetName()
			local screenclass = THEME:GetMetric(screenname, "Class")
			self:visible( screenclass == "ScreenTestInput" )
		end
	},

	LoadActor(game..".png")..{  InitCommand=function(self) self:y(-80):zoom(0.8) end },

	LoadActor("buttons.png")..{
		InitCommand=function(self) self:y(80):zoom(0.5) end,
		OnCommand=function(self)
			local screenname =  SCREENMAN:GetTopScreen():GetName()
			local screenclass = THEME:GetMetric(screenname, "Class")
			self:visible( screenclass == "ScreenTestInput" )
		end
	},
}

for panel,values in pairs(Highlights) do
	pad[#pad+1] = LoadActor( values.graphic )..{
		InitCommand=function(self) self:xy(values.x, values.y):rotationz(values.rotationz):zoom(values.zoom):visible(false) end,
		OnCommand=function(self)
			local screenclass = THEME:GetMetric(SCREENMAN:GetTopScreen():GetName(), "Class")
			if panel=="Start" or panel=="Select" or panel=="MenuRight" or panel=="MenuLeft" then
				if screenclass ~= "ScreenTestInput" then
					self:hibernate(math.huge)
				end
			end
		end,
		TestInputEventMessageCommand=function(self, event)
			if event.PlayerNumber == player and event.button == panel then
				self:visible(event.type == "InputEventType_FirstPress")
			end
		end
	}
end

af[#af+1] = pad

return af