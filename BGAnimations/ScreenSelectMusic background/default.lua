--- If you plan replacing this with another video, I would highly recommend using .avi over .mp4
--- Stepmania seems to have a hard time looping mp4s.
--- It tends to start the loop partway into the file and if it's too short it just wont loop at all.

local af = Def.ActorFrame{

 LoadActor("./background (loop).avi")..{
	InitCommand=function(self) self:diffusealpha(0.3):FullScreen():valign(0):y(0) end,
}
}
return af