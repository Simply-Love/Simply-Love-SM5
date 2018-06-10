local args = ...
local row = args[1]
local col = args[2]
local y_offset = args[3]

local af = Def.ActorFrame{
	Name="SongWheelShared",
	InitCommand=function(self) self:y(y_offset) end
}

-----------------------------------------------------------------
-- black background quad
af[#af+1] = Def.Quad{
	Name="SongWheelBackground",
	InitCommand=cmd(zoomto, _screen.w, _screen.h/(row.how_many-2); diffuse, Color.Black; diffusealpha,1; cropbottom,1),
	OnCommand=cmd(xy, _screen.cx, math.ceil((row.how_many-2)/2) * row.h + 10; finishtweening; accelerate, 0.2; cropbottom,0),
	SwitchFocusToGroupsMessageCommand=cmd(smooth,0.3; cropright,1),
	SwitchFocusToSongsMessageCommand=cmd(smooth,0.3; cropright,0),
	SwitchFocusToSingleSongMessageCommand=cmd(smooth,0.3; cropright,1),
}

-- rainbow glowing border top
af[#af+1] = Def.Quad{
	InitCommand=cmd(zoomto, _screen.w, 1; diffuse, Color.White; diffusealpha,0; xy, _screen.cx, _screen.cy+30 + _screen.h/(row.how_many-2)*-0.5; faderight, 10; rainbow),
	OnCommand=cmd(sleep,0.3; diffusealpha, 0.75; queuecommand, "FadeMe"),
	FadeMeCommand=cmd(accelerate,1.5; faderight, 0; accelerate, 1.5; fadeleft, 10; sleep,0; diffusealpha,0; fadeleft,0; sleep,1.5; faderight, 10; diffusealpha,0.75; queuecommand, "FadeMe"),
	SwitchFocusToGroupsMessageCommand=cmd(visible, false),
	SwitchFocusToSingleSongMessageCommand=cmd(visible, false),
	SwitchFocusToSongsMessageCommand=cmd(visible,true)
}

-- rainbow glowing border bottom
af[#af+1] = Def.Quad{
	InitCommand=cmd(zoomto, _screen.w, 1; diffuse, Color.White; diffusealpha,0; xy, _screen.cx, _screen.cy+30 + _screen.h/(row.how_many-2) * 0.5; faderight, 10; rainbow),
	OnCommand=cmd(sleep,0.3; diffusealpha, 0.75; queuecommand, "FadeMe"),
	FadeMeCommand=cmd(accelerate,1.5; faderight, 0; accelerate, 1.5; fadeleft, 10; sleep,0; diffusealpha,0; fadeleft,0; sleep,1.5; faderight, 10; diffusealpha,0.75; queuecommand, "FadeMe"),
	SwitchFocusToGroupsMessageCommand=cmd(visible, false),
	SwitchFocusToSingleSongMessageCommand=cmd(visible, false),
	SwitchFocusToSongsMessageCommand=cmd(visible,true)
}
-----------------------------------------------------------------
-- left/right UI arrows

af[#af+1] = Def.ActorFrame{
	Name="Arrows",
	InitCommand=function(self) self:diffusealpha(0):xy(_screen.cx, _screen.cy+30) end,
	OnCommand=function(self) self:sleep(0.1):linear(0.2):diffusealpha(1) end,
	SwitchFocusToGroupsMessageCommand=cmd(linear, 0.2; diffusealpha, 0),
	SwitchFocusToSingleSongMessageCommand=cmd(linear, 0.1; diffusealpha, 0),
	SwitchFocusToSongsMessageCommand=cmd(sleep, 0.2; linear, 0.2; diffusealpha, 1),

	-- right arrow
	Def.ActorFrame{
		Name="RightArrow",
		OnCommand=cmd(x, _screen.cx-50),
		PressCommand=cmd(decelerate,0.05; zoom,0.7; glow,color("#ffffff22"); accelerate,0.05; zoom,1; glow, color("#ffffff00");),

		LoadActor("./img/arrow_glow.png")..{
			Name="RightArrowGlow",
			InitCommand=cmd(zoom,0.25),
			OnCommand=function(self) self:diffuseshift():effectcolor1(1,1,1,0):effectcolor2(1,1,1,1) end
		},
		LoadActor("./img/arrow.png")..{
			Name="RightArrow",
			InitCommand=cmd(zoom,0.25; diffuse, Color.White ),
		}
	},

	-- left arrow
	Def.ActorFrame{
		Name="LeftArrow",
		OnCommand=cmd(x, -_screen.cx+50),
		PressCommand=cmd(decelerate,0.05; zoom,0.7; glow,color("#ffffff22"); accelerate,0.05; zoom,1; glow, color("#ffffff00")),

		LoadActor("./img/arrow_glow.png")..{
			Name="LeftArrowGlow",
			InitCommand=cmd(zoom,0.25; rotationz, 180),
			OnCommand=function(self) self:diffuseshift():effectcolor1(1,1,1,0):effectcolor2(1,1,1,1) end
		},
		LoadActor("./img/arrow.png")..{
			Name="LeftArrow",
			InitCommand=cmd(zoom,0.25; diffuse, Color.White; rotationz, 180),

		}
	}
}
-----------------------------------------------------------------
-- text

