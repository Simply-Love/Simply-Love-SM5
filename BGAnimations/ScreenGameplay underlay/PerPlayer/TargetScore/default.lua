local player = ...
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

-- Pacemaker mod by JackG

local function get43size(size4_3)
	return 640*(size4_3/854)
end

-- Ported from PSS.cpp, can be removed if that gets exported to Lua
local function GetCurMaxPercentDancePoints()
	local possible = pss:GetPossibleDancePoints()
	if possible == 0 then
		return 0
	end
	local currentMax = pss:GetCurrentPossibleDancePoints()
	if currentMax == possible then
		return 1
	end
	return currentMax / possible
end

-- if nobody wants us, we won't appear
if (SL[ToEnumShortString(player)].ActiveModifiers.TargetStatus == "Disabled") or SL.Global.Gamestate.Style == "double" then
	return false
end

local isTwoPlayers = (GAMESTATE:IsPlayerEnabled(PLAYER_1) and GAMESTATE:IsPlayerEnabled(PLAYER_2))

local bothWantBars = isTwoPlayers
                     and (SL[ToEnumShortString(PLAYER_1)].ActiveModifiers.TargetStatus == "Bars" or SL[ToEnumShortString(PLAYER_1)].ActiveModifiers.TargetStatus == "Both")
                     and (SL[ToEnumShortString(PLAYER_2)].ActiveModifiers.TargetStatus == "Bars" or SL[ToEnumShortString(PLAYER_2)].ActiveModifiers.TargetStatus == "Both")

local targetBarBorderWidth = 2

local graphHeight = 350
local graphWidth  = WideScale(250, 300)
local graphX = 0
local graphY = 430

if isTwoPlayers then
	graphY = 425
	-- tinier graph
	graphWidth = WideScale(25, 70)
	-- tinier border for the target bar
	targetBarBorderWidth = 1
	
	local separator = 0
	
	if IsUsingWideScreen() then
		separator = 5
	end
	
	-- put the graph right beside the note field
	if (player == PLAYER_1) then
		graphX = _screen.w / 2 - graphWidth - separator
	else
		graphX = _screen.w / 2 + separator
	end
else
	-- put the graph on the other side of the screen
	if (player == PLAYER_1) then
		graphX = WideScale( get43size(500), 500)
	else
		graphX = WideScale( get43size(40), 40)
	end
end

local barWidth = graphWidth * 0.25
local barSpacing = barWidth / 4
local barOffset = barSpacing / 3

-- two player mode only shows current and target bar, so this needs to be adjusted
if isTwoPlayers then
	barWidth = graphWidth * 0.3
	barSpacing = barWidth / 3
		
	if IsUsingWideScreen() then
		barOffset = barSpacing
	else
		barOffset = barSpacing * 1.5
	end
end

-- used to determine when we change grade
local currentGrade = nil
local previousGrade = nil

-- possible targets
-- { 'C-', 'C', 'C+', 'B-', 'B', 'B+', 'A-', 'A', 'A+', 'S-', 'S', 'S+', '*', '**', '***', '****', 'Machine best', 'Personal best' }

-- get personal best score
local pbGradeScore = GetTopScore(player, "Personal")

-- get the index of the target chosen in the options menu
local targetGradeIndex = tonumber(SL[ToEnumShortString(player)].ActiveModifiers.TargetBar)
local targetGradeScore = 0

if (targetGradeIndex == 17) then
	targetGradeScore = GetTopScore(player, "Machine")
elseif (targetGradeIndex == 18) then
	targetGradeScore = pbGradeScore
else
	targetGradeScore = THEME:GetMetric("PlayerStageStats", "GradePercentTier" .. string.format("%02d", 17 - targetGradeIndex))
end

-- if there is no personal/machine score, automatically choose S as target
if targetGradeScore == 0 then
	targetGradeScore = THEME:GetMetric("PlayerStageStats", "GradePercentTier06")
end

-- Converts a percentage to an exponential scale, returning the corresponding Y point in the graph
function percentToYCoordinate(scorePercent)
	return -(graphHeight*math.pow(100,scorePercent)/100)
