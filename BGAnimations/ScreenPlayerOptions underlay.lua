return Def.ActorFrame{
	OnCommand=cmd(diffusealpha,0; linear,0.2; diffusealpha,1),
	OffCommand=cmd(linear,0.2; diffusealpha,0),
	
	Def.Quad{
		Name="ExplanationBackground",
		InitCommand=cmd(diffuse, color("0,0,0,0.9"); xy, _screen.cx, _screen.h-57 ),
		OnCommand=cmd(zoomto, _screen.w*0.935, _screen.h*0.08 ),
	},
	LoadFont("Miso/_miso")..{
		InitCommand=cmd(xy,_screen.cx,460; maxwidth, 470 ),
		OnCommand=function(self)
			local songtitle = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse():GetDisplayFullTitle()) or GAMESTATE:GetCurrentSong():GetDisplayFullTitle()

			if songtitle then
				self:settext(songtitle)
			end
		end
	}
	
}