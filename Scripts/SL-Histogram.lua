local function gen_vertices(player, width, height, desaturation)
	local Song, Steps
	local first_step_has_occurred = false
	local pn = ToEnumShortString(player)

	if GAMESTATE:IsCourseMode() then
		local TrailEntry = GAMESTATE:GetCurrentTrail(player):GetTrailEntry(GAMESTATE:GetCourseSongIndex())
		Steps = TrailEntry:GetSteps()
		Song = TrailEntry:GetSong()
	else
		Steps = GAMESTATE:GetCurrentSteps(player)
		Song = GAMESTATE:GetCurrentSong()
	end
	
	if not Steps or not Song then return {} end

	-- This function does no work if we already have the data in SL.Streams cache.
	ParseChartInfo(Steps, pn)
	PeakNPS = SL[pn].Streams.PeakNPS
	NPSperMeasure = SL[pn].Streams.NPSperMeasure 
	-- store the PeakNPS in GAMESTATE:Env()[pn.."PeakNPS"] in case both players are joined
	-- their charts may have different peak densities, and if they both want histograms,
	-- we'll need to be able to compare densities and scale one of the graphs vertically
	GAMESTATE:Env()[pn.."PeakNPS"] = PeakNPS

	-- use MESSAGEMAN to broadcast that the peak NPS has been calculated (and/or updated in CourseMode)
	-- and is available.  actors on the current screen can listen for this via something like:
	--
	-- PeakNPSUpdatedMessageCommand=function(self)
	--   local p1peak = GAMESTATE:Env()["P1PeakNPS"]
	-- end
	MESSAGEMAN:Broadcast("PeakNPSUpdated")

	local verts = {}
	local x, y, t

	if (PeakNPS and NPSperMeasure and #NPSperMeasure > 1) then
		local TimingData = Steps:GetTimingData()
		local FirstSecond = math.min(TimingData:GetElapsedTimeFromBeat(0), 0)
		local LastSecond = Song:GetLastSecond()

		-- magic numbers obtained from Photoshop's Eyedrop tool in rgba percentage form (0 to 1)
		local blue   = {0,    0.678, 0.753, 1}
		local purple = {0.51, 0,     0.631, 1}

		if desaturation ~= nil then
			local function Desaturate(color, desaturation)
				local luma = 0.3 * color[1] + 0.59 * color[2] + 0.11 * color[3]
				color[1] = color[1] + desaturation * (luma - color[1])
				color[2] = color[2] + desaturation * (luma - color[2])
				color[3] = color[3] + desaturation * (luma - color[3])
				return color
			end
			blue = Desaturate(blue, desaturation)
			purple = Desaturate(purple, desaturation)
		end

		local upper

		for i, nps in ipairs(NPSperMeasure) do

			if nps > 0 then first_step_has_occurred = true end

			if first_step_has_occurred then
				-- i will represent the current measure number but will be 1 larger than
				-- it should be (measures in SM start at 0; indexed Lua tables start at 1)
				-- subtract 1 from i now to get the actual measure number to calculate time
				t = TimingData:GetElapsedTimeFromBeat((i-1)*4)

				x = scale(t, FirstSecond, LastSecond, 0, width)
				y = round(-1 * scale(nps, 0, PeakNPS, 0, height))

				-- if the height of this measure is the same as the previous two measures
				-- we don't need to add two more points (bottom and top) to the verts table,
				-- we can just "extend" the previous two points by updating their x position
				-- to that of the current measure.  For songs with long streams, this should
				-- cut down on the overall size of the verts table significantly.
				if #verts > 2 and verts[#verts][1][2] == y and verts[#verts-2][1][2] == y then
					verts[#verts][1][1] = x
					verts[#verts-1][1][1] = x
				else
					-- lerp_color() is a global function defined by the SM engine that takes three arguments:
					--    a float between [0,1]
					--    color1
					--    color2
					-- and returns a color that has been linearly interpolated by that percent between the two colors provided
					-- for example, lerp_color(0.5, yellow, orange) will return the color that is halfway between yellow and orange
					upper = lerp_color(math.abs(y/height), blue, purple )

					verts[#verts+1] = {{x, 0, 0}, blue} -- bottom of graph (blue)
					verts[#verts+1] = {{x, y, 0}, upper}  -- top of graph (somewhere between blue and purple)
				end
			end
		end

		-- Insert a 0 NPS datapoint at the end of the graph, otherwise
		-- the last measure will not have a nice downwards slope like
		-- all the other measures but end abruptly at the start of the
		-- measure.
		if NPSperMeasure[#NPSperMeasure] ~= 0 then
			verts[#verts+1] = {{width, 0, 0}, blue}
			verts[#verts+1] = {{width, 0, 0}, blue}
		end
	end

	return verts
end

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

function NPS_Histogram(player, width, height, desaturation)
	local pn = ToEnumShortString(player)
	local amv = Def.ActorMultiVertex{
		InitCommand=function(self)
			self:SetDrawState({Mode="DrawMode_QuadStrip"})
		end,
		["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self)
			self:queuecommand("Redraw")
		end,
		RedrawCommand=function(self)
			-- we've reached a new song, so reset the vertices for the density graph
			-- this will occur at the start of each new song in CourseMode
			-- and at the start of "normal" gameplay
			local verts = gen_vertices(player, width, height, desaturation)
			self:SetNumVertices(#verts):SetVertices(verts)
		end
	}

	return amv
end


function Scrolling_NPS_Histogram(player, width, height, desaturation)
	local verts, visible_verts
	local left_idx, right_idx

	local amv = Def.ActorMultiVertex{
		InitCommand=function(self)
			self:SetDrawState({Mode="DrawMode_QuadStrip"})
		end,
		UpdateCommand=function(self)
			if visible_verts ~= nil then
				self:SetNumVertices(#visible_verts):SetVertices(visible_verts)
				visible_verts = nil
			end
		end,

		LoadCurrentSong=function(self, scaled_width)
			verts = gen_vertices(player, scaled_width, height, desaturation)

			left_idx = 1
			right_idx = 2
			self:SetScrollOffset(0)
		end,
		SetScrollOffset=function(self, offset)
			local left_offset = offset
			local right_offset = offset + width

			for i = left_idx, #verts, 2 do
				if verts[i][1][1] >= left_offset then
					left_idx = i
					break
				end
			end

			for i = right_idx, #verts, 2 do
				if verts[i][1][1] <= right_offset then
					right_idx = i
				else
					break
				end
			end

			if left_idx == 1 and right_idx == #verts then
				-- All vertices are visible.
				-- This saves memory as the assignment here isn't a copy unlike unpack().
				-- This is necessary for songs like "Blue (Da Ba Dee)" from Crapyard Scent.
				visible_verts = verts
			else
				-- Pick ther vertices to display.
				visible_verts = {unpack(verts, left_idx, right_idx)}

				if left_idx > 1 then
					local prev1, prev2, cur1, cur2 = unpack(verts, left_idx-2, left_idx+1)
					table.insert(visible_verts, 1, interpolate_vert(prev1, cur1, left_offset))
					table.insert(visible_verts, 2, interpolate_vert(prev2, cur2, left_offset))
				end

				if right_idx < #verts then
					local cur1, cur2, next1, next2 = unpack(verts, right_idx-1, right_idx+2)
					table.insert(visible_verts, interpolate_vert(cur1, next1, right_offset))
					table.insert(visible_verts, interpolate_vert(cur2, next2, right_offset))
				end
			end
		end
	}

	return amv
end
