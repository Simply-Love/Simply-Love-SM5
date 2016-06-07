local file = THEME:GetPathB("", "_shared background normal/" .. ThemePrefs.Get("VisualTheme") .. ".png")

-- this variable will be used within the scope of this file like (index+1) and (index-1)
-- to continue to diffuse each sprite as we shift through the colors available in SL.Colors
local index = SL.Global.ActiveColorIndex

-- time in seconds for the first NewColor (which is triggered from AF's InitCommand)
-- should be 0 so that children sprites get colored properly immediately; we'll
-- change this variable in the AF's OnCommand so that color-shifts tween appropriately
local delay = 0

local af = Def.ActorFrame{
	Def.Quad{
		InitCommand=function(self) self:FullScreen():Center():diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black ) end,
		BackgroundImageChangedMessageCommand=function(self)
			THEME:ReloadMetrics()
			SL.Global.ActiveColorIndex = 3
			self:linear(1):diffuse( ThemePrefs.Get("RainbowMode") and Color.White or Color.Black )
		end,
	}
}

-- --------------------------------------------------------
-- non-RainbowMode (normal) background

local file_info = {
	ColorRGB = {0,1,1,0,0,0,1,1,1,1},
	diffusealpha = {0.05,0.2,0.1,0.1,0.1,0.1,0.1,0.05,0.1,0.1},
	xy = {0,40,80,120,200,280,360,400,480,560},
	texcoordvelocity = {{0.03,0.01},{0.03,0.02},{0.03,0.01},{0.02,0.02},{0.03,0.03},{0.02,0.02},{0.03,0.01},{-0.03,0.01},{0.05,0.03},{0.03,0.04}}
}

local t = Def.ActorFrame {
	InitCommand=function(self)
		if ThemePrefs.Get("RainbowMode") then
			self:visible(false)
		else
			self:diffusealpha(0)
		end
	end,
	OnCommand=cmd(accelerate,0.8; diffusealpha,1),
	BackgroundImageChangedMessageCommand=function(self)
		if not ThemePrefs.Get("RainbowMode") then
			self:visible(true):linear(0.6):diffusealpha(1)
		else
			self:linear(0.6):diffusealpha(0):queuecommand("Hide")
		end
	end,
	HideCommand=function(self) self:visible(false) end,
}

for i=1,10 do
	t[#t+1] = Def.Sprite {
		Texture=file,
		InitCommand=cmd(diffuse, ColorRGB( file_info.ColorRGB[i] ) ),
		ColorSelectedMessageCommand=cmd(linear, 0.5; diffuse, ColorRGB( file_info.ColorRGB[i] ); diffusealpha, file_info.diffusealpha[i] ),
		OnCommand=cmd(zoom,1.3; xy, file_info.xy[i], file_info.xy[i]; customtexturerect,0,0,1,1;
			texcoordvelocity, file_info.texcoordvelocity[i][1], file_info.texcoordvelocity[i][2]; diffusealpha, file_info.diffusealpha[i] ),
		BackgroundImageChangedMessageCommand=function(self)
			local new_file = THEME:GetPathB("", "_shared background normal/" .. ThemePrefs.Get("VisualTheme") .. ".png")
			self:Load(new_file)
		end
	}
end

