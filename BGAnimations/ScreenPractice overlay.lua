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

local players = GAMESTATE:GetHumanPlayers()
local Is43 = (GetScreenAspectRatio() <= 1.4)
local style = GAMESTATE:GetCurrentStyle():GetName()

-- The following code handles positioning the NPS Graph within practice mode.
local width = _screen.h - 100
local height = 50
local y_pos = 80

-- Positioning for most aspect ratios
local x_pos = GetNotefieldWidth() / 1.30
if style ~= "versus" and style ~= "single" then
	x_pos = (GetNotefieldWidth() / 2.2)
end


-- Positioning for 4:3
if Is43 then
	height = 25
	x_pos = (GetNotefieldWidth() / 1.50) - 1
	if style ~= "versus" and style ~= "single" then
		width = _screen.h - 200
		x_pos = (GetNotefieldWidth() / 2.7)
		y_pos = 180
	end
end

-- Set our offset from the middle of the screen, and account for the height of the grpah
x_pos = x_pos + (_screen.w / 2.0) - height

local nps_graph_drawn = false

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

	if not nps_graph_drawn then
		t[#t+1] = NPS_Histogram_With_Position_Line(player, width, height) .. {
			OnCommand=function(self)
				self:queuecommand("Redraw")
				-- Positioned to the right of the notefield, rotated vertically.
				self:xy(x_pos, y_pos)
				self:rotationz(90)
			end,
			ShowCommand=function(self)
				self:queuecommand("ScrollSong")
				self:visible(true)
			end,
			PlayingCommand=function(self) self:visible(false) end,
		}
	end
	nps_graph_drawn = true
end

return t