end

-- Converts a grade enum to an exponential scale, returning the corresponding Y point in the graph
function getYFromGradeEnum(gradeEnum)
	return percentToYCoordinate(THEME:GetMetric("PlayerStageStats", "GradePercent" .. ToEnumShortString(gradeEnum)))
end

-- Actor frame for the background of the graph
local barsBgActor = Def.ActorFrame{

	InitCommand=function(self)
		self:valign(0):halign(0)
	end,
	
	-- black background
	Def.Quad{
		InitCommand=function(self)
			self:valign(1):halign(0)
				:zoomto(graphWidth, graphHeight)
				:xy( 0, 0 )
		end,
		OnCommand=function(self)
			self:diffuse(color("#000000FF"))
		end,
	}
}

-- adds alternating grey-black bars to represent each grade and sub-grade
-- (A-, A, A+, etc)
for i=1,16 do
	local tierStart = THEME:GetMetric("PlayerStageStats", "GradePercentTier" .. string.format("%02d", i))
	local tierEnd = THEME:GetMetric("PlayerStageStats", "GradePercentTier" .. string.format("%02d", i+1))
	local yStart = percentToYCoordinate(tierStart)
	local yEnd = percentToYCoordinate(tierEnd)
	
	barsBgActor[#barsBgActor+1] = Def.Quad{
		InitCommand=function(self)
			self:valign(0):halign(0)
				:zoomto(graphWidth, -yStart+yEnd)
				:xy( 0, yStart )
		end,
		OnCommand=function(self)
			if (i % 2 == 1) then
				self:diffuse(color("#FFFFFF10"))
			else
				self:diffuse(color("#00000007"))
			end
		end,
	}
end

-- grades for which we should draw a border/label
local gradeBorders = { 2, 3, 4, 7, 10, 13, 16 }
local gradeNames = {"☆☆☆", "☆☆", "☆", "S", "A", "B", "C"}

-- draws a horizontal line and a label at every major grade border
for i = 1,#gradeBorders do
	local tierStart = THEME:GetMetric("PlayerStageStats", "GradePercentTier" .. string.format("%02d", gradeBorders[i]))
	local yStart = percentToYCoordinate(tierStart)
	
	barsBgActor[#barsBgActor+1] = Def.Quad{
		InitCommand=function(self)
			self:valign(0):halign(0)
				:zoomto(graphWidth, 0.9)
				:xy( 0, yStart )
		end,
		OnCommand=function(self)
			self:diffuse(color("#FFFFFF4F"))
		end,
	}
	
	-- in 4:3 the graphs touch each other, so the labels for P2 are redundant
	if not (isTwoPlayers and bothWantBars and player == PLAYER_2 and not IsUsingWideScreen()) then
		barsBgActor[#barsBgActor+1] = Def.BitmapText{
			Font="_miso",
			Text=gradeNames[i],
			InitCommand=function(self)
				self:valign(1):halign(0)
					:xy( 2, yStart-2 )
				-- make stars a little smaller
				if i<4 then
					self:zoom(0.75)
				end
			end,
			-- zoom the label once we reach a grade, but only in 16:9
			GradeChangeMessageCommand=function(self)
				if (bothWantBars and not IsUsingWideScreen()) then
					return
				end
				if (currentGrade == ("Grade_Tier" .. string.format("%02d", gradeBorders[i])) ) then
					self:decelerate(0.5):zoom(1.5)
				end
			end,
		}
	end
end

-- this is the final actor frame where everything will be shoved
local finalFrame = Def.ActorFrame{

	InitCommand=function(self)
		-- this makes for a more convenient coordinate system
		self:valign(0):halign(0)
	end,
	OnCommand=function(self)
		self:xy(graphX, graphY)
		
		currentGrade = pss:GetGrade()
		previousGrade = currentGrade
	end,
	-- any time we receive a judgment
	JudgmentMessageCommand=function(self,params)
		currentGrade = pss:GetGrade()
		
		-- this broadcasts a message to tell other actors that we have changed grade
		if (currentGrade ~= previousGrade) then
			MESSAGEMAN:Broadcast("GradeChange")
			previousGrade = currentGrade
		end
		self:queuecommand("Update")
	end,

}

