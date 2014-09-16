local gc = Var("GameCommand")
local iIndex = gc:GetIndex()
local sName = gc:GetName()
local game = GAMESTATE:GetCurrentGame():GetName()

local viewport 	= { w = 200, h = 150}
local arrow		= { w = 12,  h = 20 }
local timePerArrow = 0.2
local pattern = {
	dance	= {"left", "down", "up", "right", "down", "up", "left", "right", "down", "right", "up", "down"},
	pump 	= {"upleft", "upright", "center", "downright", "upright", "center", "upleft", "upright", "center", "downright", "downleft", "center"},
	techno 	= {"upleft", "upright", "down", "downright", "downleft", "up", "down", "right", "left", "downright", "downleft", "up"}
}

-- I don't intend to include visualization for kb7, beat, or pop'n,
-- so fall back on the visualization for dance if necessary.
if not pattern[game] then
	game = "dance"
end

local t = Def.ActorFrame{
	
	Name="Item"..iIndex,
	InitCommand=cmd(),
	GainFocusCommand=cmd(linear,0.2; zoom,1),
	LoseFocusCommand=cmd(linear,0.2; zoom,0.4; ),
	OffCommand=cmd(linear,0.2; diffusealpha,0),
	
	Def.ActorFrame{
		
		-- grey border
		Def.Quad{
			InitCommand=cmd(diffuse,color("0.2,0.2,0.2,0.75"));
			OnCommand=cmd(zoomto,viewport.w+4,viewport.h+4);
		},
	
		-- black background
		Def.Quad{
			InitCommand=cmd(diffuse,color("0,0,0,1"););
			OnCommand=cmd(zoomto,viewport.w,viewport.h);
		},
				
		-- lower mask to hide the arrows scrolling upwards
		Def.Quad{
			InitCommand=cmd(zoomto,viewport.w*2.19,viewport.h*3; addy,viewport.h*2; MaskSource, true);
			OffCommand=cmd(linear,0.2; diffusealpha,0);
		}
	},
	
	
	-- text description of each mode ("dance", "marathon")
	LoadFont("_wendy small")..{
		Name="ModeName"..iIndex;
		Text=THEME:GetString(Var 'LoadingScreen',sName);
		InitCommand=cmd(y,100; zoom,0.6; )
	}
}


local playfield = Def.ActorFrame{}
	
if game == "pump" then
	
	-- downleft receptor arrow
	playfield[#playfield+1] = LoadActor("pump-arrow-body.png")..{
		InitCommand=cmd(rotationz,-90; x,-arrow.w*4; y,-55; zoom, 0.18)
	}
	-- upleft receptor arrow
	playfield[#playfield+1] = LoadActor("pump-arrow-body.png")..{
		InitCommand=cmd(x,-arrow.w*2; y,-55; zoom, 0.18)
	}
	-- center receptor arrow
	playfield[#playfield+1] = LoadActor("pump-center-body.png")..{
		InitCommand=cmd(x,0; y,-55; zoom, 0.18)
	}
	-- upright receptor arrow
	playfield[#playfield+1] = LoadActor("pump-arrow-body.png")..{
		InitCommand=cmd(rotationz,90; x,arrow.w*2; y,-55; zoom, 0.18)
	}
	-- downright receptor arrow
	playfield[#playfield+1] = LoadActor("pump-arrow-body.png")..{
		InitCommand=cmd(rotationz,180; x,arrow.w*4; y,-55; zoom, 0.18)
	}
	
