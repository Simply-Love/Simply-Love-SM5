-- don't bother showing the bpm and music rate in Casual mode
if SL.Global.GameMode == "Casual" then return end

return Def.ActorFrame{
	InitCommand=function(self) self:xy(_screen.cx, 175) end,

	--quad behind the MusicRate text
	Def.Quad{
		InitCommand=function(self) self:diffuse( color("#1E282F") ):setsize(418,16):zoom(0.7) end,
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
	}
}