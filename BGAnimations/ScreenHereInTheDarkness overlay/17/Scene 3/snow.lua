local num_particles = 250
-- particle size in pixels
local min_size = 12
local max_size = 25
-- particle velocity in pixels per second
local min_vx = -7
local max_vx = 7
local min_vy = 75
local max_vy = 105
--how far offscreen should it be before it wraps
local wrap_buffer = 50
-- try to keep it SFW
local path_to_texture = "./snowflake.png"
-----------------

local snowflakes = {}

local make_snow = function(obj)
    table.insert( snowflakes, {actor = obj, xspd = 0, yspd = 0, size = 0} )
end

local Update = function(self, delta)
	for i=1,#snowflakes do
		local a = snowflakes[i]

		if a then
			local b = a.actor
			if b then

				b:visible(true)
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
	InitCommand=function(self) self:SetUpdateFunction( Update ) end,
	OnCommand=function(self) self:sleep(0.02):queuecommand("Make") end,
	MakeCommand=function(self)
		for i=1,#snowflakes do
			local a = snowflakes[i]
			if a then
				a.xspd = math.random( min_vx, max_vx )
				a.yspd = math.random( min_vy, max_vy )
				a.size = math.random(min_size,max_size)+(i/#snowflakes) --configurable at top of file

				local b = a.actor
				if b then
					b:x( math.random( -40, math.floor(_screen.w)+40 ) )
					b:y( math.random( -40, math.floor(_screen.h)+40 ) )
					b:zoomto( a.size, a.size )
				end
			end
		end
	end
}

-- background Quad with a black-to-blue gradient
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:FullScreen():Center():diffusetopedge(Color.Black):diffusebottomedge(color("#061f4f")) end
}

for i=1,num_particles do
    af[#af+1] = LoadActor( path_to_texture )..{
        OnCommand=function(self) self:visible(false):queuecommand("Make") end,
        HideCommand=function(self) self:visible(false) end,
        MakeCommand=function(self) make_snow(self) end
    }
end

return af