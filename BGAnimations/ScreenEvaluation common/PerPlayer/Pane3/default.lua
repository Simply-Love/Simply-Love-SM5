-- Pane3 displays a list of HighScores for the stepchart that was played.

local player = ...

local pane = Def.ActorFrame{
	Name="Pane3",
	InitCommand=function(self)
		self:visible(false)
		self:y(_screen.cy - 62):zoom(0.8)
	end
}

-- row_height of a HighScore line
local rh
local args = { Player=player, RoundsAgo=1, RowHeight=rh}

-- if the player is using a profile (local or USB)
if PROFILEMAN:IsPersistentProfile(player) then

	-- less line spacing between HighScore rows to fit the horizontal line
	rh = 20.25
	args.RowHeight = rh

	-- top 7 machine HighScores
	args.NumHighScores = 7
	pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)

	-- horizontal line visually separating machine HighScores from player HighScores
	pane[#pane+1] = Def.Quad{ InitCommand=function(self) self:zoomto(100, 1):y(rh*8):diffuse(1,1,1,0.33) end }

	-- top 3 player HighScores
	args.NumHighScores = 3
	args.Profile = PROFILEMAN:GetProfile(player)
	pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)..{
		InitCommand=function(self) self:y(rh*8) end
	}

-- else the player is not using a profile
else
	-- more breathing room between HighScore rows
	rh = 22
	args.RowHeight = rh

	-- top 10 machine HighScores
	args.NumHighScores = 10
	pane[#pane+1] = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)
end

return pane