-- don't bother showing the bpm and music rate in Casual mode
if SL.Global.GameMode == "Casual" then return end

return Def.ActorFrame{
	InitCommand=function(self) self:xy(_screen.cx, 175) end,

	--quad behind the MusicRate text
	Def.Quad{
		InitCommand=function(self) 
			self:diffuse( color("#1E282F") ):setsize(418,16):zoom(0.7)
			if ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0.5)
			end
		end,
	},

	-- text for BPM (and maybe music rate if ~= 1.0)
	LoadFont("Common Normal")..{
		InitCommand=function(self) self:zoom(0.6):maxwidth(418/0.875) end,
		OnCommand=function(self)
			-- FIXME: the current layout of ScreenEvaluation doesn't accommodate split BPMs
			--        so this currently uses the MasterPlayer's BPM values
			local bpms = StringifyDisplayBPMs()
			local MusicRate = SL.Global.ActiveModifiers.MusicRate
			if  MusicRate ~= 1 then
				-- format a string like "150 - 300 bpm (1.5x Music Rate)"
				self:settext( ("%s bpm (%gx %s)"):format(bpms, MusicRate, THEME:GetString("OptionTitles", "MusicRate")) )
			else
				-- format a string like "100 - 200 bpm"
				self:settext( ("%s bpm"):format(bpms))
			end
		end
	},

	-- text for Song Length
	LoadFont("Common Normal")..{
		InitCommand=function(self) self:zoom(0.6):maxwidth(418/0.875):x(145):horizalign("right") end,
		OnCommand=function(self)
			local seconds = nil
			if GAMESTATE:IsCourseMode() then
				local trail = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber())
				if trail then
					seconds = TrailUtil.GetTotalSeconds(trail)
				end
			else
				seconds = GAMESTATE:GetCurrentSong():MusicLengthSeconds()
			end

			if seconds then
				seconds = seconds / SL.Global.ActiveModifiers.MusicRate
				-- longer than 1 hour in length
				if seconds > 3600 then
					-- format to display as H:MM:SS
					self:settext(math.floor(seconds / 3600) .. ":" .. SecondsToMMSS(seconds % 3600))
				else
					-- format to display as M:SS
					self:settext(SecondsToMSS(seconds))
				end
			else
				self:settext("")
			end
		end
	}
}