-- if the player wants the bar graph
if (SL[ToEnumShortString(player)].ActiveModifiers.TargetStatus == "Bars" or SL[ToEnumShortString(player)].ActiveModifiers.TargetStatus == "Both") then
	if isTwoPlayers then
		-- only two bars in 2 players mode
		finalFrame[#finalFrame+1] = Def.ActorFrame {
			-- insert the background actor frame
			barsBgActor,
			
			-- BAR 1
			-- Current Score
			Def.Quad{
				InitCommand=function(self)
					self:valign(1):halign(0)
						:zoomto(barWidth, 1)
						:xy( barSpacing + barOffset, 0 )
				end,
				OnCommand=function(self)
					self:diffuse(Color.Blue)
				end,
				JudgmentMessageCommand=function(self) self:queuecommand("Update") end,
				-- follow the player's score
				UpdateCommand=function(self)
					local dp = pss:GetPercentDancePoints()
					self:zoomy(-percentToYCoordinate(dp))
				end
			},
			
			-- BAR 2
			-- Target Score
			Def.Quad{
				InitCommand=function(self)
					self:valign(1):halign(0)
						:zoomto(barWidth, 1)
						:xy( barOffset + barSpacing * 2 + barWidth, 0 )
				end,
				OnCommand=function(self)
					self:diffuse(Color.Red)
				end,
				JudgmentMessageCommand=function(self) self:queuecommand("Update") end,
				UpdateCommand=function(self)
					local targetDP = targetGradeScore * GetCurMaxPercentDancePoints()
					self:zoomy(-percentToYCoordinate(targetDP))
				end
			},
			
			-- TARGET BORDER
			Border(barWidth+targetBarBorderWidth*2, -percentToYCoordinate(targetGradeScore)+3, targetBarBorderWidth)..{
				InitCommand=function(self)
					self:xy(barOffset + barSpacing * 2 + barWidth + barWidth/2, percentToYCoordinate(targetGradeScore)/2)
				end,
			},
		}
	else
		finalFrame[#finalFrame+1] = Def.ActorFrame {
			
			-- insert the background actor frame
			barsBgActor,
			
			-- BAR 1
			-- Current Score
			Def.Quad{
				InitCommand=function(self)
					self:valign(1):halign(0)
						:zoomto(barWidth, 1)
						:xy( barSpacing + barOffset, 0 )
				end,
				OnCommand=function(self)
					self:diffuse(Color.Blue)
				end,
				JudgmentMessageCommand=function(self) self:queuecommand("Update") end,
				-- follow the player's score
				UpdateCommand=function(self)
					local dp = pss:GetPercentDancePoints()
					self:zoomy(-percentToYCoordinate(dp))
				end
			},
			
			-- BAR 2
			-- Personal Best Score
			Def.Quad{
				InitCommand=function(self)
					self:valign(1):halign(0)
						:xy( barOffset + (barSpacing * 2) + barWidth, 0 )
						:zoomto(barWidth, -percentToYCoordinate(pbGradeScore))
				end,
				OnCommand=function(self)
					self:diffuse(Color.Green)
				end,
			},
			
			-- BAR 3
			-- Target Score
			Def.Quad{
				InitCommand=function(self)
					self:valign(1):halign(0)
						:zoomto(barWidth, 1)
						:xy( barOffset + barSpacing * 3 + barWidth * 2, 0 )
				end,
				OnCommand=function(self)
					self:diffuse(Color.Red)
				end,
				JudgmentMessageCommand=function(self) self:queuecommand("Update") end,
				UpdateCommand=function(self)
					local targetDP = targetGradeScore * GetCurMaxPercentDancePoints()
					self:zoomy(-percentToYCoordinate(targetDP))
				end
			},
			
			-- PERSONAL BEST BORDER
			Border(barWidth+4, -percentToYCoordinate(pbGradeScore)+3, targetBarBorderWidth)..{
				InitCommand=function(self)
					self:xy(barOffset + (barSpacing * 2) + (barWidth/2) + barWidth * 1, percentToYCoordinate(pbGradeScore)/2)
				end,
			},
			
			-- TARGET BORDER
			Border(barWidth+4, -percentToYCoordinate(targetGradeScore)+3, targetBarBorderWidth)..{
				InitCommand=function(self)
					self:xy(barOffset + (barSpacing * 3) + (barWidth/2) + barWidth * 2, percentToYCoordinate(targetGradeScore)/2)
				end,
			},
			
			-- pretty explody thingies for grade changes
			
			LoadActor("./heartsplode")..{
				InitCommand=cmd(diffusealpha,0),
				GradeChangeMessageCommand=cmd(y, getYFromGradeEnum(currentGrade); diffuse, GetCurrentColor(); rotationz,10; diffusealpha,0; zoom,0; diffusealpha,0.9; linear,0.6; rotationz,0; zoom,0.5; diffusealpha,0),
			},
			LoadActor("./heartsplode")..{
				InitCommand=cmd(diffusealpha,0),
				GradeChangeMessageCommand=cmd(y, getYFromGradeEnum(currentGrade); diffuse, GetCurrentColor(); rotationy,180; rotationz,-10; diffusealpha,0; zoom,0.2; diffusealpha,0.8; decelerate,0.6; rotationz,0; zoom,0.7; diffusealpha,0),
			},
			LoadActor("./minisplode")..{
				InitCommand=cmd(diffusealpha,0),
				GradeChangeMessageCommand=cmd(y, getYFromGradeEnum(currentGrade); diffuse, GetCurrentColor(); rotationz,10; diffusealpha,0; zoom,0; diffusealpha,1; decelerate,0.8; rotationz,0; zoom,0.4; diffusealpha,0),
			},
		}
		
		-- graph border and text labels for the bars
		finalFrame[#finalFrame+1] = Def.ActorFrame {
			-- white graph border
			Border(graphWidth+4, graphHeight+4, 2)..{
				InitCommand=function(self)
					self:valign(1):halign(0)
					self:xy(graphWidth/2,-graphHeight/2)
				end,
			},
			
			Def.BitmapText{
				Font="_miso",
				Text="You",
				InitCommand=function(self)
					self:xy( barOffset + barSpacing + (barWidth/2), 20 )
				end,
			},

			Def.BitmapText{
				Font="_miso",
				Text="Personal",
				InitCommand=function(self)
					self:xy( barOffset + (barSpacing * 2) + (barWidth/2) + barWidth, 20 )
				end,
			},
			
			Def.BitmapText{
				Font="_miso",
				Text="Target",
				InitCommand=function(self)
					self:xy( barOffset + (barSpacing * 3) + (barWidth/2) + barWidth * 2, 20 )
				end,
			},
		}
	end
end

-- pacemaker text (or subtractive scoring, if that's your thing)
if (SL[ToEnumShortString(player)].ActiveModifiers.TargetStatus == "Target" or SL[ToEnumShortString(player)].ActiveModifiers.TargetStatus == "Both") then
	finalFrame[#finalFrame+1] = Def.BitmapText{
		Font="_wendy small",
		Text="+0.00",
		InitCommand=function(self)
			local noteX
			-- aligned to the score
			if (player == PLAYER_1) then
				noteX = GetNotefieldX(player) + (GetNotefieldWidth() / 4) - graphX
			else
				noteX = GetNotefieldX(player) - (GetNotefieldWidth() / 4) - graphX - 15
			end
			
			self:xy( noteX, 56 - graphY ):zoom(0.4)
		end,
		JudgmentMessageCommand=function(self,params)
			self:queuecommand("Update")
		end,
		UpdateCommand=function(self)
			local percentDifference = pss:GetPercentDancePoints() - (targetGradeScore * GetCurMaxPercentDancePoints())
			self:settext(string.format("%+2.2f", percentDifference * 100))
		end
	}
end

return finalFrame
