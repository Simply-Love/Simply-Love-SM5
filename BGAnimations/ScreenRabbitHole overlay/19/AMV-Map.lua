local args = ...
local g = args[1]
local map_data = args[2]
local map_index = args[3]

g.Events[map_index] = {}


-- returns a table of two values, right and down, both in tile units
local FindCenterOfMap = function()

	-- calculate which tile currently represents the center of what is currently
	-- displayed in the window in terms of tiles right and tiles down from top-left
	local MapCenter = {right=g.Player[g.CurrentMap].pos.x,  down=g.Player[g.CurrentMap].pos.y}

	-- half screen width in tile units
	local half_screen_width_in_tiles  = (_screen.w/(map_data.tilewidth*g.map.zoom))/2
	-- half screen height in tile units
	local half_screen_height_in_tiles = (_screen.h/(map_data.tileheight*g.map.zoom))/2

	-- if players are near the edge of a map, using the MapCenter, this will result
	-- in the map scrolling "too far" and the player seeing beyond the edge of the map
	-- clamp the MapCenter values here to prevent this from occuring

	-- left edge of map
	if (MapCenter.right < half_screen_width_in_tiles) then MapCenter.right = half_screen_width_in_tiles end
	-- right edge of map
	if (MapCenter.right > map_data.width - half_screen_width_in_tiles) then MapCenter.right = map_data.width - half_screen_width_in_tiles end
	-- top edge of map
	if (MapCenter.down < half_screen_height_in_tiles) then MapCenter.down = half_screen_height_in_tiles end
	-- bottom edge of map
	if (MapCenter.down > map_data.height - half_screen_height_in_tiles) then MapCenter.down = map_data.height - half_screen_height_in_tiles end

	return MapCenter
end

local GetVerts = function(layer, tileset, tilewidth, tileheight, mapwidth, mapheight)

	local rows = tileset.imageheight/tileset.tileheight

	-- vert data for a single AMV, where 1 tilelayer = 1 AMV
	local verts = {}

	-- color, to be reused
	local c = {1,1,1,1}

	for i=0,#layer.data-1 do

		local tile_id = layer.data[i+1]-1

		if (tile_id ~= -1) then
			-- position
			local p = {
				-- x, y, z
				{ (i%mapwidth)*tilewidth,			math.floor(i/mapwidth)*tileheight, 				1 },
				{ (i%mapwidth)*tilewidth+tilewidth, math.floor(i/mapwidth)*tileheight, 				1 },
				{ (i%mapwidth)*tilewidth+tilewidth, math.floor(i/mapwidth)*tileheight+tileheight,	1 },
				{ (i%mapwidth)*tilewidth, 			math.floor(i/mapwidth)*tileheight+tileheight, 	1 }
			}

			-- texture coordinates
			local t = {
				-- tx, ty
				{scale(((tile_id%tileset.columns)+0)*tilewidth, 0, tileset.imagewidth, 0, 1),	scale((math.floor(tile_id/tileset.columns)+0)*tileheight, 0, tileset.imageheight, 0, 1) },
				{scale(((tile_id%tileset.columns)+1)*tilewidth, 0, tileset.imagewidth, 0, 1),	scale((math.floor(tile_id/tileset.columns)+0)*tileheight, 0, tileset.imageheight, 0, 1) },
				{scale(((tile_id%tileset.columns)+1)*tilewidth, 0, tileset.imagewidth, 0, 1),	scale((math.floor(tile_id/tileset.columns)+1)*tileheight, 0, tileset.imageheight, 0, 1) },
				{scale(((tile_id%tileset.columns)+0)*tilewidth, 0, tileset.imagewidth, 0, 1),	scale((math.floor(tile_id/tileset.columns)+1)*tileheight, 0, tileset.imageheight, 0, 1) },
			}

			table.insert(verts, {p[1], c, t[1]})
			table.insert(verts, {p[2], c, t[2]})
			table.insert(verts, {p[3], c, t[3]})
			table.insert(verts, {p[4], c, t[4]})
		end
	end

	return verts
end

-- -----------------------------------------------------------------------

local af = Def.ActorFrame{}

