return Def.ActorFrame{

	--quad behind the ratemod, if there is one
	Def.Quad{
		InitCommand=cmd(diffuse,color("#1E282FCC"); xy,_screen.cx, 172; zoomto, 292.5,14 ),
		OnCommand=function(self)
			local MusicRate = SL.Global.ActiveModifiers.MusicRate
			if MusicRate == 1 then
				self:visible(false)
			end
		end
	},

	--the ratemod, if there is one
	LoadFont("_miso")..{
		InitCommand=cmd(xy,_screen.cx, 173; shadowlength,1; zoom, 0.7),
		OnCommand=function(self)
			-- what was the MusicRate for this song?
			local MusicRate = SL.Global.ActiveModifiers.MusicRate

			-- Store the MusicRate for later retrieval on ScreenEvaluationSummary
			SL.Global.Stages.MusicRate[SL.Global.Stages.PlayedThisGame + 1] = MusicRate

			local bpm = GetDisplayBPMs()

			if MusicRate ~= 1 then
				self:settext(("%g"):format(MusicRate) .. " Music Rate")

				if bpm then

					--if there is a range of BPMs
					if string.match(bpm, "%-") then
						local bpms = {}
						for i in string.gmatch(bpm, "%d+") do
							bpms[#bpms+1] = round(tonumber(i) * MusicRate)
						end
						if bpms[1] and bpms[2] then
							bpm = bpms[1] .. "-" .. bpms[2]
						end
					else
						bpm = tonumber(bpm) * MusicRate
					end

					self:settext(self:GetText() .. " (" .. bpm .. " BPM)" )
				end
			else
				-- else MusicRate was 1.0
				self:settext("")
			end
		end
	}
}