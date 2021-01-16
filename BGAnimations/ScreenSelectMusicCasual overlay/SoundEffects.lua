local af = Def.ActorFrame{}
af.PlaySFXMessageCommand=function(self, params)
	local actor = self:GetChild(params.Action)
	if actor then
		if params.Player then
			actor:playforplayer(params.Player)
		else
			actor:play()
		end
	end
end

-- when a Sound's IsAction attribute is true, machine operators can mute that sound
-- by setting MuteActions=1 in Preferences.ini (F3+A to quickly toggle)
af[#af+1] = Def.Sound{ Name="ChangeGroup", IsAction=true, File=THEME:GetPathS("ScreenSelectMaster", "change") }
af[#af+1] = Def.Sound{ Name="ChangeSong",  IsAction=true, File=THEME:GetPathS("MusicWheel", "change") }
af[#af+1] = Def.Sound{ Name="Start",       IsAction=true, File=THEME:GetPathS("Common", "Start") }

return af