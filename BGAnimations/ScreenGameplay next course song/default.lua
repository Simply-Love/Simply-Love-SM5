-- fixme: I don't scale right.
local t = Def.ActorFrame {
	Def.Sprite{
		InitCommand=cmd(Center);
		BeforeLoadingNextCourseSongMessageCommand=function(self)
			self:LoadFromSongBackground( SCREENMAN:GetTopScreen():GetNextCourseSong() )
		end;
		StartCommand=cmd(scale_or_crop_background;diffusealpha,0;sleep,0.75;decelerate,0.5;diffusealpha,1);
		FinishCommand=cmd(sleep,0.75;accelerate,0.5;diffusealpha,0);
	};
};
return t;