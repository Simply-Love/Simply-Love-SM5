-- don't bother showing the song length in Casual mode
if SL.Global.GameMode == "Casual" then return end

return Def.ActorFrame{
	InitCommand=function(self) 
		self:xy(_screen.cx, 175) 
	end,
	-- text for Song Length
	LoadFont("Common Normal")..{
		InitCommand=function(self) 
			self:zoom(0.6):maxwidth(418/0.875):x(145):horizalign("right") 
		end,
		OnCommand=function(self)
			local seconds
			if not GAMESTATE:IsCourseMode() then
				seconds = GAMESTATE:GetCurrentSong():MusicLengthSeconds()
			else
				local trail = GAMESTATE:GetCurrentTrail(GAMESTATE:GetMasterPlayerNumber())
				if trail then
					seconds = TrailUtil.GetTotalSeconds(trail)
				end
			end
			if seconds then
				seconds = seconds / SL.Global.ActiveModifiers.MusicRate
				-- longer than 1 hour in length
				if seconds > 3600 then
					-- format to display as H:MM:SS
					self:settext(math.floor(seconds/3600) .. ":" .. SecondsToMMSS(seconds%3600))
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