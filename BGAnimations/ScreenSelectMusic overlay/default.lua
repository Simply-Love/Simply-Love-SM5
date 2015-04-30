local t = Def.ActorFrame{}

-- make the MusicWheel appear to cascade down
t[#t+1] = LoadActor("MusicWheelAnimation.lua")

-- Apply player modifiers from profile
t[#t+1] = LoadActor("playerModifiers.lua")

-- Banner
t[#t+1] = LoadActor("banner.lua")

-- Song Description (Artist, BPM, Duration)
t[#t+1] = LoadActor("songDescription.lua")

-- StepArtist Boxes
t[#t+1] =  LoadActor("stepArtist.lua")

-- Difficulty Blocks
t[#t+1] = LoadActor("CustomStepsDisplayList")

-- Step Data (Number of steps, jumps, holds, etc.)
t[#t+1] = LoadActor("panedisplay.lua")

-- the fadeout that informs users to press START if they want options
t[#t+1] = LoadActor("fadeOut.lua")

return t