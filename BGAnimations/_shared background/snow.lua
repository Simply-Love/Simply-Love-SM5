-- THE BEST WAY TO SPREAD HOLIDAY CHEER IS SINGING LOUD FOR ALL TO HEAR

-- -----------------------------------
-- variables you might want to configure to your liking

local num_particles = 200
-- particle size in pixels
local min_size = 12
local max_size = 35
-- particle velocity in pixels per second
local min_vx = -7
local max_vx = 7
local min_vy = 55
local max_vy = 85
-- try to keep it SFW
local path_to_texture = THEME:GetPathB("","_shared background/snowflake.png")

-----------------
-- Taro wrote the original version of this code, quietly-turning made it worse from there

-- how far offscreen should it be before it wraps
local wrap_buffer = 50

-- we will need these later
local particles = {}

local Update = function(self, delta)

	for i=1,#particles do
		local a = particles[i]

		if a then
			local b = a.actor
			if b then
				-- each sprite will have an aux of 0 by default
				if b:getaux() < 1 then
					-- increment this sprite's aux by delta (presumably some small value)
					b:aux( b:getaux() + delta )
					-- and use the result to increase this sprite's alpha until it is 1
					b:diffusealpha( b:getaux() )
				end

				b:addx( a.xspd*delta )
				b:addy( a.yspd*delta )

				if b:GetY() > (_screen.h + wrap_buffer) then
					b:y( (-wrap_buffer*2) )
				end
				if b:GetX() < 0 then
					b:x( math.random( -40, math.floor(_screen.w)+40 )  )
				end
			end
		end
	end
end

local af = Def.ActorFrame{
	InitCommand=function(self) self:SetUpdateFunction( Update ) end
}

-- background Quad with a black-to-blue gradient
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:FullScreen():Center():diffusetopedge(Color.Black):diffusebottomedge(color("#061f4f")) end
}

for i=1,num_particles do
	af[#af+1] = Def.Sprite{
		Texture=path_to_texture,
		InitCommand=function(self)

			-- initialize this particle's x-speed, y-speed, and size now
			-- store this in the particles tables for retrieval within Update()
			local _t = {
				actor = self,
				xspd = math.random( min_vx, max_vx ),
				yspd = math.random( min_vy, max_vy ),
				size = math.random( min_size,max_size)+(i/#particles),
			}

			table.insert( particles, _t )

			self:diffusealpha(0)
			self:x( math.random( -40, math.floor(_screen.w)+40 ) )
			self:y( math.random( -40, math.floor(_screen.h)+40 ) )
			self:zoomto( _t.size, _t.size )

			if ThemePrefs.Get("RainbowMode") then self:effectoffset( math.random() ):rainbow() end
		end
	}
end

return af