return Def.Quad{
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0) end,
	OnCommand=function(self) self:sleep(0.5):linear(1):diffusealpha(1) end,
	OffCommand=function(self)
		if SL.Global.GameMode == "ITG" then
			for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
				local pn = ToEnumShortString(player)
				local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
				local number = pss:GetTapNoteScores("TapNoteScore_W1")
				local faPlus = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts.W0_total
				-- Subtract FA+ count from the overall fantastic window count.
				whites = number - faPlus
				-- This will save the white count to Stats.xml, so we can later recover
				-- it when we deprecate FA+ mode and introduce W0.
				--
				-- The Score field is completely unused in Simply Love, and the ability
				-- to set the field is exposed to lua so we can hijack it for our own\
				-- purposes.
				--
				-- TODO(teejusb): Remove once we have W0 support in ITGmania.
				pss:SetScore(whites)
			end
		end
	end
}