return Def.ActorFrame{
	-- don't bother drawing the ActorFrame if MusicRate==1
	InitCommand=function(self)
		self:visible(SL.Global.ActiveModifiers.MusicRate ~= 1)
			:xy(_screen.cx, 172):zoom(0.7)
	end,

	--quad behind the MusicRate text
	Def.Quad{
		InitCommand=function(self) self:diffuse( color("#1E282FCC") ):zoomto(418,20) end,
	},

	--the MusicRate text
	LoadFont("_miso")..{
		InitCommand=function(self) self:shadowlength(1) end,
		OnCommand=function(self)
			self:settext( ("%g"):format(SL.Global.ActiveModifiers.MusicRate) .. "x " .. THEME:GetString("OptionTitles", "MusicRate") )

			local bpm = GetDisplayBPMs()
			if bpm then
				self:settext(self:GetText() .. " (" .. bpm .. " BPM)" )
			end
		end
	}
}