local background, root = ...

return Def.ActorFrame{
	Def.Sprite{
		Texture=root .. background.file,
		InitCommand=function(self)
			local scaleX = _screen.w / self:GetWidth()
			local scaleY = _screen.h / self:GetHeight()
			local scale = background.fit == "contain" and math.min(scaleX, scaleY) or math.max(scaleX, scaleY)
			self:Center():zoom(scale)
		end,
	},
	Def.Quad{
		InitCommand=function(self)
			self:FullScreen():Center():diffuse(Color.Black):diffusealpha(background.dim or 0)
		end,
	},
}
