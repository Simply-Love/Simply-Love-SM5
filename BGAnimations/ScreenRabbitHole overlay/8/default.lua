-- i like our castle

local bricks = {
	{ x=0, y=5, c="#aaaaaa", text="What if she's allergic to flowers?" },
	{ x=0, y=4, c="#aaaaaa", text="It's a beautiful new day." },
	{ x=0, y=3, c="#aaaaaa", text="I wish this feeling would last forever." },
	{ x=0, y=2, c="#aaaaaa", text="I love you so much, but..." },
	{ x=0, y=1, c="#aaaaaa", text="I miss you." },
	{ x=0, y=0, c="#aaaaaa", text="Everything seems mixed up." },

	{ x=1, y=5, c="#bbbbbb", text="Life is so long and strange." },
	{ x=1, y=4, c="#bbbbbb", text="Why are you so angry?" },
	{ x=1, y=3, c="#bbbbbb", text="It's so hard to get out of bed some days." },
	{ x=1, y=2, c="#bbbbbb", text="He said he wants kids." },
	{ x=1, y=1, c="#bbbbbb", text="This is a quiet life." },

	{ x=2, y=5, c="#cccccc", text="A gentle spring breeze." },
	{ x=2, y=4, c="#cccccc", text="Ice cream on a hot summer night." },
	{ x=2, y=3, c="#cccccc", text="I had a dream in which you died." },
	{ x=2, y=2, c="#cccccc", text="The sound of raindrops on an awning." },
	{ x=2, y=1, c="#cccccc", text="The smell of chalkboard erasers." },
	{ x=2, y=0, c="#cccccc", text="Recalling your smile." },

	{ x=3, y=5, c="#888888", text="A smile happy with a secret." },
	{ x=3, y=4, c="#888888", text="Finding solace during a midnight walk." },
	{ x=3, y=3, c="#bbbbbb", text="You help me feel less alone." },

	{ x=4, y=5, c="#888888", text="The warmth of your embrace." },
	{ x=4, y=4, c="#888888", text="He wrote me a haiku." },
	{ x=4, y=3, c="#cccccc", text="The homeless man's gaze." },

	{ x=5, y=5, c="#bbbbbb", text="Socializing tires me out." },
	{ x=5, y=4, c="#bbbbbb", text="Why are my feelings so intense?" },
	{ x=5, y=3, c="#bbbbbb", text="You inspired me to try harder." },
	{ x=5, y=2, c="#bbbbbb", text="Where do these thoughts come from?" },
	{ x=5, y=1, c="#bbbbbb", text="Will I ever know peace?" },

	{ x=6, y=5, c="#cccccc", text="Fall leaves on the pavement." },
	{ x=6, y=4, c="#cccccc", text="I can't turn my mind off." },
	{ x=6, y=3, c="#cccccc", text="It's so lonely here." },
	{ x=6, y=2, c="#cccccc", text="Please leave me alone." },
	{ x=6, y=1, c="#cccccc", text="Can I love without fear?" },
}

-- handles to actors
local amv, paddle, ball, bmt_af, give_up_text, main_af

-- ball variables
local dx, dy = 0, 0
local velocity = 150

-- paddle variables
local paddle_v = 300
local paddle_dx = 0

local input = { left=false, right=false, start=false, back=false }

-- don't allow two bricks to be broken in too quick of succession
local time_until_next_brick = 0
local intro_is_over = false

local playing = false
local brick_size = 40
local paddle_h = 8
local offset = { x=-160, y=-190 }
local verts = {}
local hidden_bricks = 0
local canvas_w, canvas_h = 640,480

local give_up_time = 3
local held_duration, old_time = 0, 0

