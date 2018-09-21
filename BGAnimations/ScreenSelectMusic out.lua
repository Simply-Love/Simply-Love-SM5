return Def.ActorFrame{
	InitCommand=function(self) self:draworder(200) end,

	Def.Quad{
		InitCommand=cmd(diffuse,Color.Black; FullScreen; diffusealpha,0 ),
		OffCommand=cmd(cropbottom,1; fadebottom,.5; linear,0.3; cropbottom,-0.5; diffusealpha,1)
	},

	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenSelectMusic","Press Start for Options"),
		InitCommand=cmd(Center; zoom,0.75 ),
		OnCommand=cmd(visible, false),
		ShowPressStartForOptionsCommand=cmd(visible,true;),
		ShowEnteringOptionsCommand=cmd(linear,0.125; diffusealpha,0; queuecommand, "NewText"),
		NewTextCommand=cmd(hibernate,0.1; settext,THEME:GetString("ScreenSelectMusic", "Entering Options..."); linear,0.125; diffusealpha,1; hurrytweening,0.1; sleep,1)
	},

	-- my additions (time bar)
	Def.ActorFrame{
		InitCommand=function(self)
			self:y(_screen.cy + 50)
		end,

		Border(150+4, 25+4, 2)..{
			OnCommand=function(self)
				self:CenterX()
			end
		},

		Def.Quad{
			InitCommand=function(self)
				self:zoomto(150, 25)
				self:diffuse(color("0,1,0,1"))
				self:horizalign(left)
			end,

			OnCommand=function(self)
				self:x(_screen.cx - 75)
				self:linear(1.5)
				self:zoomx(0)
			end
		},

		--InitCommand=cmd(zoomx,100;zoomy,25; diffuse,Color.White; CenterX; y,_screen.cy + 40; diffusealpha, 0.5),
		ShowEnteringOptionsCommand=cmd(linear,0.125; diffusealpha,0)
	}
}
