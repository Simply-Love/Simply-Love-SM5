local map_data = ...

local af = Def.ActorFrame{
	Name="ParallaxAF",
	InitCommand=function(self) self:hibernate(13) end,
}

for map_index,map in ipairs(map_data) do
	for layer_index,layer in ipairs(map.layers) do
		if layer.name == "Parallax" then
			for obj_index, obj in ipairs(layer.objects) do

				af[#af+1] = LoadActor(obj.properties.Texture)..{
					Name="Parallax"..map_index,
					InitCommand=function(self)
						self:diffusealpha(obj.properties.alpha or 1)
							:xy(obj.x, obj.y)
							:z(layer_index)
							:align(0,0)
							:setsize( _screen.w, _screen.h )
							-- :visible(false)
					end,
					HideCommand=function(self) self:visible(false) end
				}
			end
		end
	end
end

return af