local args = ...
local g = args[1]
local map_data = args[2]

local Update = function(self, delta)
	g.map.af:playcommand("UpdateAMV", {delta})
end

local map_af = Def.ActorFrame{
	Name="Map ActorFrame",

	InitCommand=function(self)
		g.map.af = self

		self:GetChild("Map"..g.CurrentMap):playcommand("MoveMap")
	end,
	OnCommand=function(self)
		self:hibernate(13)
		self:GetChild("Map1"):visible(true)

		local screen = SCREENMAN:GetTopScreen()
		screen:SetUpdateFunction( Update )
		screen:AddInputCallback( LoadActor("InputHandler.lua", {map_data, g}) )
	end,
	TweenMapCommand=function(self)
		self:stoptweening():linear(g.SleepDuration):GetChild("Map"..g.CurrentMap):playcommand("MoveMap")
	end,
}

-- add maps to the map_af
for map_index,map in ipairs(map_data) do
	map_af[#map_af+1] = LoadActor("AMV-Map.lua" ,{g, map, map_index})..{ Name="Map"..map_index }
end

-- add taro snow
map_af[#map_af+1] = LoadActor("./Snow/snow-simple.lua", {g, map_data})

return map_af