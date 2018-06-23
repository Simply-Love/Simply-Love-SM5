local Player = ...
local pn = ToEnumShortString(Player)
local CanEnterName = SL[pn].HighScores.EnteringName

if CanEnterName then
	SL[pn].HighScores.Name = ""
end

if PROFILEMAN:IsPersistentProfile(Player) then
	SL[pn].HighScores.Name = PROFILEMAN:GetProfile(Player):GetLastUsedHighScoreName()
end

local t = Def.ActorFrame{
	Name="PlayerNameAndDecorations_"..pn,
	InitCommand=function(self)
		if Player == PLAYER_1 then
			self:x(_screen.cx-160)
		elseif Player == PLAYER_2 then
			self:x(_screen.cx+160)
		end
		self:y(_screen.cy-20)
	end,


	-- the quad behind the playerName
	Def.Quad{
		InitCommand=cmd(diffuse,color("0,0,0,0.75"); zoomto, 300, _screen.h/7),
	},

	-- the quad behind the scrolling alphabet
	Def.Quad{
		InitCommand=cmd(diffuse,color("0,0,0,0.5"); zoomto, 300, _screen.h/10),
		OnCommand=cmd(y, 58)
	},

	-- the quad behind the highscore list
	Def.Quad{
		InitCommand=cmd(diffuse,color("0,0,0,0.25"); zoomto, 300, _screen.h/4),
		OnCommand=cmd(y,142)
	}
}


t[#t+1] = LoadActor("Cursor.png")..{
	Name="Cursor",
	InitCommand=cmd(diffuse,PlayerColor(Player); zoom,0.5;),
	OnCommand=function(self)
		self:visible( CanEnterName )
		self:y(58)
	end,
	HideCommand=cmd(linear, 0.25; diffusealpha, 0)
}

t[#t+1] = LoadFont("_wendy white")..{
	Name="PlayerName",
	InitCommand=cmd(zoom,0.75; halign,0; xy,-80,0;),
	OnCommand=function(self)
		self:visible( CanEnterName )
		self:settext( SL[pn].HighScores.Name or "" )
	end,
	SetCommand=function(self)
		self:settext( SL[pn].HighScores.Name or "" )
	end
}

t[#t+1] = LoadFont("_wendy small")..{
	Text=ScreenString("OutOfRanking"),
	OnCommand=cmd(zoom,0.7; diffuse,PlayerColor(Player); y, 58; visible, not CanEnterName)
}

return t
