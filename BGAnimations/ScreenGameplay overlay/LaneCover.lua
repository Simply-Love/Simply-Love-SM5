local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local playeroptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

local filter = Def.Quad{
    InitCommand=function(self)
        local headerHeight = 80
        local percentage = mods.LaneCover:gsub("%%","") / 100

		self:diffuse(Color.Black)
			:xy(GetNotefieldX(player), _screen.cy + (headerHeight / 2))
            :zoomto(GetNotefieldWidth(player), _screen.h - headerHeight)

        if (playeroptions:UsingReverse()) then
            self:cropbottom(1 - percentage)
        else
            self:croptop(1 - percentage)
        end
    end,
}

return filter