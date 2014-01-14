local gc = Var("GameCommand");
local iIndex = gc:GetIndex();
local sName = gc:GetName();

local viewport 	= { w = 200, h = 150};
local arrow		= { w = 12,  h = 20 };
local timePerArrow = 0.2;
local pattern = {"left", "down", "up", "right", "down", "up", "left", "right", "down", "right", "up", "down"}



local t = Def.ActorFrame{
	
	Name="Item"..iIndex;
	InitCommand=cmd();
	GainFocusCommand=cmd(linear,0.2; zoom,1);
	LoseFocusCommand=cmd(linear,0.2; zoom,0.4; );
	OffCommand=cmd(linear,0.2; diffusealpha,0);
	
	Def.ActorFrame{
		
		-- grey border
		Def.Quad{
			InitCommand=cmd(diffuse,color("0.2,0.2,0.2,0.75"));
			OnCommand=cmd(zoomto,viewport.w+4,viewport.h+4);
		};
	
		-- black background
		Def.Quad{
			InitCommand=cmd(diffuse,color("0,0,0,1"););
			OnCommand=cmd(zoomto,viewport.w,viewport.h);
		};
				
		-- lower mask to hide the arrows scrolling upwards
		Def.Quad{
			
			--diffuse,color("0,0,0,0.01") is a workaround because masking in Mac OS SM5 is broken
			InitCommand=cmd(zoomto,viewport.w*2.19,viewport.h*3; addy,viewport.h*2; diffuse,color("0,0,0,0.01"); MaskSource, true);
			OffCommand=cmd(linear,0.2; diffusealpha,0);
		};	
	};
	
	
	-- text description of each mode ("dance", "marathon")
	LoadFont("_wendy small")..{
		Name="ModeName"..iIndex;
		Text=THEME:GetString(Var 'LoadingScreen',sName);
		InitCommand=cmd(y,100; zoom,0.6; );
	};
};


local playfield = Def.ActorFrame{
	
	-- left receptor arrow
	LoadActor("dance-receptor.png")..{
		InitCommand=cmd(addx,-arrow.w*3; addy,-55; zoom, 0.77);
	};
	-- down receptor arrow
	LoadActor("dance-receptor.png")..{
		InitCommand=cmd(rotationz,-90; addx,-arrow.w; addy,-55; zoom, 0.77);
	};
	-- up receptor arrow
	LoadActor("dance-receptor.png")..{
		InitCommand=cmd(rotationz,90; addx,arrow.w; addy,-55; zoom, 0.77);
	};
	-- right receptor arrow
	LoadActor("dance-receptor.png")..{
		InitCommand=cmd(rotationz,180; addx,arrow.w*3; addy,-55; zoom, 0.77);
	};
};







local function LoopThisArrow(self,i)
	-- reset the y of this arrow to a lower position
	self:y(#pattern * arrow.h);

	-- apply tweens appropriately
	if sName == "Nonstop" then
		self:ease(timePerArrow * #pattern, 75);
		self:addrotationz(720);
	else
		self:linear(timePerArrow * #pattern);		
	end
	
	--  -55 seems to be a good static y value to tween to
	--  before recursing and effectively doing this again
	self:y(-55);
	self:queuecommand('Loop');

end




local function YieldStepPattern(i, dir)
	
	local rz, ax;
	if dir == "left" then
		rz = 0;
		ax = -arrow.w*3;
	elseif dir == "down" then
		rz = -90;
		ax = -arrow.w;
	elseif dir == "up" then
		rz = 90;
		ax = arrow.w;
	elseif dir == "right" then
		rz = 180;
		ax = arrow.w*3;
	end
	
	local step = Def.ActorFrame{
		
		InitCommand=cmd(
			y, -55 + (i * (arrow.h+5));
			rotationz, rz;
			addx, ax;
			MaskDest;
		);
		OnCommand=cmd(queuecommand,"FirstLoop");
		
		FirstLoopCommand=function(self)
			-- apply tweens appropriately
			if sName == "Nonstop" then
				--self:decelerate(i*timePerArrow);
				self:ease(timePerArrow * i, 75);
				self:addrotationz(720);
			else
				self:linear(i*timePerArrow);
			end
			self:y(-55);
			self:queuecommand("Loop")
			
		end;
		LoopCommand=function(self)
			LoopThisArrow(self,i);
		end;	
			
		-- white background arrow
		LoadActor("dance-arrow.png")..{
			InitCommand=cmd( diffuse,color("1,1,1,1"); zoom, 0.8; );
			OffCommand=cmd(diffusealpha,0);
		};
	
		-- colorful arrow
		LoadActor("dance-arrow.png")..{
			InitCommand=cmd( diffuse,GetHexColor(i); zoom, 0.74; );
			GainFocusCommand=cmd(diffuse,GetHexColor(i));
			LoseFocusCommand=cmd(diffuse,color("0.5,0.5,0.5,1"));
			OffCommand=cmd(diffusealpha,0);
		};
	};
	

	return step;
end;






for i=1,#pattern do
	playfield[#playfield+1] = YieldStepPattern(i, pattern[i]);
end

t[#t+1] = playfield;

return t;