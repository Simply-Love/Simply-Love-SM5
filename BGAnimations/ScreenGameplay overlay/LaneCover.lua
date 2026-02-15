local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local playeroptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")
local style = GAMESTATE:GetCurrentStyle()
local styletype = style and style:GetStyleType() or nil

local filter = Def.Quad{
    InitCommand=function(self)
        local headerHeight = 80
        local percentage = mods.LaneCover:gsub("%%","") / 100

        local halfScreen = SCREEN_CENTER_X
        local quarterScreen = halfScreen / 2

        local notefieldWidth = GetNotefieldWidth(player)

        -- P1 notefield is at 25% and P2 notefield is at 75% X-position and moved from there
        local playerNotefieldPosition = player == PLAYER_1 and quarterScreen or halfScreen + quarterScreen
        local adjusted_offset_x = mods.NoteFieldOffsetX * (player == PLAYER_1 and -1 or 1)

        if styletype == "StyleType_OnePlayerTwoSides" or styletype == "StyleType_TwoPlayersSharedSides" then
           notefieldWidth = SCREEN_CENTER_X * 2
           playerNotefieldPosition = halfScreen
           adjusted_offset_x = 0
        end 

		self:diffuse(Color.Black)
		    :addx(playerNotefieldPosition + adjusted_offset_x)
			:y(_screen.cy + (headerHeight / 2))
            :zoomto(notefieldWidth, _screen.h - headerHeight)

        if (playeroptions:UsingReverse()) then
            self:cropbottom(1 - percentage)
        else
            self:croptop(1 - percentage)
        end
    end,
}

return filter
