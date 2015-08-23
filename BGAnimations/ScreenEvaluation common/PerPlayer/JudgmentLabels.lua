local pn = ...

-- tap note types
-- Iterating through the enum isn't worthwhile because the sequencing is so bizarre...
local TNSNames = {
	THEME:GetString("TapNoteScore","W1"),
	THEME:GetString("TapNoteScore","W2"),
	THEME:GetString("TapNoteScore","W3"),
	THEME:GetString("TapNoteScore","W4"),
	THEME:GetString("TapNoteScore","W5"),
	THEME:GetString("TapNoteScore","Miss")
}
local RadarCategories = {
	THEME:GetString("ScreenEvaluation", 'Holds'),
	THEME:GetString("ScreenEvaluation", 'Mines'),
	THEME:GetString("ScreenEvaluation", 'Hands'),
	THEME:GetString("ScreenEvaluation", 'Rolls')
}


local t = Def.ActorFrame{
	InitCommand=cmd(xy, 50, _screen.cy-24),
	OnCommand=function(self)
		if pn == PLAYER_2 then
			self:x( self:GetX() * -1)
		end
	end
}


--  labels: W1 ---> Miss
for index, label in ipairs(TNSNames) do
	t[#t+1] = LoadFont("_miso")..{
		Text=label:upper(),
		InitCommand=cmd(zoom,0.833; horizalign,right ),
		BeginCommand=function(self)
			self:x( (pn == PLAYER_1 and 24) or -26 )
			self:y((index-1)*28 -16)
		end
	}
end

-- labels: holds, mines, hands, rolls
for index, label in ipairs(RadarCategories) do
	t[#t+1] = LoadFont("_miso")..{
		Text=label,
		InitCommand=cmd(NoStroke;zoom,0.833; horizalign,right ),
		BeginCommand=function(self)
			self:x( (pn == PLAYER_1 and -160) or 90 )
			self:y((index-1)*28 + 41)
		end
	}
end

return t