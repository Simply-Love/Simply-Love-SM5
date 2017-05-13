return Def.ActorFrame{

	LoadActor( THEME:GetPathG("", "_header.lua") ),

	Def.BitmapText{
		Name="GameModeText",
		Font="_wendy small",
		InitCommand=function(self)
			self:diffusealpha(0):zoom( WideScale(0.5,0.6)):xy(_screen.w-70, 16):halign(1)
			if not PREFSMAN:GetPreference("MenuTimer") then
				self:x(_screen.w-10)
			end
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
				:settext(THEME:GetString("ScreenSelectPlayMode", SL.Global.GameMode))
		end,
	},

	LoadFont("_wendy small") .. {
		InitCommand=cmd(zoom,WideScale(0.4, 0.5); xy, _screen.cx, SCREEN_BOTTOM-15; horizalign,center; diffusealpha,0; queuecommand,"TextSet"),
		TextSetCommand=function(self)
					self:settext( string.format('%s %02i %04i', MonthToString(MonthOfYear()), DayOfMonth(), Year()) )
		end,
		OnCommand=cmd(decelerate,0.5; diffusealpha,1),
		OffCommand=cmd(accelerate,0.5;diffusealpha,0)
	},

}
