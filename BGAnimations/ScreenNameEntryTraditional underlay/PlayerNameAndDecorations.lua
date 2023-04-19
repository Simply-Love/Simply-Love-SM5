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
		InitCommand=function(self) self:diffuse(0,0,0,0.75):zoomto(300, _screen.h/7) end,
	},

	-- the quad behind the scrolling alphabet
	Def.Quad{
		InitCommand=function(self) self:diffuse(0,0,0,0.5):zoomto(300, _screen.h/10) end,
		OnCommand=function(self) self:y(58) end
	},

	-- the quad behind the highscore list
	Def.Quad{
		InitCommand=function(self) self:diffuse(0,0,0,0.25):zoomto(300, _screen.h/4) end,
		OnCommand=function(self) self:y(142) end
	}
}


t[#t+1] = LoadActor("Cursor (doubleres).png")..{
	Name="Cursor",
	InitCommand=function(self) self:diffuse(PlayerColor(Player)):zoom(0.5) end,
	OnCommand=function(self) self:visible( CanEnterName ):y(58) end,
	HideCommand=function(self) self:linear(0.25):diffusealpha(0) end
}

t[#t+1] = LoadFont(ThemePrefs.Get("ThemeFont") == "Common" and "Wendy/_wendy white" or "Mega/_mega font")..{
	Name="PlayerName",
	InitCommand=function(self) self:zoom(ThemePrefs.Get("ThemeFont") == "Common" and 0.75 or 1.22):halign(0):xy(-80,0) end,
	OnCommand=function(self)
		self:visible( CanEnterName )
		self:settext( SL[pn].HighScores.Name or "" )
	end,
	SetCommand=function(self)
		self:settext( SL[pn].HighScores.Name or "" )
	end
}

t[#t+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
	Text=ScreenString("OutOfRanking"),
	OnCommand=function(self) self:zoom(0.7):diffuse(PlayerColor(Player)):y(58):visible(not CanEnterName) end
}

return t