local Update = function(af, delta)

	paddle:playcommand("Update", {delta})
	ball:playcommand("Update", {delta})
	amv:playcommand("Update", {delta})

	if time_until_next_brick > 0 then
		time_until_next_brick = time_until_next_brick - delta
	end

	if input.start or input.back then

		if old_time == 0 then
			old_time = GetTimeSinceStart()
			held_duration = 0
		else
			held_duration = GetTimeSinceStart() - old_time
		end

		if held_duration > (give_up_time * 0.15) then
			give_up_text:queuecommand("Show")
		end

		if held_duration > give_up_time then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end

end

local af = Def.ActorFrame{
	InputEventCommand=function(self, event)
		if not intro_is_over then return false end

		if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
			if paddle:GetVisible() then
				playing = true
			else
				SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
			end
		end
		if event.type == "InputEventType_FirstPress" and (event.button=="Up") then
			playing = true
		end

		if event.type ~= "InputEventType_Release" then
			if (event.button=="Left" or event.button=="DownLeft") then input.left = true end
			if (event.button=="Right" or event.button=="DownRight") then input.right = true end
			if (event.button=="Start") then input.start = true end
			if (event.button=="Back") then input.back = true end
		end

		if event.type == "InputEventType_Release" then
			if (event.button=="Left" or event.button=="DownLeft") then
				input.left = false
			end
			if (event.button=="Right" or event.button=="DownRight") then
				input.right = false
			end

			if (event.button=="Start") then
				held_duration, old_time = 0, 0
				give_up_text:playcommand("Hide")
				input.start = false
			end
			if (event.button=="Back") then
				held_duration, old_time = 0, 0
				give_up_text:playcommand("Hide")
				input.back = false
			end
		end
	end,
}

local canvas = Def.ActorFrame{
	InitCommand=function(self)
		main_af = self
		self:Center():SetUpdateFunction(Update)
	end,
	NextScreenCommand=function(self) SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen") end
}

-- gymnopedie no.1
canvas[#canvas+1] = LoadActor("./gymnopedie_no1.ogg")..{
	OnCommand=function(self) self:stop():play():sleep(86):queuecommand("On") end,
}

-- sky
canvas[#canvas+1] = Def.Quad{
	InitCommand=function(self) self:diffuse(color("#d8fdff")) end,
	OnCommand=function(self) self:zoomto(canvas_w, canvas_h) end
}

-- grass
canvas[#canvas+1] = LoadActor("./grass.png")..{
	InitCommand=function(self)
		self:zoomto(canvas_w, canvas_h)
	end
}

-- castle
canvas[#canvas+1] = Def.ActorMultiVertex{
	InitCommand=function(self)
		self:SetDrawState( {Mode="DrawMode_Quads"} )
			:LoadTexture( THEME:GetPathB("ScreenRabbitHole", "overlay/8/brick.png") )
			:SetVertices( verts )

		amv = self
	end,
	UpdateCommand=function(self, params)
		local delta = params[1]
		local vert_to_remove = nil

		for i=1, #verts, 4 do

			-- if this brick is still visible, check if the ball is colliding with it
			if verts[i][2][4] == 1 then

				-- collision checking LEFT and RIGHT
				if (ball:GetY()-brick_size/4 >= verts[i][1][2] and ball:GetY()+brick_size/4 <= verts[i+2][1][2]) then
					-- ball collides with LEFT of this brick
					if (ball:GetX()-brick_size/4 <= verts[i][1][1] and ball:GetX()+(brick_size/4)+dx >= verts[i][1][1] ) then
						dx = -math.abs(dx)
						vert_to_remove = i
						break

					-- ball collides with RIGHT of this brick
					elseif (ball:GetX()+brick_size/4 >= verts[i+1][1][1] and ball:GetX()-(brick_size/4)-dx <= verts[i+1][1][1]) then
						dx = math.abs(dx)
						vert_to_remove = i
						break
					end

				-- collision checking TOP and BOTTOM
				elseif (ball:GetX()+brick_size/4 >= verts[i][1][1] and ball:GetX()-brick_size/4 <= verts[i+1][1][1]) then
					-- ball collides with TOP of this brick
					if (ball:GetY()+brick_size/4 <= verts[i][1][2] and ball:GetY()+(brick_size/4)+dy >= verts[i][1][2]) then
						dy = -math.abs(dy)
						vert_to_remove = i
						break

					-- ball collides with BOTTOM of this brick
					elseif (ball:GetY()+brick_size/4 >= verts[i+2][1][2] and ball:GetY()-(brick_size/4)-dy <= verts[i+2][1][2]) then
						dy = math.abs(dy)
						vert_to_remove = i
						break
					end
				end
			end
		end

		-- actually removing 4 vertices would (I think?) require calling table.remove(vert_to_remove) 4 times
		-- and waiting for the verts table to left-shift everything 4 times,  so just hide it (alpha of 0)
		if (vert_to_remove and time_until_next_brick <= 0) then

			-- set a 0.1 second window in which no additional bricks can be broken
			-- this prevents two (or more) bricks from being broken too quickly to read
			time_until_next_brick = 0.1

			verts[vert_to_remove][2][4] = 0
			verts[vert_to_remove+1][2][4] = 0
			verts[vert_to_remove+2][2][4] = 0
			verts[vert_to_remove+3][2][4] = 0

			hidden_bricks = hidden_bricks + 1
			amv:SetVertices(verts)

			bmt_af:GetChild("")[math.ceil(vert_to_remove/4)]:queuecommand("Reveal")
		end
	end
}

