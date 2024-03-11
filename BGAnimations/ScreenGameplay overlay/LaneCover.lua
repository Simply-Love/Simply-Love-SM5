local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local playeroptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

local filter = Def.Quad{
    InitCommand=function(self)
        local headerHeight = 80
        local percentage = mods.LaneCover:gsub("%%","") / 100

        local halfScreen = SCREEN_CENTER_X
        local quarterScreen = halfScreen / 2

        -- P1 notefield is at 25% and P2 notefield is at 75% X-position and moved from there
        local playerNotefieldPosition = player == PLAYER_1 and quarterScreen or halfScreen + quarterScreen
        local adjusted_offset_x = mods.NoteFieldOffsetX * (player == PLAYER_1 and -1 or 1)

		self:diffuse(Color.Black)
		    :addx(playerNotefieldPosition + adjusted_offset_x)
			:y(_screen.cy + (headerHeight / 2))
            :zoomto(GetNotefieldWidth(player), _screen.h - headerHeight)

        if (playeroptions:UsingReverse()) then
            self:cropbottom(1 - percentage)
        else
            self:croptop(1 - percentage)
        end
    end,
}

return filter