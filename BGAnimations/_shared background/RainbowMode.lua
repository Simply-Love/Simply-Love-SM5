-- --------------------------------------------------------
-- RainbowMode background

local file = ...

-- this index will be used within the scope of this file like (index+1) and (index-1)
-- to continue to diffuse each sprite as we shift through the colors available in SL.Colors
local index = SL.Global.ActiveColorIndex

-- time in seconds for the first NewColor (which is triggered from AF's InitCommand)
-- should be 0 so that children sprites get colored properly immediately; we'll
-- change this variable in the AF's OnCommand so that color-shifts tween appropriately
local delay = 0

local af1 = Def.ActorFrame{
	InitCommand=function(self)
		local style = ThemePrefs.Get("VisualStyle")
		self:visible(ThemePrefs.Get("RainbowMode") and style ~= "SRPG8")
	end,
	OnCommand=function(self) self:Center():bob():effectmagnitude(0,50,0):effectperiod(8) end,
	VisualStyleSelectedMessageCommand=function(self)
		local style = ThemePrefs.Get("VisualStyle")

		if ThemePrefs.Get("RainbowMode") and style ~= "SRPG8" then
			self:visible(true):linear(0.6):diffusealpha(1)
		else
			self:linear(0.6):diffusealpha(0):queuecommand("Hide")
		end
	end,
	HideCommand=function(self) self:visible(false) end,
}

local af2 = Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0):queuecommand("Appear"):playcommand("NewColor") end,
	AppearCommand=function(self) self:linear(1):diffusealpha(1):queuecommand("Loop") end,

	OnCommand=function(self)
		delay = 0.7
		self:bob():effectmagnitude(0,0,50):effectperiod(12)
	end,
	VisualStyleSelectedMessageCommand=function(self)
		if ThemePrefs.Get("RainbowMode") then
			local new_file = THEME:GetPathG("", "_VisualStyles/" .. ThemePrefs.Get("VisualStyle") .. "/SharedBackground.png")
			self:RunCommandsOnChildren(function(child) child:Load(new_file) end)
		end
	end,

	LoopCommand=function(self)
		index = index + 1
		self:queuecommand("NewColor"):sleep(delay):queuecommand("Loop")
	end
}

-- To this day, I wonder where these numbers originally came from.  Did hurtpiggypig and mad matt
-- just sit down and play with different combinations of numbers until they found something aesthetically
-- pleasing? Did they use some kind of animating tool to assist and export values?  Was it ancient
-- aliens all along?  We may never know.
local anim_data = {
	x = {0,-50,50,-100,100,-150,150,-200,200,-250,250,-300,300,-350,350,-400,400,-450,450,-500,500,-550,550,-600,600},
	y = {0,40,-80,120,-160,210,-250,290,-330,370,-410,450,-490,530,-570,610,-650,690,-730,770,-810,850,-890,930,-970},
	z = {-030,-100,-100,-200,-040,-050,-200,-060,-100,-100,-050,-000,-100,-100,-000,-200,-100,-100,-200,-200,-100,-070,-200,-100,-100},
	tv_x = {0.03,0.04,0.05,0.06,0.07,0.08,0.03,0.03,0.03,0.03,0.03,0.03,0.03,0.03,0.03,0.04,0.03,0.02,0.03,0.06,0.04,0.03,0.02,0.06,0.04},
	tv_y = {0.04,0.01,0.02,0.02,0.01,0.01,0.03,0.03,0.02,0.03,0.01,0.01,0.01,0.02,0.01,0.03,0.02,0.04,0.02,0.01,0.01,0.02,0.03,0.02,0.04},
	color_add = {1,1,-1,-1,1,-1,-1,1,-1,1,1,-1,1,1,-1,1,1,1,-1,1,-1,-1,-1,-1,1},
	a = {0.3,0.2,0.2,0.2,0.3,0.3,0.2,0.3,0.2,0.2,0.3,0.2,0.2,0.2,0.3,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2}
}

for i=1,25 do
	af2[#af2+1] = LoadActor(file)..{
		InitCommand=function(self)
			self:zoom(1.3)
			:xy(anim_data.x[i], anim_data.y[i])
			:z(anim_data.z[i])
			:customtexturerect(0,0,1,1)
			:texcoordvelocity(anim_data.tv_x[i], anim_data.tv_y[i])
		end,
		NewColorCommand=function(self)
			self:linear(delay)
			:diffuse( GetHexColor(index+anim_data.color_add[i], true))
			:diffusealpha(anim_data.a[i])
		end
	}
end

af1[#af1+1] = af2

return af1