canvas[#canvas+1] = Def.ActorFrame{ InitCommand=function(self) bmt_af = self end }

for i, brick in ipairs(bricks) do
	table.insert( verts, {{brick.x*brick_size+offset.x, brick.y*brick_size+offset.y, 0}, color(brick.c), {0,0} } )
	table.insert( verts, {{brick.x*brick_size+brick_size+offset.x, brick.y*brick_size+offset.y, 0}, color(brick.c), {1,0} } )
	table.insert( verts, {{brick.x*brick_size+brick_size+offset.x, brick.y*brick_size+brick_size+offset.y, 0}, color(brick.c), {1,1} } )
	table.insert( verts, {{brick.x*brick_size+offset.x, brick.y*brick_size+brick_size+offset.y, 0}, color(brick.c), {0,1} } )

	canvas[#canvas][i] = Def.BitmapText{
		File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/monaco/_monaco 20px.ini"),
		Text=brick.text,
		InitCommand=function(self)
			self:zoom(0.35):diffuse(Color.Black)
				:visible(false)
				:xy(brick.x*brick_size+offset.x+brick_size/2, brick.y*brick_size+offset.y+brick_size/2)
		end,
		RevealCommand=function(self)
			self:visible(true):linear(1.1):zoom(1):addy(-30):diffusealpha(0):queuecommand("Hide")
		end,
		HideCommand=function(self)
			self:visible(false)
		end
	}
end

-- Paddle
canvas[#canvas+1] = Def.Quad{
	InitCommand=function(self)
		paddle = self
		self:diffuse(Color.Black):zoomto(brick_size*2, paddle_h):xy(brick_size/2, _screen.h/2 - 24)
	end,
	UpdateCommand=function(self, params)
		local delta = params[1]
		-- move paddle left
		if input.left then
			paddle_dx = -paddle_v*delta
			if self:GetX()+paddle_dx > -canvas_w/2 then
				self:x( self:GetX() + paddle_dx )
				if not playing then
					ball:x(self:GetX())
				end
			end
		end

		-- move paddle right
		if input.right then
			paddle_dx = paddle_v*delta
			if self:GetX()+paddle_dx < canvas_w/2 then
				self:x( self:GetX() + paddle_dx )
				if not playing then
					ball:x(self:GetX())
				end
			end
		end
	end,
	HideCommand=function(self) self:visible(false) end
}

-- ball
canvas[#canvas+1] = LoadActor("./ball.png")..{
	InitCommand=function(self)
		ball = self
		self:zoomto(brick_size/2, brick_size/2)
			:diffuse(color("#00bfff"))
			:xy(paddle:GetX(), paddle:GetY() - paddle_h/2 - brick_size/4)
	end,
	UpdateCommand=function(self, params)
		local delta = params[1]

		-- ball collides with right || left of canvas
		if (self:GetX() + dx > canvas_w/2 or self:GetX() + dx < -canvas_w/2) then
			dx = -dx
			self:playcommand("Move")
			return
		end

		-- ball collides with top of canvas
		if (self:GetY() + dy < -canvas_h/2 and hidden_bricks < #bricks) then
			dy = math.abs(dy)
			self:playcommand("Move")
			return

		-- ball goes beyond bottom (plus padding)
		elseif (self:GetY() + dy > canvas_h/2 + 20) then
			dx, dy = 0,0
			self:playcommand("Reset")
			return
		end

		-- ball collides with paddle
		if (self:GetY() <= (paddle:GetY() - paddle_h)
		and (self:GetY() + dy > (paddle:GetY() - paddle_h))
		and ((self:GetX()) > paddle:GetX()-brick_size)
		and ((self:GetX()) < (paddle:GetX() + brick_size))) then

			local relativeIntersect = self:GetX() - paddle:GetX()
			local normalizedIntersect = relativeIntersect/(brick_size)
			dx = normalizedIntersect * (velocity * delta)
			dy = -math.abs(velocity * delta)
			self:playcommand("Move")
			return
		end

		-- endgame has resulted in ball going beyond the upper bound
		if (self:GetY() < -canvas_h and playing) then
			if (hidden_bricks < #bricks) then
				self:playcommand("Reset")
				return
			else
				-- hide ball and paddle
				playing = false
				dx, dy = 0, 0
				ball:visible(false)
				paddle:linear(1):diffusealpha(0):queuecommand("Hide")
				main_af:sleep(2.5):smooth(1):diffuse(0,0,0,1):queuecommand("NextScreen")
			end
		end

		-- if the ball was just released from the paddle
		-- this.moving will be true, but dy will still be 0
		-- so start the ball moving upwards
		if (playing and dy == 0) then
			dy = -(velocity * delta)
			self:playcommand("Move")
			return
		end

		self:playcommand("Move")
	end,
	MoveCommand=function(self)
		self:x(self:GetX() + dx)
		self:y(self:GetY() + dy)
	end,
	ResetCommand=function(self)
		playing = false
		self:xy(paddle:GetX(), paddle:GetY() - paddle_h/2 - brick_size/4)
	end,
}

af[#af+1] = canvas

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	Text="continue holding to quit",
	InitCommand=function(self)
		give_up_text = self
		self:xy(_screen.cx, _screen.cy+100):zoom(1):diffuse( 0,0,0,0 )
	end,
	ShowCommand=function(self) self:finishtweening():linear(0.1):diffusealpha(1) end,
	HideCommand=function(self) self:finishtweening():linear(0.1):diffusealpha(0) end,
}

-- intro (thanks, xkcd)
af[#af+1] = Def.ActorFrame{
	InitCommand=function(self) self:diffuse(0,0,0,1) end,
	OnCommand=function(self) self:sleep(1.5):smooth(1):diffuse(1,1,1,1):sleep(6.4):smooth(1):diffusealpha(0):queuecommand("Hide") end,
	HideCommand=function(self)
		self:visible(false)
		intro_is_over = true
	end,

	Def.Quad{ InitCommand=function(self) self:FullScreen():diffuse(Color.Black) end },

	LoadActor("./_856 (doubleres).png")..{
		InitCommand=function(self) self:xy(_screen.cx, _screen.cy+50) end
	},
	LoadActor("./_855 (doubleres).png")..{
		InitCommand=function(self) self:xy(_screen.cx, _screen.cy+50) end,
		OnCommand=function(self) self:sleep(5.5):smooth(0.25):diffusealpha(0) end
	}
}

return af