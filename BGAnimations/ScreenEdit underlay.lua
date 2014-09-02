local bgChildren, textChildren;

return Def.ActorFrame {

	Def.ActorFrame{
		Name="Backgrounds",
		InitCommand=cmd(y,_screen.cy),
		BeginCommand=function(self)
			bgChildren = self:GetChildren()
		end,

		EditCommand=cmd(playcommand,"Show"),
		PlayingCommand=cmd(playcommand,"Hide"),
		RecordCommand=cmd(playcommand,"Hide"),
		RecordPausedCommand=cmd(playcommand,"Hide"),

		ShowCommand=function(self)
			if bgChildren then
				self:linear(0.2)
				bgChildren.HelpBG:linear(0.2)
				bgChildren.HelpBG:addx(120)

				bgChildren.InfoBG:linear(0.2)
				bgChildren.InfoBG:addx(-120)

				MESSAGEMAN:Broadcast("EditorShow")
			end
		end,
		HideCommand=function(self)
			if bgChildren then
				bgChildren.HelpBG:linear(0.2)
				bgChildren.HelpBG:addx(-120)

				bgChildren.InfoBG:linear(0.2)
				bgChildren.InfoBG:addx(120)

				MESSAGEMAN:Broadcast("EditorHide")
			end
		end,

		Def.Quad {
			Name="HelpBG",
			InitCommand=cmd(x,SCREEN_LEFT;horizalign,left;zoomtowidth,128;zoomtoheight,_screen.h;diffuse,color("#000000");diffuserightedge,color("#00000008");)
		},
		Def.Quad {
			Name="InfoBG",
			InitCommand=cmd(x,SCREEN_RIGHT;horizalign,right;zoomtowidth,128;zoomtoheight,_screen.h;diffuse,color("#000000");diffuseleftedge,color("#00000008");)
		}
	},

	Def.ActorFrame{
		Name="Text",
		InitCommand=cmd(y,SCREEN_TOP+16;),

		BeginCommand=function(self)
			textChildren = self:GetChildren()
		end,

		EditCommand=cmd(playcommand,"Show"),
		PlayingCommand=cmd(playcommand,"Hide"),
		RecordCommand=cmd(playcommand,"Hide"),
		RecordPausedCommand=cmd(playcommand,"Hide"),

		ShowCommand=function(self)
			if textChildren then
				textChildren.HelpText:linear(0.2)
				textChildren.HelpText:addx(120)

				textChildren.InfoText:linear(0.2)
				textChildren.InfoText:addx(-120)
			end
		end,
		HideCommand=function(self)
			if textChildren then
				self:linear(0.2)
				textChildren.HelpText:linear(0.2)
				textChildren.HelpText:addx(-120)

				textChildren.InfoText:linear(0.2)
				textChildren.InfoText:addx(120)
			end
		end,

		LoadFont("_misoreg hires") .. {
			Name="HelpText",
			InitCommand=cmd(x,SCREEN_LEFT+60;zoom,0.75;settext,THEME:GetString("ScreenEdit","Help");strokecolor,color("#00000077");shadowlength,0)
		},
		Def.Quad{
			InitCommand=cmd(x,SCREEN_LEFT+60;y,12;zoomto,120,2;diffuse,color("1,1,1,0.8");shadowlength,1)
		},

		LoadFont("_misoreg hires") .. {
			Name="InfoText",
			InitCommand=cmd(x,SCREEN_RIGHT-60;zoom,0.75;settext,THEME:GetString("ScreenEdit","Info");strokecolor,color("#00000077");shadowlength,0)
		},
		Def.Quad{
			InitCommand=cmd(x,SCREEN_RIGHT-60;y,12;zoomto,120,2;diffuse,color("1,1,1,0.8");shadowlength,1)
		}
	}
}