-- zoom the map and the player (but not the snow) some amount
af.InitCommand=function(self)
	self:zoom(g.map.zoom)

	-- The AMV_map will have been designed in the Tiled app to have "under" and "over" layers
	-- but the player sprite and event tiles might need to dynamically shift their sense of what
	-- draws under/over what.  We handle this by updating the z() value of the player and events to match their
	-- y() value (things further down the map draw OVER things higher up the map) and applying
	-- SetDrawByZPosition(true) to the entire ActorFrame.
	self:SetDrawByZPosition(true):visible(false)
end

af.MoveMapCommand=function(self)
	local MapCenter = FindCenterOfMap()

	local x = -(MapCenter.right * map_data.tilewidth * g.map.zoom - _screen.w/2)
	local y = -(MapCenter.down * map_data.tileheight * g.map.zoom - _screen.h/2)

	self:GetParent():xy(x,y)
end


local path_to_texture = THEME:GetPathB("ScreenRabbitHole", "overlay/19/map_data/" .. map_data.tilesets[1].image)

-- find the collision data layer now and add it to the g table
-- we'll want to refer to it from within a few different files
for layer in ivalues(map_data.layers) do
	if layer.name == "Collision" then
		g.collision_layer[map_index] = layer
		break
	end
end


-- Loop through the layers exported from the Tiled app, and add either an AMV or a Sprite for each.
-- The parent ActorFrame (af) has SetDrawByZPosition(true) set, so the sequence in which these layers are
-- added to it does not dictate their draw order.  Each layer must be assigned a z() value appropriately.
for layer_index,layer in ipairs(map_data.layers) do

	-- this is a tiled layer that must be created using an AMV
	if layer.name ~= "Collision" and layer.name ~= "Events" and layer.name ~= "Player" and layer.name ~= "Texture" and layer.name ~= "Parallax" and layer.visible then

		local verts = GetVerts(layer, map_data.tilesets[1], map_data.tilewidth, map_data.tileheight, map_data.width, map_data.height)

		-- an AMV for this layer in the map
		af[#af+1] = Def.ActorMultiVertex{
			InitCommand=function(self)
				self:SetDrawState( {Mode="DrawMode_Quads"} )
					:LoadTexture( path_to_texture )
					:SetVertices( verts )
					:SetTextureFiltering( false )
					:z(layer_index)
			end
		}

	-- for "Texture" layers, add a texture
	elseif layer.name == "Texture" then

		local obj = layer.objects[1]

		if not obj.properties.Parallax then

			af[#af+1] = LoadActor(obj.properties.Texture)..{
				InitCommand=function(self)
					self:customtexturerect(0,0,1,1)
						:texcoordvelocity(obj.properties.vx or 0,obj.properties.vy or 0)
						:diffusealpha(obj.properties.alpha or 1)
						:xy(obj.x, obj.y)
						:z(layer_index)
						:align(0,0)
						:zoomto( obj.width, obj.height )

				end
			}
		end

	elseif layer.name == "Player" then

		-- Player sprite has enough logic that it gets its own Lua file
		af[#af+1] = LoadActor("./Player/player_sprite.lua", {g, map_data, layer, layer_index, map_index})

	elseif layer.name == "Events" then

		for event in ivalues(layer.objects) do
			local tile_num

			-- if an object from Tiled has a gid, we need to subtract 1 tile unit from the y position of this event
			if event.gid then
				tile_num = ((event.y/map_data.tileheight)-1) * map_data.width + (event.x/map_data.tilewidth) + 1
			else
			-- otherwise, if the object does not have a tile associated with it...
				tile_num = ((event.y/map_data.tileheight)) * map_data.width + (event.x/map_data.tilewidth) + 1
			end

			-- set Events data
			g.Events[map_index][tile_num] = event

			if event.gid then
				af[#af+1] = Def.Sprite{
					Texture=path_to_texture,
					InitCommand=function(self)
						self:animate(false)
							:align(0,0)
							:x(event.x)
							:y(event.y-map_data.tileheight)
							:z(layer_index)
							:setstate(event.gid-1)
							:SetTextureFiltering( false )
					end,
				}
			end
		end
	end
end

return af