local args = ...
local g = args[1]
local map_data = args[2]
local layer_data = args[3]
local layer_index = args[4]
local map_index = args[5]


local SleepDuration = g.SleepDuration

local pos = { x=nil, y=nil }

local player = {
	file = "Elli 4x4 (doubleres).png",
	dir = "Down",
	tweening = false,

	input = {
		Active = nil,
		Up = false,
		Down = false,
		Left = false,
		Right = false,
		MenuRight = false,
		MenuLeft = false,
		Start = false,
		Select = false
	},

	NextTile = {
		Up=function() return (pos.y-1) * map_data.width + pos.x + 1 end,
		Down=function() return (pos.y+1) * map_data.width + pos.x + 1 end,
		Left=function() return pos.y * map_data.width + pos.x end,
		Right=function() return pos.y * map_data.width + pos.x + 2 end
	},
}

local WillBeOffMap = {
	Up=function() return pos.y < 1 end,
	Down=function() return pos.y > map_data.height-2 end,
	Left=function() return pos.x < 1 end,
	Right=function() return pos.x > map_data.width-2 end
}

local UpdatePosition = function()
	-- Increment/Decrement the value as needed first
	if g.Player[map_index].dir == "Up" then
		pos.y = pos.y - 1

	elseif g.Player[map_index].dir == "Down" then
		pos.y = pos.y + 1

	elseif g.Player[map_index].dir == "Left" then
		pos.x = pos.x - 1

	elseif g.Player[map_index].dir == "Right" then
		pos.x = pos.x + 1
	end
end


local WillCollide = function()
	local next_tile = g.Player[map_index].NextTile[g.Player[map_index].dir]()

	if next_tile then
		if g.collision_layer[map_index].data[ next_tile ] ~= 0 then
			return true
		else
			g.TouchHandler( next_tile )
			return false
		end
	end

	return false
end


local frames = {
	Down = {
		{ Frame=1,	Delay=SleepDuration/1.5},
		{ Frame=2,	Delay=SleepDuration/1.5},
		{ Frame=3,	Delay=SleepDuration/1.5},
		{ Frame=0,	Delay=SleepDuration/1.5}
	},
	Left = {
		{ Frame=5,	Delay=SleepDuration/1.5},
		{ Frame=6,	Delay=SleepDuration/1.5},
		{ Frame=7,	Delay=SleepDuration/1.5},
		{ Frame=4,	Delay=SleepDuration/1.5}
	},
	Right = {
		{ Frame=9,	Delay=SleepDuration/1.5},
		{ Frame=10,	Delay=SleepDuration/1.5},
		{ Frame=11,	Delay=SleepDuration/1.5},
		{ Frame=8,	Delay=SleepDuration/1.5}
	},
	Up = {
		{ Frame=13,	Delay=SleepDuration/1.5},
		{ Frame=14,	Delay=SleepDuration/1.5},
		{ Frame=15,	Delay=SleepDuration/1.5},
		{ Frame=12,	Delay=SleepDuration/1.5}
	}
}

-- a sprite for the player
return LoadActor( "./" .. player.file )..{
	InitCommand=function(self, event)

		player.actor = self

		if event.x and event.y then
			pos.x = event.x
			pos.y = event.y
		else
			pos.x = layer_data.objects[1].x/map_data.tilewidth
			pos.y = layer_data.objects[1].y/map_data.tileheight
		end

		player.pos = pos
		g.Player[map_index] = player

		self:animate(false)
		-- align to left and v-middle
			:align(0.1, 0.5)
		-- initialize the position
			:xy(pos.x*map_data.tilewidth, pos.y*map_data.tileheight)
			:z( layer_index )
		-- initialize the sprite state
			:SetStateProperties( frames[player.dir] )
			:setstate(1)
			:SetTextureFiltering(false)
			:zoom(0.9)
	end,
	UpdateSpriteFramesCommand=function(self)
		if player.dir then
			self:SetStateProperties( frames[player.dir] )
		end
	end,
	AnimationOnCommand=function(self)
		self:animate(true)
	end,
	AnimationOffCommand=function(self)
		self:animate(false):setstate(1)
	end,
	TweenCommand=function(self)

		if g.DialogIsActive then
			self:playcommand("AnimationOff")
			return
		end

		-- collision check the impending tile
		if not g.InputIsLocked and not WillCollide() and not WillBeOffMap[player.dir]() then

			-- this does a good job of mitigating tween overflows resulting from button mashing
			-- self:stoptweening()
			player.tweening = true

			-- we *probably* want to update the player's map position
			-- UpdatePosition() does just that, if we should
			UpdatePosition()

			-- tween the map
			self:GetParent():GetParent():playcommand("TweenMap")

			self:playcommand("AnimationOn")
				:linear(SleepDuration)
				:x(pos.x * map_data.tilewidth)
				:y(pos.y * map_data.tileheight)

			self:queuecommand("MaybeTweenAgain")
		end
	end,
	MaybeTweenAgainCommand=function(self)
		player.tweening = false

		if player.dir and player.input[ player.dir ] then
			self:playcommand("Tween")
		else
			self:stoptweening():queuecommand("AnimationOff")
		end
	end,
	AttemptToTweenCommand=function(self, params)

		-- Does the player sprite's current direction match the direction
		-- we were just passed from the input handler?
		if player.dir ~= params.dir then

			-- if not, update it
			player.dir = params.dir
			-- and update the sprite's frames appropriately
			self:queuecommand("UpdateSpriteFrames")
		end

		-- don't allow us to go off the map
		if player.dir and player.input[ player.dir ] and not player.tweening then

			self:playcommand("AnimationOn")

			-- tween the player sprite
			self:playcommand("Tween")
		end
	end
}