af[#af+1] = t

-- --------------------------------------------------------
-- RainbowMode background

af[#af+1] = Def.ActorFrame{
	InitCommand=function(self)
		if not ThemePrefs.Get("RainbowMode") then
			self:visible(false)
		end
	end,
	OnCommand=cmd(Center; bob; effectmagnitude,0,50,0; effectperiod,8),
	BackgroundImageChangedMessageCommand=function(self)
		if ThemePrefs.Get("RainbowMode") then
			self:visible(true):linear(0.6):diffusealpha(1)
		else
			self:linear(0.6):diffusealpha(0):queuecommand("Hide")
		end
	end,
	HideCommand=function(self) self:visible(false) end,


	Def.ActorFrame{
		OnCommand=cmd(bob; effectmagnitude,0,0,50; effectperiod,12),

		Def.ActorFrame{
			InitCommand=cmd(diffusealpha,0; queuecommand, "Appear"; playcommand, "NewColor" ),
			OnCommand=function(self)
				delay = 0.7
			end,

			AppearCommand=cmd(linear,1; diffusealpha, 1; queuecommand, "Loop"),
			-- OffCommand=cmd(linear,1; diffusealpha,0),

			LoopCommand=function(self)
				index = index + 1
				self:queuecommand('NewColor')
				self:sleep(delay)
				self:queuecommand('Loop')
			end,

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom,1.3; x,000; y,-000; z,-030; customtexturerect,0,0,1,1; texcoordvelocity,0.03,.04 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index+1); diffusealpha, 0.3 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,-050; y,040; z,-100; customtexturerect,0,0,1,1; texcoordvelocity,0.04,.01 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index+1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,050; y,-080; z,-100; customtexturerect,0,0,1,1; texcoordvelocity,0.05,.02 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index-1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,-100; y,120; z,-200; customtexturerect,0,0,1,1; texcoordvelocity,0.06,.02 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index-1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,100; y,-160; z,-040; customtexturerect,0,0,1,1; texcoordvelocity,0.07,.01 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index+1); diffusealpha, 0.3),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,-150; y,210; z,-050; customtexturerect,0,0,1,1; texcoordvelocity,0.08,.01 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index-1); diffusealpha, 0.3),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,150; y,-250; z,-200; customtexturerect,0,0,1,1; texcoordvelocity,0.03,.03 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index-1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,-200; y,290; z,-060; customtexturerect,0,0,1,1; texcoordvelocity,0.03,.03 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index+1); diffusealpha, 0.3),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,200; y,-330; z,-100; customtexturerect,0,0,1,1; texcoordvelocity,0.03,.02 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index-1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,-250; y,370; z,-100; customtexturerect,0,0,1,1; texcoordvelocity,0.03,.03 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index+1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,250; y,-410; z,-050; customtexturerect,0,0,1,1; texcoordvelocity,0.03,.01 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index+1); diffusealpha, 0.3),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,-300; y,450; z,-000; customtexturerect,0,0,1,1; texcoordvelocity,0.03,.01 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index-1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,300; y,-490; z,-100; customtexturerect,0,0,1,1; texcoordvelocity,0.03,.01 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index+1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,-350; y,530; z,-100; customtexturerect,0,0,1,1; texcoordvelocity,0.03,.02 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index+1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,350; y,-570; z,-000; customtexturerect,0,0,1,1; texcoordvelocity,0.03,.01 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index-1); diffusealpha, 0.3),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,-400; y,610; z,-200; customtexturerect,0,0,1,1; texcoordvelocity,0.04,.03 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index+1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,400; y,-650; z,-100; customtexturerect,0,0,1,1; texcoordvelocity,0.03,.02 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index+1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,-450; y,690; z,-100; customtexturerect,0,0,1,1; texcoordvelocity,0.02,.04 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index+1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,450; y,-730; z,-200; customtexturerect,0,0,1,1; texcoordvelocity,0.03,.02 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index-1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,-500; y,770; z,-200; customtexturerect,0,0,1,1; texcoordvelocity,0.06,.01 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index+1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,500; y,-810; z,-100; customtexturerect,0,0,1,1; texcoordvelocity,0.04,.01 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index-1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,-550; y,850; z,-070; customtexturerect,0,0,1,1; texcoordvelocity,0.03,.02 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index-1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,550; y,-890; z,-200; customtexturerect,0,0,1,1; texcoordvelocity,0.02,.03 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index-1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,-600; y,930; z,-100; customtexturerect,0,0,1,1; texcoordvelocity,0.06,.02 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index-1); diffusealpha, 0.2 ),
			},

			Def.Sprite{
				Texture=file,
				InitCommand=cmd(zoom, 1.3; x,600; y,-970; z,-100; customtexturerect,0,0,1,1; texcoordvelocity,0.04,.04 ),
				NewColorCommand=cmd(linear, delay; diffuse, GetHexColor(index+1); diffusealpha, 0.2 ),
			}
		}
	}
}

return af