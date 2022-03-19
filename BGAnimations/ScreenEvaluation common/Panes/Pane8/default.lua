-- Pane8 displays a list of High Scores obrained from GrooveStats for the stepchart that was played.

if not IsServiceAllowed(SL.GrooveStats.AutoSubmit) then return end

local player = unpack(...)

local pane = Def.ActorFrame{
	InitCommand=function(self)
		self:y(_screen.cy - 62):zoom(0.8)
	end
}

-- -----------------------------------------------------------------------

-- 22px RowHeight by default, which works for displaying 10 machine HighScores
local args = { Player=player, RowHeight=22, HideScores=true }

args.NumHighScores = 10
pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)

pane[#pane+1] = Def.Sprite{
	Texture=THEME:GetPathG("","GrooveStats.png"),
	Name="GrooveStats_Logo",
	InitCommand=function(self)
		self:zoom(0.3)
		self:addx(165):addy(25)
	end,
}

return pane
