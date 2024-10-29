local af = Def.ActorFrame{
	StartCommand=function(self)
		self:diffusealpha(0):visible(true):sleep(0.75):decelerate(0.5):diffusealpha(1)
	end,
	FinishCommand=function(self)
		-- tween for 1 second by default
		local duration = 1
		-- but decrease the overall tween time if musicrate is > 1 to ensure that this doesn't accidentally block arrows
		if SL.Global.ActiveModifiers.MusicRate > 1 then
			duration = duration * (1/SL.Global.ActiveModifiers.MusicRate)
		end

		self:sleep(duration/2):accelerate(duration/2):diffusealpha(0):queuecommand("Hide")
	end,
	HideCommand=function(self)
		self:visible(false)
	end,

	Def.Quad{
		InitCommand=function(self) self:diffuse(Color.Black):FullScreen() end
	},

	Def.Sprite{
		BeforeLoadingNextCourseSongMessageCommand=function(self)
			self:LoadFromSongBackground( SCREENMAN:GetTopScreen():GetNextCourseSong() )
		end,
		StartCommand=function(self) self:scale_or_crop_background() end
  }
}

if GAMESTATE:IsCourseMode() then
	af[#af+1] = LoadActor("ChangeSpeedModBeforeFirstNote.lua")
end

return af