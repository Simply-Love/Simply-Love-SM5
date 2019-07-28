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
			if SL.Global.ActiveModifiers.MusicRate ~= 1 then
				self:settext( ("%g"):format(SL.Global.ActiveModifiers.MusicRate) .. "x " .. THEME:GetString("OptionTitles", "MusicRate") )
			end

			local bpm = GetDisplayBPMs()
			if bpm then
				self:settext(self:GetText() .. " (" .. bpm .. " BPM)" )
			end
		end
	}
}