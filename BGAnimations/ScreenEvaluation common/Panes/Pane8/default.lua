-- Pane8 displays a list of High Scores obrained from GrooveStats for the stepchart that was played.

if not IsServiceAllowed(SL.GrooveStats.AutoSubmit) then return end

local player = unpack(...)

local p = player:sub(-1)
local pane = Def.ActorFrame{
	InitCommand=function(self)
		self:y(_screen.cy - 62):zoom(0.8)
	end
}

-- -----------------------------------------------------------------------

-- 22px RowHeight by default, which works for displaying 10 machine HighScores
local args = { Player=player, RowHeight=22, HideScores=true }

args.NumHighScores = 10

pane[#pane+1] = Def.Sprite{
	Texture=THEME:GetPathG("","GrooveStats.png"),
	Name="GrooveStats_Logo",
	InitCommand=function(self)
		self:zoom(1.5)
		self:addx(0):addy(100)
		self:diffusealpha(0.5)
	end,
	BoogieLogoMessageCommand=function(self,params)
		if (params.player-p) == 0 then 
			self:visible(false)
		end
	end
}
pane[#pane+1] = Def.Sprite{
	Texture=THEME:GetPathG("","BoogieStats.png"),
	Name="BoogieStats_Logo",
	InitCommand=function(self)
		self:visible(false)
		self:zoom(1.5)
		self:addx(0):addy(100)
		self:diffusealpha(0.5)
	end,
	BoogieLogoMessageCommand=function(self,params)
		if (params.player-p) == 0 then 
			self:visible(true)
		end
	end
}

pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)



return pane