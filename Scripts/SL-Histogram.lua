-- This function interpolates between two vertices based on a given offset
function interpolate_vert(v1, v2, offset)
    -- Calculate the ratio of the offset to the difference in x-coordinates of the two vertices
    local ratio = (offset - v1[1][1]) / (v2[1][1] - v1[1][1])
    -- Interpolate the y-coordinate based on the ratio
    local y = v1[1][2] * (1 - ratio) + v2[1][2] * ratio
    -- Interpolate the color based on the ratio
    local color = lerp_color(ratio, v1[2], v2[2])
    -- Return the interpolated vertex and color as a table
    return {{offset, y, 0}, color}
end

local DensityGraphBottomColor = {0, 0.678, 0.753, 1}
local DensityGraphTopColor = {0.51, 0, 0.631, 1}

function NPS_Histogram(player, width, height, desaturation)
	local pn = ToEnumShortString(player)
	return Def.DensityGraph{
		InitCommand=function(self)
			self:SetSize(width, height)
				:SetColors(DensityGraphBottomColor, DensityGraphTopColor)
				:SetDesaturation(desaturation or 0)
		end,
		["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self)
			self:queuecommand("Redraw")
		end,
		RedrawCommand=function(self)
			-- we've reached a new song, so reset the vertices for the density graph
			-- this will occur at the start of each new song in CourseMode
			-- and at the start of "normal" gameplay
			local steps = GetCurrentChartSteps(player)
			self:SetSteps(steps, player):Build()
		end
	}
end

-- Set of density graphs for a course
-- TODO: Make it possible to regenerate new graphs in screen select course ?
function NPS_Histogram_Static_Course(player, width, height, desaturation)
	local af = Def.ActorFrame{}
	local trail = GAMESTATE:GetCurrentTrail(player)

	-- first get the total time
	local totaltime = TotalCourseLength(player)

	-- build a table of offsets and widths (doing one loop with everything in InitCommand will just use
	-- the last value whatever local variable in the loop was once the actors execute)
	local curx = 0
	local ptable = {}
	local PeakCourseNPS = 0
	for te in ivalues(trail:GetTrailEntries()) do
		local steps = te:GetSteps()
		local w = (te:GetSong():GetLastSecond() / SL.Global.ActiveModifiers.MusicRate / totaltime) * width
		local PeakTENPS = steps:GetPeakNps(player)
		if PeakTENPS > PeakCourseNPS then PeakCourseNPS = PeakTENPS end
		table.insert(ptable, {curx, w, steps, PeakTENPS})
		curx = curx + w
	end
	for _, pos in ipairs(ptable) do
		local Ratio = PeakCourseNPS > 0 and pos[4]/PeakCourseNPS or 0
		af[#af+1] = Def.DensityGraph{
			InitCommand = function(self)
				self:x(pos[1])
				self:SetSize(pos[2], height*Ratio)
				self:SetColors(DensityGraphBottomColor, DensityGraphTopColor)
				self:SetDesaturation(desaturation or 0)
				self:SetSteps(pos[3], player)
				self:Build()
			end
		}
	end

	return af
end

function NPS_Histogram_With_Position_Line(player, width, height)
	local af = Def.ActorFrame{}
	af[#af+1] = NPS_Histogram(player, width, height)
	local first_second, last_second
	local position_verts
	af[#af+1] = Def.ActorMultiVertex{
		Name="PositionLine",
		InitCommand=function(self)
			self:SetDrawState({Mode="DrawMode_LineStrip"})
				:SetLineWidth(2)
				:align(0, 0)
			local color = {1, 1, 1, 1}
			position_verts = {{{0, 0, 0}, color}, {{0, -height, 0}, color}}
			self:SetNumVertices(2):SetVertices(position_verts)

			local song = GAMESTATE:GetCurrentSong()
			first_second = math.min(song:GetTimingData():GetElapsedTimeFromBeat(0), 0)
			last_second = song:GetLastSecond()
		end,
		ScrollSongCommand=function(self)
			-- Move the line left and right
			local current_second = GAMESTATE:GetCurMusicSeconds()
			offset = scale(current_second, 0, last_second-first_second, 0, width)
			position_verts[1][1][1] = offset
			position_verts[2][1][1] = offset
			self:SetVertices(position_verts)
		end
	}
	return af
end

function Scrolling_NPS_Histogram(player, width, height, desaturation)
	local actor = nil

	return Def.DensityGraph{
		InitCommand=function(self)
			actor = self
			self:SetSize(width, height)
				:SetColors(DensityGraphBottomColor, DensityGraphTopColor)
				:SetDesaturation(desaturation or 0)
		end,
		LoadCurrentSong=function(self, scaled_width)
			actor:SetScrollOffset(0)
			actor:SetGraphWidth(scaled_width)

			local steps = GetCurrentChartSteps(player)
			actor:SetSteps(steps, player)
			actor:Build()
		end,
		SetScrollOffset=function(self, offset)
			actor:SetScrollOffset(offset)
		end
	}
end
