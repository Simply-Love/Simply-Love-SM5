-- THE BEST WAY TO SPREAD HOLIDAY CHEER IS SINGING LOUD FOR ALL TO HEAR

-- -----------------------------------
-- variables you might want to configure to your liking

-- starting values (these can be manipulated later as needed)
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
-- Taro wrote the original version of this code, dbk2 h*cked it up from there

local wrap_buffer = 50 --how far offscreen should it be before it wraps

--we will need these later
local dbk_snow = {} --recycling is good for the environment

local Update = function(self, delta)

	for i=1,#dbk_snow do
		local a = dbk_snow[i]

		if a then
			local b = a.actor
			if b then

				if b:getaux() < 1 then
					b:aux( b:getaux() + delta )
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

local snow_af = Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0) end,
	OnCommand=function(self) self:smooth(0.333):diffusealpha(1) end
}

for i=1,num_particles do
	snow_af[#snow_af+1] = LoadActor( path_to_texture )..{
		OnCommand=function(self) self:queuecommand("Make") end,
		MakeCommand=function(self)
			local _t = {
				actor = self,
				xspd = math.random( min_vx, max_vx ),
				yspd = math.random( min_vy, max_vy ),
				size = math.random( min_size,max_size)+(i/#dbk_snow),
			}

			table.insert( dbk_snow, _t )

			self:x( math.random( -40, math.floor(_screen.w)+40 ) )
			self:y( math.random( -40, math.floor(_screen.h)+40 ) )
			self:zoomto( _t.size, _t.size )

			if ThemePrefs.Get("VisualTheme") == "Gay" then self:effectoffset( math.random() ):rainbow() end
		end
	}
end

af[#af+1] = snow_af

return af