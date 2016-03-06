return Def.ActorFrame{

	-- "screenshot" of ScreenSelectMusic's last state
	Def.Sprite{
		OnCommand=function(self)
			self:Center()
				:SetTexture(SL.Global.ScreenshotTexture)

				--???
				:stretchto( 0,0, _screen.w, _screen.h )
		end
	},

	-- slightly darken the entire screen
	Def.Quad {
		InitCommand=cmd(FullScreen; diffuse,Color.Black; diffusealpha,0.8)
	},
}