elseif game == "techno" then
	
	-- downleft receptor arrow
	playfield[#playfield+1] = LoadActor("pump-arrow-body.png")..{
		InitCommand=cmd(rotationz,-90; x,-arrow.w*7; y,-55; zoom, 0.18)
	}
	-- left receptor arrow
	playfield[#playfield+1] = LoadActor("pump-arrow-body.png")..{
		InitCommand=cmd(rotationz,-45; x,-arrow.w*5; y,-55; zoom, 0.18)
	}
	-- upleft receptor arrow
	playfield[#playfield+1] = LoadActor("pump-arrow-body.png")..{
		InitCommand=cmd(x,-arrow.w*3; y,-55; zoom, 0.18)
	}
	-- down receptor arrow
	playfield[#playfield+1] = LoadActor("pump-arrow-body.png")..{
		InitCommand=cmd(rotationz,-135; x,-arrow.w; y,-55; zoom, 0.18)
	}
	-- up receptor arrow
	playfield[#playfield+1] = LoadActor("pump-arrow-body.png")..{
		InitCommand=cmd(rotationz,45; x,arrow.w; y,-55; zoom, 0.18)
	}
	-- upright receptor arrow
	playfield[#playfield+1] = LoadActor("pump-arrow-body.png")..{
		InitCommand=cmd(rotationz,90; x,arrow.w*3; y,-55; zoom, 0.18)
	}
	-- right receptor arrow
	playfield[#playfield+1] = LoadActor("pump-arrow-body.png")..{
		InitCommand=cmd(rotationz,135; x,arrow.w*5; y,-55; zoom, 0.18)
	}
	-- downright receptor arrow
	playfield[#playfield+1] = LoadActor("pump-arrow-body.png")..{
		InitCommand=cmd(rotationz,180; x,arrow.w*7; y,-55; zoom, 0.18)
	}

else
	
	-- left receptor arrow
	playfield[#playfield+1] = LoadActor("dance-receptor.png")..{
		InitCommand=cmd(addx,-arrow.w*3; addy,-55; zoom, 0.77)
	}
	-- down receptor arrow
	playfield[#playfield+1] = LoadActor("dance-receptor.png")..{
		InitCommand=cmd(rotationz,-90; addx,-arrow.w; addy,-55; zoom, 0.77)
	}
	-- up receptor arrow
	playfield[#playfield+1] = LoadActor("dance-receptor.png")..{
		InitCommand=cmd(rotationz,90; addx,arrow.w; addy,-55; zoom, 0.77)
	}
	-- right receptor arrow
	playfield[#playfield+1] = LoadActor("dance-receptor.png")..{
		InitCommand=cmd(rotationz,180; addx,arrow.w*3; addy,-55; zoom, 0.77)
	}
end



