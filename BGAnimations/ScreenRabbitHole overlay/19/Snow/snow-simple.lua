local args = ...
local g = args[1]
local map_data = args[2][1]

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

local path_to_texture = THEME:GetPathB("ScreenRabbitHole", "overlay/19/Snow/snowflake.png")

-----------------
-- taro

local SNOW_MAX_TIME = 120
local SNOW_BEGIN_TIME = 15
local wrap_buffer = 100 --how far offscreen should it be before it wraps
local snow_growth = 32 --how much larger is the biggest snowflake (towards the end of the file) than the smallest one
local speed_increase = 15 --how much faster the snow is falling at the end vs the start
local sine_amount = 20 --strength of sine effect

-- snow amount should be slightly exponential
local inCubic = function(t, b, c, d)
	t = t / d
	return c * math.pow(t, 3) + b
end

local inQuad = function(t, b, c, d)
	t = t / d
	return c * math.pow(t, 2) + b
end

--we will need these later
local dbk_snow = {} --recycling is good for the environment
local dbk_sptr = 0 --it's a ''''pointer'''' to a snow object

local make_snow = function(obj)
    table.insert( dbk_snow, {actor = obj, xspd = 0, yspd = 0, size = 0, active = false} ) --shovel snow
end

local af = Def.ActorFrame{
	OnCommand=function(self)

		self:sleep(0.02):queuecommand("Make");

	end,
	MakeCommand=function(self)
		for i=1,table.getn(dbk_snow) do
			local a = dbk_snow[i]
			if a then
				a.active = false
				a.xspd = math.random( min_vx, max_vx )
				a.yspd = math.random( min_vy, max_vy )

				a.size = math.random(min_size,max_size)+(snow_growth*(i/table.getn(dbk_snow))) --configurable at top of file

				local b = a.actor
				if b then
					b:x( math.random( -40, math.floor(_screen.w)+40 ) )
					b:y( math.random( -40, math.floor(_screen.h)+40 ) )

					b:zoomto( a.size, a.size )

				end
			end
		end
	end,
	UpdateAMVCommand=function(self, params)

		local delta = params[1]

		local activepercent = math.min( math.max( (g.RunTime()-SNOW_BEGIN_TIME)/(SNOW_MAX_TIME-SNOW_BEGIN_TIME), 0 ), 1 )

		--Trace( g.RunTime() ..' ' ..activepercent )

		for i=1,table.getn(dbk_snow) do
			local a = dbk_snow[i]
			if a then
				if i < (0.01+0.99*inCubic(activepercent,0,1,1))*table.getn(dbk_snow) then
					a.active = true
				end
			end
			if a and a.active then
				local b = a.actor
				if b then

					b:visible(true)
					if b:getaux() < 1 then
						b:aux( b:getaux() + delta )
						b:diffusealpha( b:getaux() )
					end

					b:addx( (a.size/25)*(a.xspd*delta)*(1 - activepercent*0.5) - (a.size/25)*(speed_increase/2)*activepercent*delta )
					b:addy( a.yspd*delta*( 1 + activepercent*(speed_increase/100) ) + speed_increase*activepercent*delta )

					b:addx( (a.size/25)*(sine_amount*(1-0.25*activepercent))*math.sin( g.RunTime()*6 + i*12.345 )*delta ) --some sine motion that lessens as the snow falls more intensely

					if b:GetY() < -g.map.af:GetY() - wrap_buffer then
						b:addy( (_screen.h + wrap_buffer*2) )
					elseif b:GetY() > -g.map.af:GetY() + _screen.h + wrap_buffer then
						b:addy( -(_screen.h + wrap_buffer*2) )
					end

					if b:GetX() < -g.map.af:GetX() - wrap_buffer then
						b:addx( (_screen.w + wrap_buffer*2) )
					elseif b:GetX() > -g.map.af:GetX() + _screen.w + wrap_buffer then
						b:addx( -(_screen.w + wrap_buffer*2) )
					end

				end
			end
		end

	end
}

for i=1,num_particles do
    af[#af+1] = LoadActor( path_to_texture )..{
        OnCommand=function(self) self:visible(false):queuecommand("Make") end,
        HideCommand=function(self) self:visible(false) end,
        MakeCommand=function(self) make_snow(self) end --use our function from earlier!
    }
end

return af