af[#af+1] = Def.ActorFrame{
	Name="CurrentSongInfoAF",
	InitCommand=function(self) self:y( row.h * 2 + 10 ):x( col.w + 80):diffusealpha(0) end,
	OnCommand=function(self) self:sleep(0.15):linear(0.15):diffusealpha(1) end,
	SwitchFocusToGroupsMessageCommand=function(self) self:visible(false) end,
	SwitchFocusToSongsMessageCommand=function(self) self:visible(true):linear(0.2):zoom(1):y(row.h*2+10):x(col.w+80) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:linear(0.2):zoom(0.9):xy(col.w+WideScale(20,65), row.h+43) end,

	-- main title
	Def.BitmapText{
		Font="_miso",
		Name="Title",
		InitCommand=function(self)
			self:zoom(1.3):diffuse(Color.White):horizalign(left):y(-45):maxwidth(300)
		end,
		CurrentSongChangedMessageCommand=function(self, params)
			if params.song then
				self:settext( params.song:GetDisplayMainTitle() )
			end
		end,
		SwitchFocusToGroupsMessageCommand=function(self) self:settext("") end,
		CloseThisFolderHasFocusMessageCommand=function(self) self:settext("") end,
		SwitchFocusToSingleSongMessageCommand=cmd(diffuse, Color.White),
		SwitchFocusToSongsMessageCommand=cmd(diffuse, Color.White)
	},

	-- artist
	Def.BitmapText{
		Font="_miso",
		Name="Artist",
		InitCommand=function(self)
			self:zoom(0.85):diffuse(Color.White):y(-20):horizalign(left)
		end,
		CurrentSongChangedMessageCommand=function(self, params)
			if params.song then
				self:settext( THEME:GetString("ScreenSelectMusic", "Artist") .. ": " .. params.song:GetDisplayArtist() )
			end
		end,
		SwitchFocusToGroupsMessageCommand=function(self) self:settext("") end,
		CloseThisFolderHasFocusMessageCommand=function(self) self:settext("") end,
		SwitchFocusToSingleSongMessageCommand=cmd(diffuse, Color.White),
		SwitchFocusToSongsMessageCommand=cmd(diffuse, Color.White)
	},

	Def.ActorFrame{
		InitCommand=function(self) self:y(25) end,

		-- BPM
		Def.BitmapText{
			Font="_miso",
			Name="BPM",
			InitCommand=function(self)
				self:zoom(0.65):diffuse(Color.White):y(0):horizalign(left)
			end,
			CurrentSongChangedMessageCommand=function(self, params)
				if params.song then
					self:settext( THEME:GetString("ScreenSelectMusic", "BPM") .. ": " .. GetDisplayBPMs() )
				end
			end,
			SwitchFocusToGroupsMessageCommand=function(self) self:settext("") end,
			CloseThisFolderHasFocusMessageCommand=function(self) self:settext("") end,
			SwitchFocusToSingleSongMessageCommand=cmd(diffuse, Color.White),
			SwitchFocusToSongsMessageCommand=cmd(diffuse, Color.White)
		},
		-- length
		Def.BitmapText{
			Font="_miso",
			Name="Length",
			InitCommand=function(self)
				self:zoom(0.65):diffuse(Color.White):y(14):horizalign(left)
			end,
	 		CurrentSongChangedMessageCommand=function(self, params)
				if params.song then
		 			self:settext( THEME:GetString("ScreenSelectMusic", "Length") .. ": " .. SecondsToMMSS(params.song:MusicLengthSeconds()):gsub("^0*","") )
				end
	 		end,
			SwitchFocusToGroupsMessageCommand=function(self) self:settext("") end,
	 		CloseThisFolderHasFocusMessageCommand=function(self) self:settext("") end,
			SwitchFocusToSingleSongMessageCommand=cmd(diffuse, Color.White),
			SwitchFocusToSongsMessageCommand=cmd(diffuse, Color.White)
		},
		-- genre
		Def.BitmapText{
			Font="_miso",
			Name="Genre",
			InitCommand=function(self)
				self:zoom(0.65):diffuse(Color.White):y(28):horizalign(left)
			end,
			CurrentSongChangedMessageCommand=function(self, params)
				if params.song then
					self:settext( THEME:GetString("ScreenSelectMusic", "Genre") .. ": " .. params.song:GetGenre() )
				end
			end,
			SwitchFocusToGroupsMessageCommand=function(self) self:settext("") end,
			CloseThisFolderHasFocusMessageCommand=function(self) self:settext("") end,
			SwitchFocusToSingleSongMessageCommand=cmd(diffuse, Color.White),
			SwitchFocusToSongsMessageCommand=cmd(diffuse, Color.White)
		},
	}
}


return af