local function LoopThisArrow(self,i)
	-- reset the y of this arrow to a lower position
	self:y(#pattern[game] * arrow.h)

	-- apply tweens appropriately
	if sName == "Nonstop" then
		self:ease(timePerArrow * #pattern[game], 75)
		self:addrotationz(720)
	else
		self:linear(timePerArrow * #pattern[game])
	end
	
	--  -55 seems to be a good static y value to tween to
	--  before recursing and effectively doing this again
	self:y(-55)
	self:queuecommand('Loop')

end




local function YieldStepPattern(i, dir)
	
	local rz, ax
	if game == "pump" then
		if dir == "downleft" then
			rz = -90
			ax = -arrow.w*4
		elseif dir == "upleft" then
			rz = 0
			ax = -arrow.w*2
		elseif dir == "center" then
			rz = 0
			ax = 0
		elseif dir == "upright" then
			rz = 90
			ax = arrow.w*2
		elseif dir == "downright" then
			rz = 180
			ax = arrow.w*4
		end
		
	elseif game == "techno" then
		
		if dir == "downleft" then
			rz = -45
			ax = -arrow.w*7
		elseif dir == "left" then
			rz = 0
			ax = -arrow.w*5
		elseif dir == "upleft" then
			rz = 45
			ax = -arrow.w*3
		elseif dir == "down" then
			rz = -90
			ax = -arrow.w
		elseif dir == "up" then
			rz = 90
			ax = arrow.w
		elseif dir == "upright" then
			rz = 135
			ax = arrow.w*3
		elseif dir == "right" then
			rz = 180
			ax = arrow.w*5
		elseif dir == "downright" then
			rz = 225
			ax = arrow.w*7
		end
		
	else
		
		if dir == "left" then
			rz = 0
			ax = -arrow.w*3
		elseif dir == "down" then
			rz = -90
			ax = -arrow.w
		elseif dir == "up" then
			rz = 90
			ax = arrow.w
		elseif dir == "right" then
			rz = 180
			ax = arrow.w*3
		end
	end
	
	local step = Def.ActorFrame{
		
		InitCommand=cmd(
			y, -55 + (i * (arrow.h+5));
			rotationz, rz;
			addx, ax;
			MaskDest;
		),
		OnCommand=cmd(queuecommand,"FirstLoop"),
		
		FirstLoopCommand=function(self)
			-- apply tweens appropriately
			if sName == "Nonstop" then
				self:ease(timePerArrow * i, 75)
				self:addrotationz(720)
			else
				self:linear(i*timePerArrow)
			end
			self:y(-55)
			self:queuecommand("Loop")
			
		end,
		LoopCommand=function(self)
			LoopThisArrow(self,i)
		end
	}
	
	if game == "pump" then
		
		if pattern[game][i] == "center" then
			
			-- colorful center arrow body
			step[#step+1] = LoadActor("pump-center-body.png")..{
				InitCommand=cmd( diffuse,color("1,1,1,1"); zoom, 0.18 ),
				GainFocusCommand=cmd(diffuse,GetHexColor(i)),
				LoseFocusCommand=cmd(diffuse,color("0.5,0.5,0.5,1")),
				OffCommand=cmd(diffusealpha,0)
			}
			
			-- colorful center arrow border
			step[#step+1] = LoadActor("pump-center-border.png")..{
				InitCommand=cmd( diffuse,color("1,1,1,1"); zoom, 0.18 ),
				GainFocusCommand=cmd(diffuse,GetHexColor(i)),
				LoseFocusCommand=cmd(diffuse,color("0.5,0.5,0.5,1")),
				OffCommand=cmd(diffusealpha,0)
			}
			
			-- colorful center arrow feet
			step[#step+1] = LoadActor("pump-center-feet.png")..{
				InitCommand=cmd(zoom, 0.18 ),
				OnCommand=cmd(blend,Blend.Multiply),
				OffCommand=cmd(diffusealpha,0)
			}
		else
			-- gray arrow border
			step[#step+1] = LoadActor("pump-arrow-border.png")..{
				InitCommand=cmd( diffuse,color("1,1,1,1"); zoom, 0.18 ),
				OffCommand=cmd(diffusealpha,0)
			}			
		
			-- colorful arrow body
			step[#step+1] = LoadActor("pump-arrow-body.png")..{
				InitCommand=cmd( diffuse,color("1,1,1,1"); zoom, 0.18 ),
				GainFocusCommand=cmd(diffuse,GetHexColor(i)),
				LoseFocusCommand=cmd(diffuse,color("0.5,0.5,0.5,1")),
				OffCommand=cmd(diffusealpha,0)
			}
			
			-- colorful arrow stripes
			step[#step+1] = LoadActor("pump-arrow-stripes.png")..{
				InitCommand=cmd(zoom, 0.18 ),
				OnCommand=cmd(blend,Blend.Multiply),
				OffCommand=cmd(diffusealpha,0)
			}	

		end
		
	else
		-- white background arrow
		step[#step+1] = LoadActor("dance-receptor.png")..{
			InitCommand=cmd( diffuse,color("1,1,1,1"); zoom, 0.77; ),
			OffCommand=cmd(diffusealpha,0)
		}
	
		-- colorful arrow
		step[#step+1] = LoadActor("dance-arrow.png")..{
			InitCommand=cmd( diffuse,GetHexColor(i); zoom, 0.77; ),
			GainFocusCommand=cmd(diffuse,GetHexColor(i)),
			LoseFocusCommand=cmd(diffuse,color("0.5,0.5,0.5,1")),
			OffCommand=cmd(diffusealpha,0)
		}
	end
	

	return step
end



for i=1,#pattern[game] do
	playfield[#playfield+1] = YieldStepPattern(i, pattern[game][i])
end

t[#t+1] = playfield

return t