local player, pss, isTwoPlayers, bothWantBars, graph, percentToYCoordinate = unpack(...)

-- ---------------------------------------------------------------
local bg = Def.ActorFrame{}

bg.InitCommand=function(self)
	self:align(0,0)
end

-- ---------------------------------------------------------------
-- black background
bg[#bg+1] = Def.Quad{
	InitCommand=function(self)
		self:valign(1):halign(0)
			:zoomto(graph.w, graph.h)
			:xy(0,0):diffuse(Color.Black)
	end
}


-- adds alternating grey-black bars to represent each grade
-- (A-, A, A+, etc)
for i=1,16 do
	local tierStart = THEME:GetMetric("PlayerStageStats", "GradePercentTier" .. string.format("%02d", i))
	local tierEnd = THEME:GetMetric("PlayerStageStats", "GradePercentTier" .. string.format("%02d", i+1))
	local yStart = percentToYCoordinate(tierStart)
	local yEnd = percentToYCoordinate(tierEnd)

	bg[#bg+1] = Def.Quad{
		InitCommand=function(self)
			self:valign(0):halign(0)
				:zoomto(graph.w, -yStart+yEnd)
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

-- FIXME: There is currently a bug where having 2 narrow-width-graphs directly next to one another
-- when the display is 4:3 will result in the ☆☆☆ text being cut off.  It could be more easily
-- fixed if a single set of background Quads were drawn, but that would probably involve restructuring
-- this file to load once and handle [one, the other, both players] within.

-- grades for which we should draw a border/label
local gradeBorders = { 2, 3, 4, 7, 10, 13, 16 }
local gradeNames = {"☆☆☆", "☆☆", "☆", "S", "A", "B", "C"}

-- draws a horizontal line and a label at every major grade border
for i = 1,#gradeBorders do
	local tierStart = THEME:GetMetric("PlayerStageStats", "GradePercentTier" .. string.format("%02d", gradeBorders[i]))
	local yStart = percentToYCoordinate(tierStart)

	bg[#bg+1] = Def.Quad{
		InitCommand=function(self)
			self:valign(0):halign(0)
				:zoomto(graph.w, 0.9)
				:xy( 0, yStart )
		end,
		OnCommand=function(self)
			self:diffuse(color("#FFFFFF4F"))
		end,
	}

	-- in 4:3 the graphs touch each other, so the labels for P2 are redundant
	if not (isTwoPlayers and bothWantBars and player == PLAYER_2 and not IsUsingWideScreen()) then
		bg[#bg+1] = Def.BitmapText{
			Font=ThemePrefs.Get("ThemeFont") .. " Normal",
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
			GradeChangedCommand=function(self)
				if (bothWantBars and not IsUsingWideScreen()) then
					return
				end
				if (pss:GetGrade() == ("Grade_Tier" .. string.format("%02d", gradeBorders[i])) ) then
					self:decelerate(0.5):zoom(1.5)
				end
			end,
		}
	end
end

return bg