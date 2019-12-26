local player = ...

--variables needed for both the legend and the bargraph
local w, h, num_lines, num_lines_y, max_dif, min_dif

CreateLineGraph = function(_w, _h)
	w, h = _w, _h
----------------------------------------------------------------------------------------------------
--Legend
----------------------------------------------------------------------------------------------------
	local legend = LoadFont("_wendy small")..{
		Name="VertLegend_BMT",
		Initialize=function(self, actor)
			local toPrint = ""
			for i = max_dif, min_dif,-1 do
				if i ~= 25 then
					toPrint = toPrint..i .. "\n"
				else 
					toPrint = toPrint..i.."+\n"
				end
			end
			_, count = string.gsub(toPrint, " ", " ")
			actor:settext(toPrint)
			actor:zoom(h/num_lines_y/100) --each line is 100 pixels
		end,
	}
	legend.InitCommand=function(self)
		self:zoom(1):halign(0):xy(-100,10)
	end						
----------------------------------------------------------------------------------------------------
--Line connecting the points on the graph
----------------------------------------------------------------------------------------------------	
	local pointsLine = Def.ActorMultiVertex{
		Name="PointsLine_AMV",
		Initialize=function(self, actor)
			local verts = {}
			for i,song in pairs(SL[ToEnumShortString(player)].Stages.Stats) do
				if song.difficultyMeter then --if player backs out of a song then Stages.Stats will have an empty table. Ignore that.
					local diff = max_dif - song.difficultyMeter
					if diff < 0 then diff = 0 end --max difficulty to show is 25.
					local color = Color.Green
					if song.grade and song.grade == "Grade_Failed" then
						color = Color.Red
					end
					table.insert(verts,{{i*(w/num_lines),diff*(h/num_lines_y),0}, Color.White})
				end
			end
			actor:SetNumVertices(#verts):SetVertices(verts)
		end
	}
	pointsLine.InitCommand=function(self)
		self:SetDrawState({Mode="DrawMode_LineStrip"})
			:xy(-75,-75)
	end	
	
----------------------------------------------------------------------------------------------------
--Gridlines
----------------------------------------------------------------------------------------------------
	local graphLines = Def.ActorMultiVertex{
		Name="GraphLines_AMV",
		Initialize=function(self, actor)
			local verts = {}
			----------------------------------------------------------------------------------------------------
			--Create grid lines
			----------------------------------------------------------------------------------------------------
			--vertical lines
			for i = 1, num_lines do --don't need to draw the first line because it's a white line drawn later
				table.insert(verts,{{i*(w/num_lines),0,0}, {.5,.5,.5,1}})
				table.insert(verts,{{i*(w/num_lines),h,0}, {.5,.5,.5,1}})
				table.insert(verts,{{i*(w/num_lines)+1,h,0}, {.5,.5,.5,1}})
				table.insert(verts,{{i*(w/num_lines)+1,0,0}, {.5,.5,.5,1}})
			end
			--horizontal lines
			local tab = {}
			for i = 0, num_lines_y - 1 do --don't need to draw the last line because it's a white line drawn later
				table.insert(verts,{{0,i*(h/num_lines_y),0}, {.5,.5,.5,1}})
				table.insert(verts,{{w,i*(h/num_lines_y),0}, {.5,.5,.5,1}})
				table.insert(verts,{{w,i*(h/num_lines_y)+1,0}, {.5,.5,.5,1}})
				table.insert(verts,{{0,i*(h/num_lines_y)+1,0}, {.5,.5,.5,1}})
				tab[#tab+1] = i*(math.floor(h/num_lines_y))
			end
			table.insert(verts,{{0,0,0}, Color.White})
			table.insert(verts,{{0,h,0}, Color.White})
			table.insert(verts,{{1,h,0}, Color.White})
			table.insert(verts,{{1,0,0}, Color.White})
			
			table.insert(verts,{{0,h,0}, Color.White})
			table.insert(verts,{{w,h,0}, Color.White})
			table.insert(verts,{{w,h+1,0}, Color.White})
			table.insert(verts,{{0,h+1,0}, Color.White})

			actor:SetNumVertices(#verts):SetVertices(verts)
		end
	}
	graphLines.InitCommand=function(self)
		self:SetDrawState({Mode="DrawMode_Quads"})
			:xy(-75,-75)
	end																																  
----------------------------------------------------------------------------------------------------
--Points on the graph
----------------------------------------------------------------------------------------------------
	local graphPoints = Def.ActorMultiVertex{
		Name="GraphPoints_AMV",
		Initialize=function(self, actor)
			local verts = {}
			for i,song in pairs(SL[ToEnumShortString(player)].Stages.Stats) do
				if song.difficultyMeter then --if player backs out of a song then Stages.Stats will have an empty table. Ignore that.
					local diff = max_dif - song.difficultyMeter
					if diff < 0 then diff = 0 end --max difficulty to show is 25.
					local color = Color.Green
					if song.grade and song.grade == "Grade_Failed" then
						color = Color.Red
					end
					table.insert(verts,{{i*(w/num_lines)-3,diff*(h/num_lines_y)-3,0}, color})
					table.insert(verts,{{i*(w/num_lines)+3,diff*(h/num_lines_y)-3,0}, color})
					table.insert(verts,{{i*(w/num_lines)+3,diff*(h/num_lines_y)+3,0}, color})
					table.insert(verts,{{i*(w/num_lines)-3,diff*(h/num_lines_y)+3,0}, color})
				end
			end
			
			actor:SetNumVertices(#verts):SetVertices(verts)
		end
	}
	graphPoints.InitCommand=function(self)
		self:SetDrawState({Mode="DrawMode_Quads"})
			:xy(-75,-75)
	end	
----------------------------------------------------------------------------------------------------
--Grade Underlay
----------------------------------------------------------------------------------------------------
	local gradeUnderlay = Def.ActorMultiVertex{
		Name="GradeUnderlay_AMV",
		Initialize=function(self, actor)
			local verts = {}
			table.insert(verts,{{0,h,0}, Color.Red})
			table.insert(verts,{{0,h,0}, Color.Purple})
			for i,song in pairs(SL[ToEnumShortString(player)].Stages.Stats) do
				if song.score then --if player backs out of a song then Stages.Stats will have an empty table. Ignore that.
					local scorePoint = h-h*song.score
					table.insert(verts,{{i*(w/num_lines),scorePoint,0},Color.Purple})
					table.insert(verts,{{i*(w/num_lines),h,0},Color.Red})
				end
			end
			actor:SetNumVertices(#verts):SetVertices(verts)
		end
	}
	gradeUnderlay.InitCommand=function(self)
		self:SetDrawState({Mode="DrawMode_QuadStrip"})
			:xy(-75,-75)
	end					
	
	af=Def.ActorFrame{}
	af[#af+1]=gradeUnderlay
	af[#af+1]=graphLines
	af[#af+1]=pointsLine
	af[#af+1]=graphPoints
	af[#af+1]=legend
	af.SetOptionPanesMessageCommand=function(self)
		if #SL.Global.Stages.Stats ~= 0 then 
			if #SL.Global.Stages.Stats < 5 then num_lines = 5 
			else num_lines = #SL.Global.Stages.Stats end
			for _,song in pairs(SL[ToEnumShortString(player)].Stages.Stats) do
				if song.difficultyMeter then --if player backs out of a song then Stages.Stats will have an empty table. Ignore that.
					if max_dif == nil or song.difficultyMeter > max_dif then max_dif = song.difficultyMeter end
					if min_dif == nil or song.difficultyMeter < min_dif then min_dif = song.difficultyMeter end
				end
			end
			if max_dif > 25 then max_dif = 25 end --max difficulty to display is 25
			num_lines_y = max_dif - min_dif
			if num_lines_y < 5 then
				local extra = math.floor((5 - num_lines_y) / 2)
				max_dif = max_dif + extra + ((5 - num_lines_y) % 2)
				min_dif = min_dif - extra
				num_lines_y = 5
			end
			pointsLine:Initialize(self:GetChild("PointsLine_AMV"))
			graphLines:Initialize(self:GetChild("GraphLines_AMV"))
			graphPoints:Initialize(self:GetChild("GraphPoints_AMV"))
			gradeUnderlay:Initialize(self:GetChild("GradeUnderlay_AMV"))
			legend:Initialize(self:GetChild("VertLegend_BMT"))
		end
	end
	
	return af
	
end