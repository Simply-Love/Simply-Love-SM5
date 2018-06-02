return Def.Sprite{
	InitCommand=function(self) self:Center() end,
	BeforeLoadingNextCourseSongMessageCommand=function(self)
		self:LoadFromSongBackground( SCREENMAN:GetTopScreen():GetNextCourseSong() )
	end,
	StartCommand=cmd(scale_or_crop_background;diffusealpha,0;sleep,0.75;decelerate,0.5;diffusealpha,1),
	FinishCommand=function(self)
		self:sleep(0.5):accelerate(0.5):diffusealpha(0)
		if SL.Global.ActiveModifiers.MusicRate > 1 then
			self:hurrytweening( 1/SL.Global.ActiveModifiers.MusicRate )
		end
	end
}