local t = Def.ActorFrame{
	Name="Text",
	OnCommand=function(self) self:queuecommand("Show") end,
	EditCommand=function(self) self:playcommand("Show") end,

	PlayingCommand=function(self) self:playcommand("Hide") end,
	RecordCommand=function(self) self:playcommand("Hide") end,
	RecordPausedCommand=function(self) self:playcommand("Hide") end,

	-- Info
	Def.ActorFrame{
		InitCommand=function(self) self:xy(_screen.w, 10) end,
		ShowCommand=function(self) self:visible(true) end,
		HideCommand=function(self) self:visible(false) end,

		Def.Quad{ InitCommand=function(self) self:zoomto(30,1):horizalign(right) end },

		LoadFont("Common Bold") .. {
			Name="InfoText",
			Text="PRACTICE MODE",
			InitCommand=function(self) self:zoom(0.265):horizalign(right):x(-35):diffuse(PlayerColor(PLAYER_1)) end,
		}
	}
}

local players =  GAMESTATE:GetHumanPlayers()
for player in ivalues(players) do
	local backgroundFilter = LoadActor("ScreenGameplay underlay/PerPlayer/BackgroundFilter.lua", player)

	if backgroundFilter then
		t[#t+1] = backgroundFilter..{
			ShowCommand=function(self) self:visible(false) end,
			PlayingCommand=function(self) self:visible(true) end
		}
	end

	t[#t+1] = LoadActor("ScreenGameplay underlay/PerPlayer/NoteField/default.lua", player)..{
		ShowCommand=function(self) self:visible(false) end,
		PlayingCommand=function(self) self:visible(true) end,
	}

	t[#t+1] = Def.ActorProxy{
		Name="NoteFieldContainer"..ToEnumShortString(player),
		OnCommand=function(self)
			self:SetTarget(GetPlayerAF(ToEnumShortString(player)))
		end,
		ShowCommand=function(self) self:visible(false) end,
		PlayingCommand=function(self) self:visible(true) end,
	}
end

return t