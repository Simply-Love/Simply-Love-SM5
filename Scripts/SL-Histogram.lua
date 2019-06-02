NPS_Histogram = function(player, _w, _h)

	local SongNumberInCourse = 0

	local amv = Def.ActorMultiVertex{
		Name="DensityGraph_AMV",

		-- based on noticeable lag at ~3.5k
		MaxVertices = 2000,

		Initialize=function(self, actor)
			local Song, Steps
			local first_step_has_occurred = false

			if GAMESTATE:IsCourseMode() then
				local TrailEntry = GAMESTATE:GetCurrentTrail(player):GetTrailEntries()[SongNumberInCourse]
				Steps = TrailEntry:GetSteps()
				Song = TrailEntry:GetSong()
			else
				Steps = GAMESTATE:GetCurrentSteps(player)
				Song = GAMESTATE:GetCurrentSong()
			end

			local PeakNPS, NPSperMeasure = GetNPSperMeasure(Song, Steps)
			-- broadcast this for any other actors on the current screen that rely on knowing the peak nps
			MESSAGEMAN:Broadcast("PeakNPSUpdated", {PeakNPS=PeakNPS})

			-- also, store the PeakNPS in SL[pn] in case both players are joined
			-- their charts may have different peak densities, and if they both want histograms,
			-- we'll need to be able to compare densities and scale one of the graphs vertically
			SL[ToEnumShortString(player)].NoteDensity.Peak = PeakNPS

			-- FIXME: come up with a way to do this^ that doesn't rely on the SL table so other
			-- themes can use this NPS_Histogram function more easily

			local verts = {}
			local x, y, t

			if (PeakNPS and NPSperMeasure and #NPSperMeasure > 1) then

				local TimingData = Steps:GetTimingData()

				-- Don't use Song:MusicLengthSeconds() because it includes time
				-- at the beginning before beat 0 has occurred
				local FirstSecond =  Song:GetFirstSecond()
				local LastSecond = Song:GetLastSecond()

				-- magic numbers obtained from Photoshop's Eyedrop tool
				local yellow = {0.968, 0.953, 0.2, 1}
				local orange = {0.863, 0.553, 0.2, 1}
				local upper

				for i, nps in ipairs(NPSperMeasure) do

					if nps > 0 then first_step_has_occurred = true end

					if first_step_has_occurred then
						-- i will represent the current measure number but will be 1 larger than
						-- it should be (measures in SM start at 0; indexed Lua tables start at 1)
						-- subtract 1 from i now to get the actual measure number to calculate time
						t = TimingData:GetElapsedTimeFromBeat((i-1)*4)

						x = scale(t,  0, LastSecond, 0, _w)
						y = round(-1 * scale(nps, 0, PeakNPS, 0, _h))

						-- if the height of this measure is the same as the previous two measures
						-- we don't need to add two more points (bottom and top) to the verts table,
						-- we can just "extend" the previous two points by updating their x position
						-- to that of the current measure.  For songs with long streams, this should
						-- cut down on the overall size of the verts table significantly.
						if #verts > 2 and verts[#verts][1][2] == y and verts[#verts-2][1][2] == y then
							verts[#verts][1][1] = x
							verts[#verts-1][1][1] = x
						else
							-- lerp_color() take a float between [0,1], color1, and color2, and returns a color
							-- that has been linearly interpolated by that percent between the colors provided
							upper = lerp_color(math.abs(y/_h), yellow, orange )

							verts[#verts+1] = {{x, 0, 0}, yellow} -- bottom of graph (yellow)
							verts[#verts+1] = {{x, y, 0}, upper}  -- top of graph (somewhere between yellow and orange)
						end
					end
				end

				actor:SetNumVertices(#verts):SetVertices(verts)
			end
		end
	}

	amv.InitCommand=function(self)
		self:SetDrawState({Mode="DrawMode_QuadStrip"})
	end
	amv.CurrentSongChangedMessageCommand=function(self)
		SongNumberInCourse = SongNumberInCourse + 1

		-- we've reached a new song, so reset the vertices for the density graph
		-- this will occur at the start of each new song in CourseMode
		-- and at the start of "normal" gameplay
		amv:Initialize(self)
	end

	return amv
end